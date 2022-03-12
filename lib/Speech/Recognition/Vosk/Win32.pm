#!perl
use strict;
use 5.012;
use File::Basename 'dirname';
use Win32::API;
use Exporter 'import';

# We want to load the DLLs from here:
$ENV{PATH} .= ";" . dirname($0) . "/vosk-win64-0.3.32";

#our $model_new = Win32::API->new("libvosk.dll", "vosk_model_new", "P", "N")
Win32::API::More->Import("libvosk.dll", "vosk_model_new", "P", "N")
    or die $^E;

Win32::API::More->Import("libvosk.dll", "vosk_model_find_word", "NP", "N")
    or die $^E;
    
Win32::API::More->Import("libvosk.dll", "vosk_recognizer_new", "NF", "N")
    or die $^E;

Win32::API->Import("libvosk.dll", "vosk_recognizer_accept_waveform", "NPN", "N")
    or die $^E;

Win32::API->Import("libvosk.dll", "vosk_recognizer_partial_result", "N", "P")
    or die $^E;

Win32::API->Import("libvosk.dll", "vosk_recognizer_result", "N", "P")
    or die $^E;

Win32::API->Import("libvosk.dll", "vosk_recognizer_final_result", "N", "P")
    or die $^E;


our @EXPORT_OK = (qw(
    vosk_model_new
    vosk_model_find_word
    vosk_model_recognizer_new
    vosk_model_recognizer_accept_waveform
    vosk_model_recognizer_partial_result
    vosk_model_recognizer_result
    vosk_model_recognizer_final_result
));

1;