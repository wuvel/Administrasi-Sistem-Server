#!/bin/bash

name=`docker ps -a | awk '{print $NF}'`
sliced=${name##*S}
sliced=${sliced//$'\n'/}
echo "$sliced"