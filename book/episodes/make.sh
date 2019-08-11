#!/bin/bash
for f in `ls *.md`
do
perl ../../script/mkhtml.pl "$f" > "out/${f%.*}.html"
done
