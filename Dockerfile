FROM python:3.8.0b4-alpine3.10

WORKDIR /build

RUN apk add --no-cache --virtual .build-deps git gcc  musl-dev linux-headers make automake libtool m4 autoconf && \
    git clone https://github.com/cython/cython && \
    cd cython && \
    pip wheel . && \
    pip install Cython-3.0a0-cp38-cp38-linux_x86_64.whl && \
    cd .. && \
    git clone https://github.com/MagicStack/asyncpg && \
    cd asyncpg && \
    git submodule update --init --recursive && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/MagicStack/uvloop && \
    cd uvloop && \
    git submodule update --init --recursive && \
    pip wheel . && \
    cd ..

# allow for build caching
RUN mkdir /wheels && \
    find . -name \*.whl -exec cp {} /wheels \;

CMD sleep 20
