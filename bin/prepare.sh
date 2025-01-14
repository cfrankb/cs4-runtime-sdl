#!/bin/bash
mkdir -p ./build/final
rm -f ./build/final/*
cp ./build/cs4v2.* ./build/final
gzip  ./build/final/*.data ./build/final/*.wasm
mv ./build/final/cs4v2.data.gz ./build/final/cs4v2.data
mv ./build/final/cs4v2.wasm.gz ./build/final/cs4v2.wasm
