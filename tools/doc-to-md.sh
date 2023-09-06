#!/bin/bash

set -eu

# Get all the docx files in the tmp dir.
find tmp -name '*.docx' -print0 | \
# Extract just the filename so we can reuse it easily 哈哈哈.
xargs -0 basename -s .docx | \
while IFS= read -r filename; do
    # Truncate the `nostarch` dir file and put the "no editing" warning back.
    # Tell shellcheck to ignore this because I want the `/src/` printed
    # literally, not expanded.
    # shellcheck disable=SC2016
    echo '<!-- DO NOT EDIT THIS FILE.

This file is periodically generated from the content in the `/src/`
directory, so all fixes need to be made in `/src/`.
-->' > "nostarch/$filename.md"
    # Make a directory to put the XML in.
    mkdir -p "tmp/$filename"
    # Unzip the docx to get at the XML.
    unzip -o "tmp/$filename.docx" -d "tmp/$filename"
    # Convert to markdown with XSL.
    xsltproc tools/docx-to-md.xsl "tmp/$filename/word/document.xml" | \
    # Hard wrap at 80 chars at word bourdaries.
    fold -w 80 -s | \
    # Remove trailing whitespace and append to the file in the `nostarch` dir for comparison.
    sed -e "s/ *$//" >> "nostarch/$filename.md"
done
