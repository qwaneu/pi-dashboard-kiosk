#!/bin/bash
set -e
current_dir=$(dirname $0)
cp -av ${current_dir}/../kiosk-scripts/install.sh ${current_dir}/install-kiosk.sh
docker build ${current_dir} -t kiosk-test
docker run --rm -it kiosk-test
