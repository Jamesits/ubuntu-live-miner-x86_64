#!/bin/bash
set -euv

apt-get -y install cmake build-essential libmicrohttpd-dev libssl-dev libhwloc-dev
cd /tmp
git clone https://github.com/fireice-uk/xmr-stak.git
cd xmr-stak
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DMICROHTTPD_ENABLE=ON -DOpenSSL_ENABLE=ON -DCPU_ENABLE=ON -DHWLOC_ENABLE=ON -DOpenCL_ENABLE=OFF -DCUDA_ENABLE=OFF
make

# get binaries from /tmp/xmr-stak/build/bin
