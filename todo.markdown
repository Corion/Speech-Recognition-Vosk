# Things to do before release/talk

[✓] Implement C program to read from stdin (with ffmpeg)

## Write XS module to expose the API

[✓] Inline::C as prototype
[✓] Wrap/import vosk_api.h
[✓] Deparse all JSON

Module name: Speech::Recognition::Vosk

## Simple "read audio stream from ffmpeg, return hash" API

## Simple "read audio stream from ffmpeg, return hash" API, but async/pollable/feedable

# Things to do before after release/talk

[ ] Split up in Alien::Vosk and Speech::Recognition::Vosk
    This means that we can maybe (re)use a local Vosk build instead of always
    trying to create our own.

[ ] Investigate how to use the OS supplied/packaged lapack instead of vendored
    clapack

[ ] Vendor OG lapack instead of 2008 clapack
    http://www.netlib.org/lapack/
