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
SV* Vosk_vosk_model_new(SV* modelname) {
    VoskModel* model;
    SV* res;
    model = vosk_model_new(SvPV_nolen(modelname));
    res = newSViv((IV) model); /* We store the pointer as an int in our result */

    return res;
}

SV* Vosk_vosk_recognizer_new(SV* model, double sample_rate) {
    VoskRecognizer* recognizer;
    SV* res;

    // XXX Keep a reference to the model in our recognizer for housekeeping

    recognizer = vosk_recognizer_new((VoskModel*)SvIV(model), sample_rate);

    res = newSViv((IV) recognizer);
    return res;
}
END_OF_C_CODE

my $model = Vosk_vosk_model_new("model");
my $recognizer = Vosk_vosk_recognizer_new($model, 44100);

__END__
#include <vosk_api.h>
#include <stdio.h>

int main() {
    char buf[3200];
    int nread, final;

    VoskModel *model = vosk_model_new("model");
    VoskRecognizer *recognizer = vosk_recognizer_new(model, 44100.0);

    freopen(NULL, "rb", stdin);
    while (!feof(stdin)) {
         nread = fread(buf, 1, sizeof(buf), stdin);
         final = vosk_recognizer_accept_waveform(recognizer, buf, nread);
         if (final) {
             printf("%s\n", vosk_recognizer_result(recognizer));
         } else {
             printf("%s\n", vosk_recognizer_partial_result(recognizer));
         }
    }
    printf("%s\n", vosk_recognizer_final_result(recognizer));

    vosk_recognizer_free(recognizer);
    vosk_model_free(model);
    fclose(stdin);
    return 0;
}
