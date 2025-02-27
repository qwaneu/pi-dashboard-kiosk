#!/bin/bash
set -e
retain_container=false
current_dir=$(dirname $0)
while [[ "$1" =~ "-" ]]; do
    case "$1" in
        --retain | -r) retain_container=true; shift;;
    esac
done

the_test=${1:-install}
cp -av ${current_dir}/../kiosk-scripts/${the_test}.sh ${current_dir}/install-test.sh
docker build ${current_dir} -f ${current_dir}/${the_test}-test.dockerfile -t ${the_test}-test
docker run -it --name last-kiosk-${the_test}-test ${the_test}-test ${the_test}-test 
if [[ retain_container ]]; then
    docker commit last-kiosk-${the_test}-test last-kiosk-${the_test}-test
    docker run -it --entrypoint bash last-kiosk-${the_test}-test
fi
docker rm last-kiosk-${the_test}-test
