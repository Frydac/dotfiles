#!/usr/bin/env bash

# TODO: use array of strings to enable/disable different features

function auro {
    echo auro_compiler="$auro_compiler"
}

function auro_reload
{
    export auro_compiler="color-use_mold-vlc-${auro_cmd}-${auro_mode}-${auro_arch}${auro_postfix}"
    auro
}

function debug {
    export auro_mode="debug"
    auro_reload
}

function reldeb {
    export auro_mode="release_with_debug"
    auro_reload
}

function release {
    export auro_mode="release"
    auro_reload
}

function rel_mss {
    export auro_mode="auro_mss_log_in_release"
    auro_reload
}

function noverbose {
    unset auro_verbose=0
    echo "$auro_verbose"
}

function verbose {
    export auro_verbose=1
    echo "$auro_verbose"
}

function nortc {
    export auro_postfix=""
    auro_reload
}

function rtc {
    export auro_postfix="-rtc"
    auro_reload
}

function x32 {
    export auro_arch="x86"
    auro_reload
}

function x86 {
    export auro_arch="x86"
    auro_reload
}

function x64 {
    export auro_arch="x64"
    auro_reload
}

function auro_gcc {
    export auro_cmd="gcc"
    auro_reload
}

function auro_clang {
    export auro_cmd="clang"
    auro_reload
}

function init {
    auro_gcc
    x64
    debug
    rtc
}

init > /dev/null

