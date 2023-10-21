FROM docker.io/gelbpunkt/python:3.12

WORKDIR /build

ENV CARGO_BUILD_TARGET "x86_64-unknown-linux-musl"
ENV MAKEFLAGS "-j 16"
ENV RUSTFLAGS "-C target-cpu=native -Z mutable-noalias -C target-feature=-crt-static"
ENV CFLAGS "-O3"
ENV CXXFLAGS "-O3"

COPY 0001-Patch-677-ugly.patch /tmp/
COPY 0002-Support-orjson.patch /tmp/
COPY 0001-aiohttp-orjson.patch /tmp/
COPY 0001-3.11-compat.patch /tmp/
COPY 0001-Fix-TLS-in-TLS-warning.patch /tmp/
COPY 0001-Remove-JSON-encoders-and-decoders.patch /tmp/
COPY 0001-Build-optimizations.patch /tmp/
COPY 0001-Fix-compilation-with-latest-cython.patch /tmp/
COPY 0001-Sync-setup.cfg.patch /tmp/
COPY 0001-Add-thread-timeout-for-loop.shutdown_default_executo.patch /tmp/
COPY 0001-aiohttp-4.0-changes.patch /tmp/
COPY aiohttp.txt /tmp/

RUN set -ex && \
    mkdir /wheels && \
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
    git am -3 /tmp/0001-Build-optimizations.patch && \
    maturin build --release --strip --interpreter python3 --manylinux off --features=unstable-simd,yyjson && \
    cp target/wheels/*.whl /wheels && \
    cd .. && \
    git clone https://github.com/amitdev/lru-dict && \
    cd lru-dict && \
    pip wheel . && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/niklasf/python-chess && \
    cd python-chess && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone --single-branch https://github.com/cython/cython && \
    cd cython && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    CYTHON_VERSION=$(pip show cython | grep "Version" | cut -d' ' -f 2) && \
    cd .. && \
    git clone https://github.com/MagicStack/asyncpg && \
    cd asyncpg && \
    git submodule update --init --recursive && \
    sed -i "s:Cython(.*):Cython==$CYTHON_VERSION:g" setup.py pyproject.toml && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/MagicStack/uvloop && \
    cd uvloop && \
    git pull origin pull/507/head --no-edit && \
    git submodule update --init --recursive && \
    sed -i "s:Cython(.*):Cython==$CYTHON_VERSION:g" setup.py pyproject.toml && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/aio-libs/multidict && \
    cd multidict && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/aio-libs/frozenlist && \
    cd frozenlist && \
    echo -e "cython==$CYTHON_VERSION" > requirements/ci.txt && \
    rm pyproject.toml && \
    make cythonize && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/aio-libs/yarl && \
    cd yarl && \
    echo -e "cython==$CYTHON_VERSION" > requirements/cython.txt && \
    rm pyproject.toml && \
    make cythonize && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/aio-libs/aiosignal && \
    cd aiosignal && \
    pip wheel . --no-deps && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/PyYoshi/cChardet && \
    cd cChardet && \
    git submodule update --init --recursive && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/aio-libs/aiohttp && \
    cd aiohttp && \
    git submodule update --init --recursive && \
    make generate-llhttp && \
    git am -3 /tmp/0001-aiohttp-orjson.patch && \
    git am -3 /tmp/0001-Fix-TLS-in-TLS-warning.patch && \
    git am -3 /tmp/0001-Sync-setup.cfg.patch && \
    echo -e "multidict\ncython==$CYTHON_VERSION\ntyping_extensions>=4.1.1" > requirements/cython.txt && \
    sed -i "s:-c requirements/constraints.txt::g" Makefile && \
    make cythonize && \
    pip wheel -r /tmp/aiohttp.txt && \
    python setup.py bdist_wheel && \
    pip install *.whl && \
    pip install dist/*.whl && \
    cp *.whl /wheels && \
    cp dist/*.whl /wheels && \
    TIMEOUT_VERSION=$(pip show async_timeout | grep "Version" | cut -d' ' -f 2) && \
    cd .. && \
    git clone https://github.com/redis/redis-py && \
    cd redis-py && \
    git am -3 /tmp/0001-Remove-JSON-encoders-and-decoders.patch && \
    sed -i "s:async-timeout>=4.0.2:async-timeout==$TIMEOUT_VERSION:g" setup.py && \
    pip wheel .[hiredis] && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/giampaolo/psutil && \
    cd psutil && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/scrapinghub/dateparser && \
    cd dateparser && \
    git pull origin pull/477/merge --no-edit -s recursive -X ours && \
    git am -3 /tmp/0001-Patch-677-ugly.patch && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone --single-branch -b master https://github.com/Gelbpunkt/discord.py && \
    cd discord.py && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cp *.whl /wheels && \
    git reset --hard HEAD~1 && \
    sed -i "s:discord.py:discord.py-custom:g" setup.py && \
    pip wheel . --no-deps && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/aiowiki && \
    cd aiowiki && \
    rm requirements.txt && \
    echo "aiohttp" > requirements.txt && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/getsentry/sentry-python && \
    cd sentry-python && \
    git am -3 /tmp/0002-Support-orjson.patch && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/fantasy-names && \
    cd fantasy-names && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/nir0s/distro && \
    cd distro && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/dabeaz/sly && \
    cd sly && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/jmoiron/humanize && \
    cd humanize && \
    pip wheel . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd .. && \
    git clone https://github.com/aiogram/aiogram && \
    cd aiogram && \
    git am -3 /tmp/0001-aiohttp-4.0-changes.patch && \
    sed -i "s/aiohttp~=3.8.5/aiohttp==4.0.0a2.dev0/g" pyproject.toml && \
    pip wheel --pre --find-links /wheels . && \
    pip install *.whl && \
    cp *.whl /wheels && \
    cd ..
    #cd .. && \
    #git clone https://github.com/Gelbpunkt/zangy && \
    #cd zangy && \
    #CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu maturin build --no-sdist --release --strip --manylinux off --interpreter python3 && \
    #pip install target/wheels/*.whl && \
    #cd .. && \
    #git clone https://github.com/daggy1234/polaroid && \
    #cd polaroid && \
    #maturin build --no-sdist --release --strip --manylinux off --interpreter python3 && \
    #pip install target/wheels/*.whl && \
    #cd ..

CMD sleep 20
