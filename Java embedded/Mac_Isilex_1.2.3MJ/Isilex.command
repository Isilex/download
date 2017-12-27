#!/bin/bash

# working directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JAVA=$DIR/jre_osx/Contents/Home/bin
rm -f .basex
cd $DIR
$JAVA/java -jar $DIR/Isilex.jar 2>&1 /dev/null

