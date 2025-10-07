#!/bin/bash

set -e # exit once any command fails

{
    docker --version | grep "Docker version"
    java --version | grep "openjdk version"
    jenkins --version 
} 

echo "done" # let Validator know success
