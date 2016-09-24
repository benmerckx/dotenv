#!/bin/sh
zip -r submit.zip src haxelib.json README.md -x "*/\.*"
haxelib submit submit.zip
rm submit.zip 2> /dev/null