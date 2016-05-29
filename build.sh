#!/bin/sh

set -e

AC_VERSION=2.4.1
DACT_VERSION=2.4.1
APP=Dact
APPDIR=$PWD/${APP}.AppDir

# alpinocorpus
sudo apt-get install libxml2-dev libxslt1-dev libboost-all-dev

# dact
sudo apt-get install qttools5-dev-tools qtbase5-dev

if [ ! -d AppImageKit ] ; then
  git clone https://github.com/probonopd/AppImageKit.git
  (
    cd AppImageKit
    cmake .
    make
  )
fi

if [ ! -d ${APPDIR} ] ; then
  mkdir -p ${APPDIR}/usr
fi

PREFIX=${APPDIR}/usr

if [ ! -d dbxml ] ; then
  git clone https://github.com/rug-compling/dbxml.git
  (
    cd dbxml
    ./buildall.sh --prefix=${PREFIX}
  )
fi

if [ ! -d alpinocorpus ] ; then
	git clone https://github.com/rug-compling/alpinocorpus.git
	(
		cd alpinocorpus
		git checkout ${AC_VERSION}
		mkdir build
		cd build
		cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DUSE_REMOTE_CORPUS:BOOL=OFF ..
	)
fi

(
  cd alpinocorpus/build
  make install -j5
)

if [ ! -d dact ] ; then
	git clone https://github.com/rug-compling/dact.git
	(
		cd dact
		git checkout ${DACT_VERSION}
		mkdir build
		cd build
		cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DUSE_REMOTE_CORPUS:BOOL=OFF ..
	)
fi

(
  cd dact/build
  make install -j5
)

cp -r /usr/lib/x86_64-linux-gnu/qt5/plugins/* ${PREFIX}/bin

lddtree -l ${PREFIX}/bin/dact | egrep -v "${PREFIX}|lib[Xx]|drm|mesa|glapi|libgcc|libc\.so|librt|libpthread|libdl|libm\.so|libz\.so" | xargs cp -t $PREFIX/lib
lddtree -l ${PREFIX}/bin/platforms/libqxcb.so | egrep -v "${PREFIX}|lib[Xx]|drm|mesa|glapi|libgcc|libc\.so|librt|libpthread|libdl|libm\.so|libz\.so" | xargs cp -t $PREFIX/lib

cp dact.desktop ${APPDIR}
cp dact/resources/dact-espresso.png dact/resources/dact-espresso.svg ${APPDIR}

cp AppImageKit/AppRun ${APPDIR}
chmod a+x AppImageKit/AppRun

AppImageKit/AppImageAssistant ${APPDIR} Dact

