FROM gelbpunkt/python:gcc10

WORKDIR /build

RUN apk upgrade --no-cache && \
    apk add --no-cache --virtual .build-deps git gcc g++ musl-dev linux-headers make automake libtool m4 autoconf curl && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.11/main libffi-dev && \
    git config --global user.name "Jens Reidel" && \
    git config --global user.email "jens@troet.org" && \
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
    git clone https://github.com/aaugustin/websockets && \
    cd websockets && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/cython/cython && \
    cd cython && \
    git checkout release && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/MagicStack/asyncpg && \
    cd asyncpg && \
    git submodule update --init --recursive && \
    sed -i "s:0.29.14:0.29.16:g" setup.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/MagicStack/uvloop && \
    cd uvloop && \
    git submodule update --init --recursive && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/aiohttp && \
    cd aiohttp && \
    git submodule update --init --recursive && \
    echo "cython==0.29.16" > requirements/cython.txt && \
    make cythonize && \
    pip wheel .[speedups] && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/aio-libs/aioredis && \
    cd aioredis && \
    pip wheel . && \
    pip install *.whl && \
    git clone https://github.com/giampaolo/psutil && \
    cd psutil && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/scrapinghub/dateparser && \
    cd dateparser && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/Rapptz/discord.py && \
    cd discord.py && \
    git checkout sharding-rework && \
    git pull origin pull/1849/merge --no-edit && \
    git pull origin pull/1497/merge --no-edit && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/PythonistaGuild/Wavelink && \
    cd Wavelink && \
    sed -i 's/aiohttp.ClientSession(loop=self.loop)/aiohttp.ClientSession()/' wavelink/client.py && \
    sed -i '85d' wavelink/websocket.py && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/aiowiki && \
    cd aiowiki && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
    cd .. && \
    git clone https://github.com/getsentry/raven-python && \
    cd raven-python && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/Diniboy1123/raven-aiohttp && \
    cd raven-aiohttp && \
    pip wheel . --no-deps && \
    pip install --no-deps *.whl && \
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
    git clone https://github.com/dabeaz/ply && \
    cd ply && \
    echo -e "from distutils.core import setup\nfrom Cython.Build import cythonize\nsetup(name=\"ply\", ext_modules=cythonize('ply/*.py'))" > setup.py && \
    sed -i 's/f = sys._getframe(levels)/f = sys._getframe()/' ply/lex.py && \
    sed -i 's/f = sys._getframe(levels)/f = sys._getframe()/' ply/yacc.py && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/jmoiron/humanize && \
    cd humanize && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/hellysmile/contextvars_executor && \
    cd contextvars_executor && \
    pip wheel . && \
    pip install *.whl && \
    cd .. && \
    git clone https://github.com/Gelbpunkt/duckpy && \
    cd duckpy && \
    pip wheel . --no-deps && \
    pip install *.whl --no-deps && \
    cd .. && \
    apk del .build-deps

# allow for build caching
RUN mkdir /wheels && \
    find . -name \*.whl -exec cp {} /wheels \;

CMD sleep 20
