#!/bin/bash
set -e
current_dir=$(dirname $0)
the_test=$1
cp -av ${current_dir}/../kiosk-scripts/${the_test}.sh ${current_dir}/install-test.sh
docker build ${current_dir} -f ${current_dir}/${the_test}-test.dockerfile -t ${the_test}-test
docker rm last-kiosk-${the_test}-test
docker run -it --name last-kiosk-${the_test}-test ${the_test}-test ${the_test}-test 
docker commit last-kiosk-${the_test}-test last-kiosk-${the_test}-test
docker run -it --entrypoint bash last-kiosk-${the_test}-test