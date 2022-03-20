package Speech::Recognition::Vosk;
use strict;
use 5.012; # //=
use Carp 'croak';

our $VERSION = '0.03';

our @EXPORT_OK = (qw(
    model_new
    model_find_word
    recognizer_new
    recognizer_free
    recognizer_accept_waveform
    recognizer_partial_result
    recognizer_result
    recognizer_final_result
));

=head1 NAME

Speech::Recognition::Vosk - offline speech recognition using the Vosk toolkit

=head1 SYNOPSIS

Most likely, you want to use the more convenient OO wrapper in
L<Speech::Recognition::Vosk::Recognizer>.

  use Speech::Recognition::Vosk;
  use JSON 'decode_json';

  my $model = Speech::Recognition::Vosk::model_new("model-en");
  my $recognizer = Speech::Recognition::Vosk::recognizer_new($model, 44100);

  binmode STDIN, ':raw';

  while( ! eof(*STDIN)) {
      read(STDIN, my $buf, 3200);
      my $complete = Speech::Recognition::Vosk::recognizer_accept_waveform($recognizer, $buf);
      my $spoken;
      if( $complete ) {
          $spoken = Speech::Recognition::Vosk::recognizer_result($recognizer);
      } else {
          $spoken = Speech::Recognition::Vosk::recognizer_partial_result($recognizer);
      }

      my $info = decode_json($spoken);
      if( $info->{text}) {
          print $info->{text},"\n";
      } else {
          local $| = 1;
          print $info->{partial}, "\r";
      };
  }

  # Flush the buffers
  my $spoken = Speech::Recognition::Vosk::recognizer_final_result($recognizer);
  my $info = decode_json($spoken);
  print $info->{text},"\n";

=head1 FUNCTIONS

=cut

sub import {
    my %args = @_;
    if( $^O eq 'MSWin32' ) {
        $args{binding} //= 'win32';
    } else {
        $args{binding} //= 'xs';
    }

    my $impl;
    if( $args{ binding } eq 'xs' ) {
        $impl = 'Speech::Recognition::Vosk::Impl::XS';
    } elsif( $args{ binding } eq 'win32' ) {
        $impl = 'Speech::Recognition::Vosk::Impl::Win32';
    } else {
        croak "Unknown binding '$args{binding}'";
    }

    (my $module = $impl) =~ s!::!/!g;
    require "$module.pm";
    $impl->import(@EXPORT_OK);
}

1;
