#!/bin/sh

########################################
## CONFIG
REDISVER=2.8.13
########################################


## =====================================
BASEDIR=$(pwd)
MACHINE=$(uname -m)-$(uname -s)

SRCDIR=${BASEDIR}/SOURCE
mkdir -p ${SRCDIR}


## =====================================
## Build Redis
cd ${SRCDIR}
REDISSRC0="redis-${REDISVER}"
REDISSRC="redis-${REDISVER}-${MACHINE}"

if [ -x ${REDISSRC}/src/redis-server ]; then
  echo "[DBG] The redis-server (version:${REDISVER}, platform:${MACHINE}) is already built. Nice!"
else
  REDISPKG="${REDISSRC0}.tar.gz"
  [ ! -f ${REDISPKG} ] && wget http://download.redis.io/releases/${REDISPKG}
  rm -rf ${REDISSRC0}
  tar -xzf ${REDISPKG}

  rm -rf ${REDISSRC}
  mv ${REDISSRC0} ${REDISSRC}

  cd ${REDISSRC}
  make
  make test
fi
cd ${BASEDIR}

## =====================================
## Prepare run directory
RUNDIR=/tmp/${USER}/redis
echo "[DBG] Preparing home directory: ${RUNDIR}"
mkdir -p ${RUNDIR}
rm -f run
ln -s ${RUNDIR} ${BASEDIR}/run
cd ${RUNDIR}
cp -p ${SRCDIR}/${REDISSRC}/redis.conf .
cp -p ${SRCDIR}/${REDISSRC}/src/redis-server .
cp -p ${SRCDIR}/${REDISSRC}/src/redis-cli .
cp -p ${SRCDIR}/${REDISSRC}/src/redis-benchmark .

## =====================================
echo "[DBG] Done"
cd ${BASEDIR}
