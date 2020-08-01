#!/bin/bash

/usr/bin/pandoc 0*.md -o topic_selection.pdf \
    --pdf-engine=xelatex \
    -s \
    --toc
    #--toc-depth=3 \
