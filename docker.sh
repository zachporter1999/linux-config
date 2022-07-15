#!/bin/bash
# Boot docker container to test with
docker build -t linux-config:test testing
docker run --rm -v ${PWD}:/tmp -ti linux-config:test

