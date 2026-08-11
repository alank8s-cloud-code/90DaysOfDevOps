#!/bin/bash

START="<!-- SURAJ-START -->"
END="<!-- SURAJ-END -->"

awk -v start="$START" -v end="$END" '
$0 == start {
    print
    while ((getline line < "suraj.md") > 0)
        print line
    close("suraj.md")
    inside=1
    next
}
$0 == end {
    inside=0
    print
    next
}
!inside { print }
' README.md > README.tmp && mv README.tmp README.md
