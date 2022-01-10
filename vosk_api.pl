#!perl
use strict;

use Inline C => Config
    => autowrap => 1
    => auto_include => '#include "build/vosk-api/src/vosk_api.h"'
    => libs => '-Lbuild/vosk-api/src -lvosk -ldl -lpthread -Wl,-rpath=build/vosk-api/src'
    ;

sub read_vosk_headers {
    open my $fh, '<', 'build/vosk-api/src/vosk_api.h'
        or die "$!";
    local $/;
    <$fh>
};
use Inline C => \&read_vosk_headers;

my $model = vosk_model_new("model");

