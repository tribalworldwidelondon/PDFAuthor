#!/bin/sh

# Check if all the required commands exist

if ! [ -x "$(command -v swift)" ]; then
    echo 'Error: Swift is not installed.' >&2
    exit 1
fi

if ! [ -x "$(command -v sourcekitten)" ]; then
    echo 'Error: sourcekitten is not installed.' >&2
    echo 'Install it with "brew install sourcekitten"' >&2
    exit 1
fi

if ! [ -x "$(command -v jazzy)" ]; then
    echo 'Error: jazzy is not installed.' >&2
    echo 'Install it with "gem install jazzy"' >&2
    exit 1
fi

swift build

sourcekitten doc --spm-module PDFAuthor > .PDFAuthorDoc.json

jazzy -s .PDFAuthorDoc.json \
    --clean \
    --author "Tribal Worldwide London" \
    --author_url "http://tribalworldwide.co.uk" \
    --module PDFAuthor 
