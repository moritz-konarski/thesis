#!/bin/bash

/usr/bin/pandoc *.md -o topic_selection.pdf \
    --pdf-engine=xelatex \
    -s \
    --toc
    #--toc-depth=3 \
