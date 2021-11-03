FROM docker.io/gelbpunkt/python:3.11

WORKDIR /build

ENV MAKEFLAGS "-j 16"
ENV RUSTFLAGS "-C target-cpu=native -Z mutable-noalias -C target-feature=-crt-static -Z mir-opt-level=3 -Z unsound-mir-opts"
ENV CFLAGS "-O3"
ENV CXXFLAGS "-O3"

COPY 0001-Patch-677-ugly.patch /tmp/
COPY 0002-Support-orjson.patch /tmp/
COPY 0001-Support-relative-date-floats.patch /tmp/
COPY 0001-Fix-aiohttp-4-compat.patch /tmp/
COPY 0001-aiohttp-orjson.patch /tmp/
COPY 0001-Fix-unknown-events.patch /tmp/
COPY aiohttp.txt /tmp/

RUN set -ex && \
    apk upgrade --no-cache && \
    apk add --no-cache --virtual .build-deps git gcc libgcc g++ musl-dev linux-headers make automake libtool m4 autoconf curl libffi-dev openssl-dev nodejs-current npm && \
    git config --global pull.rebase false && \
    curl -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile minimal --component rust-src -y && source $HOME/.cargo/env; \
    pip install -U pip wheel && \
    pip install "maturin>=0.12.0-beta.2" typing_extensions && \
    git config --global user.name "Jens Reidel" && \
    git config --global user.email "jens@troet.org" && \
    pip download tomli && \
    git clone https://github.com/ijl/orjson && \
    cd orjson && \
    rm Cargo.lock && \
    maturin build --no-sdist --release --strip --interpreter python3 --manylinux off && \
    cd .. && \
    git clone https://github.com/amitdev/lru-dict && \
    cd lru-dict && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/astanin/python-tabulate && \
    cd python-tabulate && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/iomintz/import-expression-parser && \
    cd import-expression-parser && \
    pip wheel . && \
    cd .. && \
    git clone https://github.com/niklasf/python-chess && \
    cd python-chess && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/cython/cython && \
    cd cython && \
    pip wheel . && \
    pip install *.whl && \
    CYTHON_VERSION=$(pip show cython | grep "Version" | cut -d' ' -f 2) && \
    cd .. && \
    git clone https://github.com/MagicStack/asyncpg && \
    cd asyncpg && \
    git submodule update --init --recursive && \
    sed -i "s:Cython(.*):Cython==$CYTHON_VERSION:g" setup.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/MagicStack/uvloop && \
    cd uvloop && \
    git submodule update --init --recursive && \
    git pull origin pull/445/merge --no-edit && \
    sed -i "s:Cython(.*):Cython==$CYTHON_VERSION:g" setup.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/multidict && \
    cd multidict && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/frozenlist && \
    cd frozenlist && \
    echo -e "cython==$CYTHON_VERSION" > requirements/cython.txt && \
    make cythonize && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/yarl && \
    cd yarl && \
    echo -e "cython==$CYTHON_VERSION" > requirements/cython.txt && \
    make cythonize && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/aiosignal && \
    cd aiosignal && \
    pip wheel . --no-deps && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/aiohttp && \
    cd aiohttp && \
    git submodule update --init --recursive && \
    make generate-llhttp && \
    git am -3 /tmp/0001-aiohttp-orjson.patch && \
    echo -e "multidict\ncython==$CYTHON_VERSION\ntyping_extensions==3.7.4.3" > requirements/cython.txt && \
    make cythonize && \
    pip wheel -r /tmp/aiohttp.txt && \
    python setup.py bdist_wheel && \
    pip install *.whl && \
    pip install dist/*.whl && \
    TIMEOUT_VERSION=$(pip show async_timeout | grep "Version" | cut -d' ' -f 2) && \
    cd .. && \
    git clone https://github.com/aio-libs/aioredis-py && \
    cd aioredis-py && \
    sed -i "s:async-timeout:async-timeout==$TIMEOUT_VERSION:g" setup.py && \
    pip wheel .[hiredis] && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/giampaolo/psutil && \
    cd psutil && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/scrapinghub/dateparser && \
    cd dateparser && \
    git am -3 /tmp/0001-Support-relative-date-floats.patch && \
    git pull origin pull/562/merge --no-edit && \
    git pull origin pull/477/merge --no-edit -s recursive -X ours && \
    git am -3 /tmp/0001-Patch-677-ugly.patch && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone --single-branch -b master https://github.com/Gelbpunkt/discord.py && \
    cd discord.py && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/Rapptz/discord-ext-menus && \
    cd discord-ext-menus && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/PythonistaGuild/Wavelink && \
    cd Wavelink && \
    git am -3 /tmp/0001-Fix-aiohttp-4-compat.patch && \
    git am -3 /tmp/0001-Fix-unknown-events.patch && \
    rm requirements.txt && \
    echo -e "aiohttp==4.0.0a1\ndiscord.py>=1.3.4" > requirements.txt && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/aiowiki && \
    cd aiowiki && \
    rm requirements.txt && \
    echo "aiohttp==4.0.0a1" > requirements.txt && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/getsentry/sentry-python && \
    cd sentry-python && \
    git am -3 /tmp/0002-Support-orjson.patch && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://git.travitia.xyz/Adrian/fantasy-names && \
    cd fantasy-names && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/nir0s/distro && \
    cd distro && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/dabeaz/sly && \
    cd sly && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/jmoiron/humanize && \
    cd humanize && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/aioscheduler && \
    cd aioscheduler && \
    pip wheel . && \                                                                               
    pip install *.whl && \      
    cd .. && \
    git clone https://github.com/aio-libs/aiohttp-session && \
    cd aiohttp-session && \
    pip wheel . --no-deps && \
    pip install *.whl --no-deps && \
    cd .. && \
    git clone https://github.com/aio-libs/aiohttp-jinja2 && \
    cd aiohttp-jinja2 && \
    pip wheel . --no-deps && \
    pip install *.whl --no-deps && \
    cd .. && \
    git clone https://github.com/pallets/jinja && \
    cd jinja && \
    pip wheel . && \    
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/pyca/cryptography && \
    cd cryptography && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/Devoxin/Lavalink.py && \
    cd Lavalink.py && \
    git checkout dev && \
    pip wheel . --no-deps && \
    pip install *.whl --no-deps && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/zangy && \
    cd zangy && \
    CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu maturin build --no-sdist --release --strip --manylinux off --interpreter python3 && \
    pip install target/wheels/*.whl && \
    cd .. && \
    git clone https://github.com/daggy1234/polaroid && \
    cd polaroid && \
    maturin build --no-sdist --release --strip --manylinux off --interpreter python3 && \
    pip install target/wheels/*.whl && \
    cd ..

# allow for build caching
RUN mkdir /wheels && \
    find . -name \*.whl -exec cp {} /wheels \;

CMD sleep 20
