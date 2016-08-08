#!/bin/bash

DATE=`date "+%Y-%m%-%d"`


PROJECT_DIR="fscript-CLI"

INSTALLER_DIR="Installer"
INSTALLER_FILES_DIR=$INSTALLER_DIR/Files
BIN_DIR=$INSTALLER_FILES_DIR/usr/bin
MAN_DIR=$INSTALLER_FILES_DIR/usr/share/man/man1

INSTALLER_PROJECT=$INSTALLER_DIR/fscript.pmproj
INSTALLER_IMAGE_DIR="fscript CLI Installer"

MAN_FILE=fscript.1



# Build project
echo Building project...
xcodebuild -project $PROJECT_DIR/fscript.xcodeproj -configuration Release


# This script copies the files to the appropriate places in the Installer's
# file hierarchy
echo Copying package files...

sudo rm -rf $INSTALLER_FILES_DIR

mkdir -p $BIN_DIR
mkdir -p $MAN_DIR

cp -f $PROJECT_DIR/build/Release/fscript $BIN_DIR
cp -f $PROJECT_DIR/$MAN_FILE $MAN_DIR

echo Setting permissions...

#/usr permissions
sudo chown -R root:wheel $INSTALLER_FILES_DIR/usr
sudo chmod -R 0755 $INSTALLER_FILES_DIR
sudo chmod 0644 $MAN_DIR/$MAN_FILE


# save documentation
echo Compiling documentation...
DOC_ARCHIVE_NAME=docs
DOC_ARCHIVE_FILE=$DOC_ARCHIVE_NAME.tar.gz
rm -rf $DOC_ARCHIVE_FILE
CURRENT_DIR="$PWD"
cd $PROJECT_DIR
./makedocs.sh clean
compress $DOC_ARCHIVE_NAME Documentation
mv $DOC_ARCHIVE_FILE "$CURRENT_DIR"
cd "$CURRENT_DIR"

echo ""
echo ""

PACKAGE_NAME="fscript command-line tool"
# Build installer
echo Building installer...
echo packagemaker --doc "$INSTALLER_DIR/fscript.pmdoc" --out "$INSTALLER_IMAGE_DIR/$PACKAGE_NAME.pkg" --id "com.andrewweinrich.weinrich.fscript"
packagemaker --doc "$INSTALLER_DIR/fscript.pmdoc" --out "$INSTALLER_IMAGE_DIR/$PACKAGE_NAME.pkg" --id "com.andrewweinrich.fscript"


pkgbuild --root "$INSTALLER_DIR" --





# temporarily move build directories out of project dir
echo Relocating build directories...
mv $PROJECT_DIR/build ./build


# Create disk images
SOURCE_DMG="fscript-source_$DATE.dmg"
BIN_DMG="fscript-bin_$DATE.dmg"
Echo Creating disk images...
if [ -f "$SOURCE_DMG" ]; then
	rm -f "$SOURCE_DMG"
fi
hdiutil create -srcfolder "$PROJECT_DIR" "fscript-source_$DATE.dmg"
if [ -f "$BIN_DMG" ]; then
	rm -f "$BIN_DMG"
fi
hdiutil create -srcfolder "$INSTALLER_IMAGE_DIR" "fscript-bin_$DATE.dmg"

# Replace build directories
echo Replacing build directories...
mv build $PROJECT_DIR/build
