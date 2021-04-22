#!/bin/bash

crd_dir="./crds"

res=$(ls -A $crd_dir | wc -w)
if [ "$res" = "0" ]; then
  exit
else
  kubectl apply -f $crd_dir
fi
