#!/bin/bash

acrPrefix=$1
imageName="api"
imageTag="0.0.1"

docker build ./src -t $acrPrefix.azurecr.io/$imageName:$imageTag

