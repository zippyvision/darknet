# https://www.learnopencv.com/install-opencv3-on-ubuntu/

# FROM ubuntu:18.04
# FROM nvidia/cuda:10.2-cudnn7-runtime-ubuntu18.04
FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

# FROM nvidia/cuda:10.2-base

ARG PYTHON_VERSION=3.8
ARG OPENCV_VERSION=4.2.0
ARG PYBIND_VERSION=v.2.4.3

# Install all dependencies for OpenCV
RUN apt-get -y update -qq --fix-missing && \
    apt-get -y install --no-install-recommends \
    nano \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    $( [ ${PYTHON_VERSION%%.*} -ge 3 ] && echo "python${PYTHON_VERSION%%.*}-distutils" ) \
    wget \
    unzip \
    cmake \
    libtbb2 \
    gfortran \
    apt-utils \
    pkg-config \
    checkinstall \
    build-essential \
    libatlas-base-dev \
    libgtk2.0-dev \
    libavcodec57 \
    libavcodec-dev \
    libavformat57 \
    libavformat-dev \
    libavutil-dev \
    libswscale4 \
    libswscale-dev \
    libjpeg8-dev \
    libpng-dev \
    libtiff5-dev \
    libdc1394-22 \
    libdc1394-22-dev \
    libxine2-dev \
    libv4l-dev \
    libgstreamer1.0 \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    libglew-dev \
    libpostproc-dev \
    libeigen3-dev \
    libtbb-dev \
    zlib1g-dev \
    libsm6 \
    curl \
    libxext6 \
    libxrender1 \
    libssl-dev

# install python dependencies
RUN    sysctl -w net.ipv4.ip_forward=1 && \
    wget https://bootstrap.pypa.io/get-pip.py --progress=bar:force:noscroll --no-check-certificate && \
    python${PYTHON_VERSION} get-pip.py && \
    rm get-pip.py && \
    pip${PYTHON_VERSION} install numpy

# Install OpenCV
RUN    wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip --progress=bar:force:noscroll --no-check-certificate && \
    unzip -q opencv.zip && \
    mv /opencv-${OPENCV_VERSION} /opencv && \
    rm opencv.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib.zip --progress=bar:force:noscroll --no-check-certificate && \
    unzip -q opencv_contrib.zip && \
    mv /opencv_contrib-${OPENCV_VERSION} /opencv_contrib && \
    rm opencv_contrib.zip

# Prepare build
RUN    mkdir /opencv/build && \
    cd /opencv/build && \
    cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_PYTHON_SUPPORT=ON \
    -D BUILD_DOCS=ON \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -D BUILD_opencv_python3=$( [ ${PYTHON_VERSION%%.*} -ge 3 ] && echo "ON" || echo "OFF" ) \
    -D PYTHON${PYTHON_VERSION%%.*}_EXECUTABLE=$(which python${PYTHON_VERSION}) \
    -D PYTHON_DEFAULT_EXECUTABLE=$(which python${PYTHON_VERSION}) \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_IPP=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_GSTREAMER=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D WITH_V4L=ON \
    -D WITH_LIBV4L=ON \
    -D WITH_TBB=ON \
    -D WITH_OPENGL=ON \
    -D ENABLE_PRECOMPILED_HEADERS=OFF \
    .. &&\
    cd /opencv/build && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Set the default python and install PIP packages
RUN update-alternatives --install /usr/bin/python${PYTHON_VERSION%%.*} python${PYTHON_VERSION%%.*} /usr/bin/python${PYTHON_VERSION} 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1

RUN pip install pytest
# Remove cmake there is one installed
RUN apt-get -y purge cmake

# install latest version of the cmake
RUN mkdir /tempx &&\
    cd /tempx &&\
    wget https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz --progress=bar:force:noscroll --no-check-certificate &&\
    tar -xzvf cmake-3.17.0.tar.gz && \
    cd cmake-3.17.0 && \
    ./bootstrap &&\
    make -j4 &&\
    make install &&\
    cd / &&\
    rm -rf /tempx



# # Call default command.
# RUN python --version && \
#     python -c "import cv2 ; print(cv2.__version__)"

COPY . /app



