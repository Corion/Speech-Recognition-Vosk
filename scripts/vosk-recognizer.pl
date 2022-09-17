#!perl
use strict;
use utf8;
use Speech::Recognition::Vosk::Recognizer;
use Encode 'encode';

my $recognizer = Speech::Recognition::Vosk::Recognizer->new(
    model_dir => 'models/vosk-model-small-en-us-0.15',
    sample_rate => 44100,
);

my $ffmpeg;
if( $^O eq 'MSWin32' ) {
    # find the name of your audio device using
    # ffmpeg -list_devices true -f dshow -i dummy
    $ffmpeg = encode('Latin-1','ffmpeg -hide_banner -nostats -ac 1 -ar 44100 -f dshow -i audio="Microphone Array (Intel® Smart Sound Technologie für digitale Mikrofone)" -f s16le pipe:1');
} else {
    $ffmpeg = 'ffmpeg -hide_banner -loglevel error -nostats -f pulse -i 11 -t 30 -ac 1 -ar 44100 -f s16le -';
}
# record from PulseAudio device 11
open my $voice, "$ffmpeg |";
binmode $voice, ':raw';

while( ! eof($voice)) {
    read($voice, my $buf, 3200);

    my $complete = $recognizer->accept_waveform($buf);
    my $info;
    if( $complete ) {
        $info = $recognizer->result();
    } else {
        $info = $recognizer->partial_result();
    }
    if( $info->{text}) {
        print $info->{text},"\n";
    } else {
        print $info->{partial}, "\r";
    };
};
my $info = $recognizer->final_result();
print $info->{text},"\n";
