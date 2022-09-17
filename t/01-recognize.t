#!perl
use strict;
use warnings;

use Test::More;
use Speech::Recognition::Vosk::Recognizer;

my $model_dir = 'models/vosk-model-small-en-us-0.15';
SKIP: {
    if( ! -d $model_dir) {
        plan skip_all => 'No recognition model installed in ./models/';
        exit;
    }
}
my @utterances = ('hello', 'this is a test');
plan tests => 0+@utterances;

my $recognizer = Speech::Recognition::Vosk::Recognizer->new(
    model_dir => $model_dir,
    sample_rate => 44100,
);

# record from ffmpeg audio device
open my $voice, "t/test.s16le.pcm";
binmode $voice, ':raw';

my $idx = 0;
while( ! eof($voice)) {
    read($voice, my $buf, 3200);

    my $complete = $recognizer->accept_waveform($buf);
    my $spoken;
    if( $complete ) {
        $spoken = $recognizer->result();
        my $i = $idx++;
        is $spoken->{text}, $utterances[$i], $utterances[$i];
    } else {
        if( $spoken->{text}) {
            note "Partial: '$spoken->{text}'";
        };
    }
};
