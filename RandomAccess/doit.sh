#!/bin/bash

for ((i=0;i<10;i++)); do ./linux.sh; done
for ((i=0;i<10;i++)); do ./docker.sh; done
for ((i=0;i<10;i++)); do ./vm.sh; done
