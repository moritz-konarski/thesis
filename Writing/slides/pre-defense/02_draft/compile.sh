#!/bin/bash

cd ./build/
latexmk ../src/01_main.tex -pdflua
cd ..
mv ./build/01_main.pdf ./main.pdf
