FROM centos:7.9.2009

ARG GCC_INSTALL_HOME=/opt/rh/gcc-toolset-10/root/usr
ARG GCC_10_DOWNLOAD_URL=https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.gz
ARG GCC_DOWNLOAD_URL=https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz
ARG CMAKE_INSTALL_HOME=/opt/cmake

ADD yum-mirrorlist /etc/yum-mirrorlist/
RUN rm -f /etc/yum.repos.d/CentOS-*.repo && ln -s /etc/yum-mirrorlist/$(arch)/CentOS-Base-Local-List.repo /etc/yum.repos.d/CentOS-Base-Local-List.repo
RUN yum install -y gcc gcc-c++ make automake curl wget gzip gunzip zip bzip2 file texinfo \
    python3 python3-devel python3-pip \
    @development zlib-devel bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils && \
    yum clean metadata

RUN wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz && \
    tar xzf Python-3.9.7.tgz && \
    cd Python-3.9.7 && ./configure --prefix=/usr --enable-loadable-sqlite-extensions -enable-optimizations && \
    make altinstall

# build gcc-10
RUN mkdir -p /workspace/gcc-10 && \
    cd /workspace/gcc-10 &&    \
    wget --progress=dot:mega --no-check-certificate $GCC_10_DOWNLOAD_URL -O ../gcc-10.tar.gz && \
    tar -xzf ../gcc-10.tar.gz --strip-components=1 && \
    ./contrib/download_prerequisites && \
    ./configure --disable-multilib --enable-languages=c,c++ --prefix=/workspace/gcc-10/install
RUN cd /workspace/gcc-10 && make -j`nproc` && make install
# build gcc-14
RUN mkdir -p /workspace/gcc && export CC=/workspace/gcc-10/install/bin/gcc && export CXX=/workspace/gcc-10/install/bin/g++ && \
    cd /workspace/gcc &&    \
    wget --progress=dot:mega --no-check-certificate $GCC_DOWNLOAD_URL -O ../gcc.tar.gz && \
    tar -xzf ../gcc.tar.gz --strip-components=1 && \
    ./contrib/download_prerequisites && \
    ./configure --disable-multilib --enable-languages=c,c++ --prefix=${GCC_INSTALL_HOME}
RUN cd /workspace/gcc && make -j`nproc`
RUN cd /workspace/gcc && mkdir -p /workspace/installed && make DESTDIR=/workspace/installed install && \
    strip /workspace/installed/${GCC_INSTALL_HOME}/bin/* /workspace/installed/${GCC_INSTALL_HOME}/libexec/gcc/*/*/{cc1,cc1plus,collect2,lto1}

RUN ARCH=`uname -m` && mkdir -p $CMAKE_INSTALL_HOME && cd $CMAKE_INSTALL_HOME && \
    curl -s -k https://cmake.org/files/v3.22/cmake-3.22.4-linux-${ARCH}.tar.gz | tar -xzf - --strip-components=1 && \
    ln -s $CMAKE_INSTALL_HOME/bin/cmake /usr/bin/cmake
