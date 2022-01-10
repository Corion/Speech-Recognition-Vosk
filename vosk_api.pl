#!perl
use strict;

use Inline C => 'Config',
    autowrap => 1,
    auto_include => '#include "build/vosk-api/src/vosk_api.h"',
    # => name => 'Speech::Recognition::Vosk',
    build_noisy => 1,
    LIBS => '-L/home/corion/Projekte/vosk/build/vosk-api/src -lvosk -ldl -lpthread -Wl,-rpath=/home/corion/Projekte/vosk/build/vosk-api/src'
    ;

use Inline C => << 'END_OF_C_CODE';
int Vosk_vosk_model_find_word(SV* model, const char *word) {
    return vosk_model_find_word((VoskModel*)SvIV(model), *word);
}

SV* Vosk_vosk_model_new(SV* modelname) {
    VoskModel* model;
    SV* res;
    model = vosk_model_new(SvPV_nolen(modelname));
    res = newSViv((IV) model); /* We store the pointer as an int in our result */

    return res;
}

void Vosk_vosk_model_free(SV* model) {
    vosk_model_free((VoskModel*)SvIV(model));
}


SV* Vosk_vosk_recognizer_new(SV* model, double sample_rate) {
    VoskRecognizer* recognizer;
    SV* res;

    // XXX Keep a reference to the model in our recognizer for housekeeping

    recognizer = vosk_recognizer_new((VoskModel*)SvIV(model), sample_rate);

    res = newSViv((IV) recognizer);
    return res;
}

/* Implicitly also releases the model! */
void Vosk_vosk_recognizer_free(SV *recognizer) {
    vosk_recognizer_free((VoskRecognizer*) SvIV(recognizer));
}

void Vosk_vosk_recognizer_set_words(SV *recognizer, int words) {
    vosk_recognizer_set_words((VoskRecognizer*)SvIV(recognizer), words);
}

bool Vosk_vosk_recognizer_accept_waveform(SV* recognizer, SV* buf) {
    char* payload;
    STRLEN strlen;
    bool final;

    payload = SvPVbyte(buf,strlen);
    VoskRecognizer* r;

    r = (VoskRecognizer*)SvIV(recognizer);
    final = vosk_recognizer_accept_waveform(r, payload, strlen);

    return final;
}

char* Vosk_vosk_recognizer_partial_result(SV* recognizer) {
    return vosk_recognizer_partial_result((VoskRecognizer*)SvIV(recognizer));
}

char* Vosk_vosk_recognizer_result(SV* recognizer) {
    return vosk_recognizer_result((VoskRecognizer*)SvIV(recognizer));
}

char* Vosk_vosk_recognizer_final_result(SV* recognizer) {
    return vosk_recognizer_final_result((VoskRecognizer*)SvIV(recognizer));
}
END_OF_C_CODE

my $model = Vosk_vosk_model_new("model-en");
my $recognizer = Vosk_vosk_recognizer_new($model, 44100);
Vosk_vosk_recognizer_set_words( $recognizer,1);
print "Ready\n";

binmode STDIN, ':raw';

use JSON 'decode_json';

while( ! eof(*STDIN)) {
    read(STDIN, my $buf, 3200);
    my $complete = Vosk_vosk_recognizer_accept_waveform($recognizer, $buf);
    my $spoken;
    if( $complete ) {
        $spoken = Vosk_vosk_recognizer_result($recognizer);
    } else {
        $spoken = Vosk_vosk_recognizer_partial_result($recognizer);
    }
    # JSON-decode

    my $info = decode_json($spoken);
    if( $info->{text}) {
        print $info->{text},"\n";
    } else {
        local $| = 1;
        print $info->{partial}, "\r";
    };
}

# Flush the buffers
my $spoken = Vosk_vosk_recognizer_final_result($recognizer);
print $spoken;

