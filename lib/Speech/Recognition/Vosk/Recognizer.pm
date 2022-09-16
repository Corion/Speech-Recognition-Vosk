package Speech::Recognition::Vosk::Recognizer;
use Speech::Recognition::Vosk;
use JSON 'decode_json';
use Moo 2;

use Filter::signatures;
use feature 'signatures';
no warnings 'experimental::signatures';

our $VERSION = '0.01';

=head1 NAME

Speech::Recognition::Vosk::Recognizer - offline speech recognition using Vosk

=head1 SYNOPSIS

  use Speech::Recognition::Vosk::Recognizer;
  # You need to download and extract an appropriate model
  # from https://alphacephei.com/vosk/models

  my $recognizer = Speech::Recognition::Vosk::Recognizer->new(
      model_dir => 'models/vosk-model-small-en-us-0.15', # use the directory name of the extracted model here
      sample_rate => 44100,
  );

  # record from PulseAudio device 11
  open my $voice, 'ffmpeg -hide_banner -loglevel error -nostats -f pulse -i 11 -t 30 -ac 1 -ar 44100 -f s16le - |';
  binmode $voice, ':raw';

  while( ! eof($voice)) {
      read($voice, my $buf, 3200);

      my $complete = $recognizer->accept_waveform($buf);
      my $spoken;
      if( $complete ) {
          $spoken = $recognizer->result();
      } else {
          $spoken = $recognizer->partial_result();
      }
      my $info = decode_json($spoken);
      if( $info->{text}) {
          print $info->{text},"\n";
      } else {
          local $| = 1;
          print $info->{partial}, "\r";
      };
  };
  my $spoken = $recognizer->final_result();
  print $info->{text},"\n";

=head1 METHODS

=head2 C<< ->new >>

  my $recognizer = Speech::Recognition::Vosk::Recognizer->new(
      model_dir => 'model-en',
      sample_rate => 44100,
  );

=over 4

=item B<model_dir>

The directory of the extracted model. Download these from L<https://alphacephei.com/vosk/models>
and extract them somewhere.

=cut

has model_dir => (
    is => 'ro',
);

=item B<sample_rate>

The sample rate of the PCM  signed, 16-bit, little-endian audio input.

Default is 44100.

=cut

has sample_rate => (
    is => 'ro',
);

=item B<model>

A premade Vosk model

=back

=cut

has model => (
    is => 'lazy',
    default => sub( $self ) {
        #warn "Loading model '$self->{model_dir}'";
        Speech::Recognition::Vosk::model_new($self->model_dir)
    },
);

has '_recognizer' => (
    is => 'lazy',
    default => sub( $self ) {
        Speech::Recognition::Vosk::recognizer_new($self->model, $self->sample_rate);
    },
);

sub DESTROY($self) {
    # Implicitly also destroys the model!
    if( $self->{_recognizer} ) {
        Speech::Recognition::Vosk::recognizer_free($self->_recognizer)
    }
}

=head2 C<< ->accept_waveform >>

  read($voice, my $buf, 3200);
  my $complete = $recognizer->accept_waveform($buf);

Feed more data to the recognizer. Returns if a pause in the speech was detected
and a completed utterance is available.

=cut

sub accept_waveform($self,$buf) {
    return Speech::Recognition::Vosk::recognizer_accept_waveform($self->_recognizer,$buf, length $buf);
};

=head2 C<< ->result >>

  my $spoken = $recognizer->result();
  print $spoken->{text};

Returns a hashref containing the recognized text.

=cut

sub result( $self ) {
    return decode_json( Speech::Recognition::Vosk::recognizer_result($self->_recognizer))
}

=head2 C<< ->partial_result >>

  my $spoken = $recognizer->partial_result();
  print "$spoken->{partial}\r";

Returns a hashref containing the recognized text so far. The text may change
when more data is collected.

=cut

sub partial_result( $self ) {
    return decode_json( Speech::Recognition::Vosk::recognizer_partial_result($self->_recognizer))
}

=head2 C<< ->final_result >>

  my $spoken = $recognizer->final_result();
  print $spoken->{text};

Returns a hashref containing the recognized text.

Call this method at the end of the input to flush any pending data.

=cut

sub final_result( $self ) {
    return decode_json( Speech::Recognition::Vosk::recognizer_final_result($self->_recognizer))
}

=head1 SEE ALSO

Vosk - L<https://alphacephei.com/vosk/> , L<https://github.com/alphacep/vosk-api>

=head2 MODELS

Download pretrained models from

L<https://alphacephei.com/vosk/models>

=cut

1;
