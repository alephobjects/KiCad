#!/usr/bin/env bash

#############################
# CONFIGURATION
#############################

BUILD_TARGET=${1:-none}

## Do we want to create a final archive
ARCHIVE_FOR_DISTRIBUTION=1

#############################
# Actual build script
#############################

if [ "$BUILD_TARGET" = "none" ]; then
	echo "You need to specify a build target with:"
	echo "$0 debian_i386"
	echo "$0 debian_amd64"
	exit 0
fi

MAKE=make

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

TAR=tar

KICAD_MAJOR_VERSION=`grep "set(PACKAGE_VERSION_MAJOR" ../CMakeLists.txt | cut -d \" -f 2`
KICAD_MINOR_VERSION=`grep "set(PACKAGE_VERSION_MINOR" ../CMakeLists.txt | cut -d \" -f 2`
# FREECAD_PATCH_VERSION=`grep "set(PACKAGE_VERSION_PATCH" ../CMakeLists.txt | cut -d \" -f 2`

# Actually for PATCH version the following is implemented:
KICAD_PATCH_VERSION=`git rev-list HEAD | wc -l | sed -e 's/ *//g' | xargs -n1 printf %04d`

FULL_VERSION=${KICAD_MAJOR_VERSION}.${KICAD_MINOR_VERSION}.${KICAD_PATCH_VERSION}

echo "Trying to build KiCAD $FULL_VERSION "
echo $FULL_VERSION > BUILD_VERSION

#############################
# Debian 32bit .deb
#############################
if [[ "$BUILD_TARGET" = "debian_i386" || "$BUILD_TARGET" = "debian_amd64" ]]; then
	BUILD_DIR="$SCRIPT_DIR/build"
	TARGET_DIR="$SCRIPT_DIR/target"
	BUILD_ARCH="Unknown"
	if [ "$BUILD_TARGET" = "debian_i386" ]; then
		BUILD_ARCH="i386"
	else
		BUILD_ARCH="amd64"
	fi

	echo "Building KiCAD in $BUILD_DIR"
#	rm -Rf $BUILD_DIR
	mkdir -p $BUILD_DIR

	cd $BUILD_DIR
# -DKICAD_SCRIPTING_WXPYTHON=ON  <-- Turn this off for now.
	cmake 	-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_GITHUB_PLUGIN=ON \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DKICAD_BIN=/usr/bin \
		-DKICAD_DATA=/usr/share/kicad \
		-DKICAD_DEMOS=/usr/share/kicad/demos \
		-DKICAD_DOCS=/usr/share/doc/kicad \
		-DKICAD_PLUGINS=/usr/share/kicad/plugins \
		-DKICAD_TEMPLATE=/usr/share/kicad/template \
		-DKICAD_REPO_NAME=deb \
		-DCMAKE_INSTALL_DOCDIR=/usr/doc \
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include/kicad \
		-DKICAD_SCRIPTING=ON \
		-DKICAD_SCRIPTING_MODULES=ON \
		-DKICAD_SCRIPTING_WXPYTHON=OFF \
		 ../..
	if [ $? != 0 ]; then echo "Failed to configure KiCAD"; exit 1; fi
	$MAKE -j3
	if [ $? != 0 ]; then echo "Failed to Make KiCAD"; exit 1; fi

	echo "Installing KiCAD to  $TARGET_DIR"
	rm -Rf $TARGET_DIR
	mkdir -p $TARGET_DIR
# Installing
	$MAKE DESTDIR=$TARGET_DIR install
	if [ $? != 0 ]; then echo "Failed to Install KiCAD"; exit 1; fi
	cd $SCRIPT_DIR
# Additional Debian-specific stuff: share directory
#	mkdir -p ${TARGET_DIR}/usr
#	mkdir -p ${TARGET_DIR}/usr/share
	
#	mkdir -p ${TARGET_DIR}/usr/share/applications
#	cp debian/kicad.desktop  ${TARGET_DIR}/usr/share/applications/

#	mkdir -p ${TARGET_DIR}/usr/share/kicad
#	ln -s ../../lib/kicad/Mod ${TARGET_DIR}/usr/share/kicad/Mod
#	cp ${TARGET_DIR}/usr/lib/kicad/data/kicad.xpm ${TARGET_DIR}/usr/share/kicad/kicad.xpm
#	ln -s ../../lib/kicad/data/kicad.xpm ${TARGET_DIR}/usr/share/kicad/kicad.xpm

# Let's Remove bulcu doc directory for now
#	rm -rf  ${TARGET_DIR}/usr/doc
	
# Debian package directory should reside inside the target directory
	mkdir -p ${TARGET_DIR}/DEBIAN
	cat debian/control | sed "s/\[BUILD_VERSION\]/${FULL_VERSION}/" | sed "s/\[ARCH\]/${BUILD_ARCH}/" > ${TARGET_DIR}/DEBIAN/control
	cp debian/postinst ${TARGET_DIR}/DEBIAN/postinst
	cp debian/postrm ${TARGET_DIR}/DEBIAN/postrm
	cp debian/prerm ${TARGET_DIR}/DEBIAN/prerm
# Now that the directory structure is ready, let's build a package
#	rm -Rf ${SCRIPT_DIR}/freecad_*.deb
# Let's delete the old builds:
	fakeroot sh -ec "
		chown root:root ${TARGET_DIR} -R
		chmod u+w,a+rX,go-w ${TARGET_DIR} -R
		chmod a+x ${TARGET_DIR}/DEBIAN -R
		dpkg-deb -Zgzip --build ${TARGET_DIR} ${SCRIPT_DIR}/kicad_${FULL_VERSION}_${BUILD_ARCH}.deb
		chown `id -un`:`id -gn` ${TARGET_DIR} -R
	"

	exit
fi
