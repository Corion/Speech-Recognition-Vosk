package Speech::Recognition::Vosk;
use strict;
our $VERSION = '0.01';

use Inline C => 'Config',
    autowrap => 1,
    auto_include => '#include "build/vosk-api/src/vosk_api.h"',
    name => 'Speech::Recognition::Vosk',
    prefix => 'Vosk_',
    build_noisy => 1,
    LIBS => '-L/home/corion/Projekte/vosk/build/vosk-api/src -lvosk -ldl -lpthread -Wl,-rpath=/home/corion/Projekte/vosk/build/vosk-api/src'
    ;

use Inline C => << 'END_OF_C_CODE';
int
Vosk_model_find_word(SV* model, const char *word) {
    return vosk_model_find_word((VoskModel*)SvIV(model), *word);
}

SV*
Vosk_model_new(SV* modelname) {
    VoskModel* model;
    SV* res;
    model = vosk_model_new(SvPV_nolen(modelname));
    res = newSViv((IV) model); /* We store the pointer as an int in our result */

    return res;
}

void
Vosk_model_free(SV* model) {
    vosk_model_free((VoskModel*)SvIV(model));
}

SV*
Vosk_recognizer_new(SV* model, double sample_rate) {
    VoskRecognizer* recognizer;
    SV* res;

    // XXX Keep a reference to the model in our recognizer for housekeeping

    recognizer = vosk_recognizer_new((VoskModel*)SvIV(model), sample_rate);

    res = newSViv((IV) recognizer);
    return res;
}

/* Implicitly also releases the model! */
void
Vosk_recognizer_free(SV *recognizer) {
    vosk_recognizer_free((VoskRecognizer*) SvIV(recognizer));
}

void
Vosk_recognizer_set_words(SV *recognizer, int words) {
    vosk_recognizer_set_words((VoskRecognizer*)SvIV(recognizer), words);
}

bool
Vosk_recognizer_accept_waveform(SV* recognizer, SV* buf) {
    char* payload;
    STRLEN strlen;
    bool final;

    payload = SvPVbyte(buf,strlen);
    VoskRecognizer* r;

    r = (VoskRecognizer*)SvIV(recognizer);
    final = vosk_recognizer_accept_waveform(r, payload, strlen);

    return final;
}

char*
Vosk_recognizer_partial_result(SV* recognizer) {
    return vosk_recognizer_partial_result((VoskRecognizer*)SvIV(recognizer));
}

char*
Vosk_recognizer_result(SV* recognizer) {
    return vosk_recognizer_result((VoskRecognizer*)SvIV(recognizer));
}

char*
Vosk_recognizer_final_result(SV* recognizer) {
    return vosk_recognizer_final_result((VoskRecognizer*)SvIV(recognizer));
}
END_OF_C_CODE

1;
