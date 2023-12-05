#!/bin/sh

function get_dev() {
    local d

    d="$(lspci | grep 'Western Digital Device beef' | cut -d ' ' -f 1)"
    if [ -z "${d}" ]; then
        echo "device not found"
        exit 1
    fi

    if [[ "${d}" =~ ^[0-9A-Fa-f]{4}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}\.[0-9A-Fa-f]$ ]]; then
        echo "${d}"
    else
        echo "0000:${d}"
    fi
}
