#!/bin/bash

cd ${WORKING_DIR}/kaldi/tools

# tools directory --> we'll only compile OpenFST
OPENFST_VERSION=$(grep -oP "OPENFST_VERSION *\?= *\K(.*)$" ${WORKING_DIR}/kaldi/tools/Makefile)
wget -T 10 -t 1 http://openfst.cs.nyu.edu/twiki/pub/FST/FstDownload/openfst-${OPENFST_VERSION}.tar.gz
tar -zxvf openfst-${OPENFST_VERSION}.tar.gz
cd openfst-${OPENFST_VERSION}/
CXX=clang++ ./configure --prefix=`pwd` --enable-static --enable-shared --enable-far --enable-ngram-fsts --host=arm-linux-androideabi LIBS="-ldl"
make -j 4
make install

# source directory
cd ..
ln -s openfst-${OPENFST_VERSION} openfst
cd ../src
CXX=clang++ ./configure --static --android-incdir=${ANDROID_TOOLCHAIN_PATH}/sysroot/usr/include/ --host=arm-linux-androideabi --openblas-root=${WORKING_DIR}/OpenBLAS/install
sed -i 's/-g # -O0 -DKALDI_PARANOID/-O3 -DNDEBUG/g' kaldi.mk
make clean -j
make depend -j
make -j 4
