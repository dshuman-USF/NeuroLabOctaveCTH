#!/bin/bash

for i in *.m # or whatever other pattern...
do
  if ! grep -q -i Copyright $i
  then
    cat LICENSE $i >$i.new && touch -r $i $i.new && mv $i.new $i
  fi
done
