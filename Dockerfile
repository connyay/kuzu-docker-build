FROM centos:7.9.2009 AS toolchain

RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo \
    && sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo \
    && sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo

RUN yum install -y gcc gcc-c++ make automake curl wget gzip zip bzip2 file texinfo \
    python3 python3-devel python3-pip \
    @development zlib-devel bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils && \
    yum clean metadata

RUN wget https://ftp.gnu.org/gnu/gcc/gcc-11.5.0/gcc-11.5.0.tar.xz && \
    tar -xf gcc-11.5.0.tar.xz && \
    cd gcc-11.5.0 && \
    ./contrib/download_prerequisites && \
    ./configure --enable-languages=c,c++ --prefix=/usr/local/lib/gcc-11.5.0 --disable-bootstrap --disable-multilib && \
    make && \
    make install

RUN wget https://www.python.org/ftp/python/3.9.21/Python-3.9.21.tgz && \
    tar xzf Python-3.9.21.tgz && \
    cd Python-3.9.21 && ./configure --prefix=/usr --enable-loadable-sqlite-extensions -enable-optimizations && \
    make altinstall

RUN mkdir -p /opt/cmake && cd /opt/cmake && \
    curl -s -k https://cmake.org/files/v3.31/cmake-3.31.3-linux-$(uname -m).tar.gz | tar -xzf - --strip-components=1 && \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake

FROM toolchain

WORKDIR /root/code/kuzudb

RUN git clone --depth 1 --branch v0.7.1 https://github.com/kuzudb/kuzu.git

WORKDIR /root/code/kuzudb/kuzu

RUN PATH=/usr/local/lib/gcc-11.5.0/bin:$PATH make release install

RUN mv install/include/kuzu.h . && \
    mv install/include/kuzu.hpp . && \
    mv install/lib64/libkuzu.so .

CMD [ "sh", "-c", "mkdir -p /out && tar -czvf /out/libkuzu-linux-$(uname -m).tar.gz kuzu.h kuzu.hpp libkuzu.so" ]
