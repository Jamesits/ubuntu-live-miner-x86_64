#!/bin/bash
set -euv

# run as root

# install build dependencies
apt-get -y install git-core cmake build-essential libmicrohttpd-dev libssl-dev libhwloc-dev

# get source code
cd /tmp
git clone https://github.com/fireice-uk/xmr-stak.git

# remove donation
cd xmr-stak
sed -ie "s/2\.0/0\.0/g" xmrstak/donate-level.hpp

# build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DMICROHTTPD_ENABLE=ON -DOpenSSL_ENABLE=ON -DCPU_ENABLE=ON -DHWLOC_ENABLE=ON -DOpenCL_ENABLE=OFF -DCUDA_ENABLE=OFF
make

# get binaries from /tmp/xmr-stak/build/bin
cd bin
install xmr-stak libxmr-stak*.a /usr/local/bin
