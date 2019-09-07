#!/bin/bash
mkdir -p out
rm out/*.html

for f in `ls *.md`
do
perl ../../script/mkhtml.pl "$f" > "out/${f%.*}.html"
done
