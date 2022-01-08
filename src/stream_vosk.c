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
