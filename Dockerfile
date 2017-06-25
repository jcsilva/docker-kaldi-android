FROM snowdream/android-ndk:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    file \
    gfortran && \
    apt-get clean autoclean && \
    apt-get autoremove -y

ENV WORKING_DIR /opt

##### Install Android toolchain
ENV ANDROID_TOOLCHAIN_PATH /tmp/my-android-toolchain
ENV PATH ${ANDROID_TOOLCHAIN_PATH}/bin:${PATH}

# ANDROID_NDK_HOME is defined in snowdream/android-ndk
RUN ${ANDROID_NDK_HOME}/build/tools/make_standalone_toolchain.py --arch arm --api 21 --stl=libc++ --install-dir ${ANDROID_TOOLCHAIN_PATH}

##### Download, compile and install OpenBlas
RUN cd ${WORKING_DIR} && \
    git clone https://github.com/xianyi/OpenBLAS && \
    cd OpenBLAS && \
    make TARGET=ARMV7 HOSTCC=gcc CC=arm-linux-androideabi-gcc NO_SHARED=1 NOFORTRAN=1 NUM_THREADS=32 libs && \
    make install NO_SHARED=1 PREFIX=`pwd`/install

##### Download, compile and install CLAPACK
RUN cd ${WORKING_DIR} && \
    git clone https://github.com/simonlynen/android_libs && \
    cd android_libs/lapack && \
    sed -i 's/-mfloat-abi=softfp/-mfloat-abi=hard/g' jni/Application.mk && \
    sed -i 's/LOCAL_MODULE:= testlapack/#LOCAL_MODULE:= testlapack/g' jni/Android.mk && \
    sed -i 's/LOCAL_SRC_FILES:= testclapack.cpp/#LOCAL_SRC_FILES:= testclapack.cpp/g' jni/Android.mk && \
    sed -i 's/LOCAL_STATIC_LIBRARIES := lapack/#LOCAL_STATIC_LIBRARIES := lapack/g' jni/Android.mk && \
    sed -i 's/include $(BUILD_SHARED_LIBRARY)/#include $(BUILD_SHARED_LIBRARY)/g' jni/Android.mk && \
    ${ANDROID_NDK_HOME}/ndk-build && \
    cp obj/local/armeabi-v7a/*.a ${WORKING_DIR}/OpenBLAS/install/lib

##### Compile kaldi
# Using "/opt" because of a bug in Docker:
# https://github.com/docker/docker/issues/25925
COPY ./compile-kaldi.sh /opt

RUN chmod +x /opt/compile-kaldi.sh

ENTRYPOINT ["./opt/compile-kaldi.sh"]
