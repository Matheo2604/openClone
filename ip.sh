#!/bin/bash

a=true
b=false

case "$a$b" in
  "truetrue")
    echo "1"
    ;;
  "falsetrue")
    echo "2"
    ;;
  "truefalse")
    echo "3"
    ;;
  "falsefalse")
    echo "4"
    ;;
  *)
    echo "Invalid combination"
    ;;
esac

