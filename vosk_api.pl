#!perl
use strict;
use Speech::Recognition::Vosk;

print "Loading model\n";
Speech::Recognition::Vosk::set_log_level(-1); # silence

my $model = Speech::Recognition::Vosk::model_new("model-en");
my $recognizer = Speech::Recognition::Vosk::recognizer_new($model, 44100);
Speech::Recognition::Vosk::recognizer_set_words( $recognizer,1);
print "Ready\n";

binmode STDIN, ':raw';

use JSON 'decode_json';

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

