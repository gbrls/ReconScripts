#!/usr/bin/env bash

TARGET="$1"
DATE="`date +%Y-%m-%d`"
OUTDIR="$TARGET-$DATE"
IGNORE_PAT='\.(jpg|jpeg|png|gif|bmp|ico|svg|ttf|otf|woff|eot|css)$'

function setup {
    #TODO: install with go
    _V="`gau --version`"
    if [[ "$_V" == "" ]]; then
        echo -e "gau not in path"
        exit 1
    fi

    _V="`katana --help`"
    if [[ "$_V" == "" ]]; then
        echo -e "katana not in path"
        exit 1
    fi

    _V="`httpx --help`"
    if [[ "$_V" == "" ]]; then
        echo -e "httpx not in path"
        exit 1
    fi

    _V="`kurl --help`"
    if [[ "$_V" == "" ]]; then
        echo -e "kurl not in path"
        exit 1
    fi

    mkdir "$OUTDIR"
}

function run_gau {
    echo -e "[info] Running gau"
    printf "$TARGET" | gau | grep -v -E "$IGNORE_PAT" | tee "$OUTDIR/tmp-gau.txt"
    printf "$TARGET\n" >> "$OUTDIR/tmp-gau.txt"

}

function run_katana {
    echo -e "[info] Running katana"
    # -fqdn -dn has a more strict scope control than -rdn
    katana -list "$OUTDIR/tmp-gau.txt" -js-crawl -fs fqdn | tee "$OUTDIR/tmp-katana.txt"
}

function run_kurl {
    echo -e "writing to $TARGET-$DATE.txt"
    echo -e "[info] Running kurl"
    export LC_CTYPE=C 
    export LANG=C
    # sort kind of crashes sometimes...
    cat "$OUTDIR/tmp-gau.txt" "$OUTDIR/tmp-katana.txt" | sort -u | xargs -P32 -I{} bash -c "kurl --all -n '{}' 2>/dev/null" | sort -u -k2 -n | tee "$TARGET-$DATE.txt"

}

function cleanup {
    echo -e "[info] cleaning up files"
    rm -rf "$OUTDIR"
}

setup
run_gau
run_katana
run_kurl
cleanup
