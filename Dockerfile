FROM ubuntu:16.04

RUN mkdir -p /opt/android-sdk-linux && mkdir -p ~/.android && touch ~/.android/repositories.cfg

ENV WORKING_DIR /opt

ENV ANDROID_NDK_HOME ${WORKING_DIR}/android-ndk-linux
ENV ANDROID_TOOLCHAIN_PATH /tmp/my-android-toolchain
ENV PATH ${ANDROID_TOOLCHAIN_PATH}/bin:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}:${ANDROID_HOME}/tools:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    file \
    gfortran \
    git \
    python \
    unzip \
    wget && \
    apt-get clean autoclean && \
    apt-get autoremove -y

##### Install Android toolchain
RUN cd ${WORKING_DIR} && \
    wget -q --output-document=android-ndk.zip https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip && \
	unzip android-ndk.zip && \
	rm -f android-ndk.zip && \
	mv android-ndk-r14b ${ANDROID_NDK_HOME}

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
