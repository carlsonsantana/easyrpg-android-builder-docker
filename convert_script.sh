#!/bin/bash

set -e

# Standalone game variables
GAME_FOLDER=$(pwd)/your_game
GAME_APK_NAME=com.your.game
GAME_NAME='Your game'
GAME_BUG_REPORT_EMAIL=email_of_game@mail.com
GAME_SITE='http://example.com/'
GAME_VERSION_CODE=100
GAME_VERSION_NAME=1.0.0
GAME_METADATA=$(pwd)/metadata
GAME_ICON_PATH=$GAME_METADATA/en-US/images/icon.png
GAME_ICON_PROMOGRAPHIC=$GAME_METADATA/en-US/images/promoGraphic.png
EASYRPG_PLAYER_FOLDER=$(pwd)/easyrpg_buildscripts/android/Player
##############################

ANDROID_FOLDER=$EASYRPG_PLAYER_FOLDER/builds/android

cd $EASYRPG_PLAYER_FOLDER

# Ignore game folder on commit
sed -i ':a;N;$!ba;s|\n\n# Game folder||g' .gitignore
sed -i ':a;N;$!ba;s|\n/builds/android/app/src/main/assets/||g' .gitignore
echo "" >> .gitignore
echo "# Game folder" >> .gitignore
echo "/builds/android/app/src/main/assets/" >> .gitignore

BUILD_FOLDER=$ANDROID_FOLDER/app/src/main

# Copy game
cd $GAME_FOLDER
rm -f $BUILD_FOLDER/game.zip
rm -f $BUILD_FOLDER/assets/game.zip
zip -r $BUILD_FOLDER/game.zip *
mv $BUILD_FOLDER/game.zip $BUILD_FOLDER/assets/game.zip
cd $BUILD_FOLDER

# Change APK name
sed -i "s|org\.easyrpg\.player|$GAME_APK_NAME|g" $ANDROID_FOLDER/app/build.gradle

# Change game name
sed -i "s|EasyRPG Player|$GAME_NAME|g" res/values/strings.xml

# Change game email
sed -i "s|easyrpg@easyrpg\.org|$GAME_BUG_REPORT_EMAIL|g" java/org/easyrpg/player/player/EasyRpgPlayerActivity.java

# Change game site
sed -i "s|https://easyrpg\.org/|$GAME_SITE|g" res/layout/browser_nav_header.xml

# Change version code
sed -i 's/android\:versionCode="[0-9]\+"/android:versionCode="'$GAME_VERSION_CODE'"/g' AndroidManifest.xml

# Change version name
sed -i 's/android\:versionName="[0-9A-Za-z\-\.]\+"/android:versionName="'$GAME_VERSION_NAME'"/g' AndroidManifest.xml

# Convert icon to HDPI: 72x72
convert $GAME_ICON_PATH -resize 72x72 res/drawable-hdpi/ic_launcher.png

# Convert icon to MDPI: 48x48
convert $GAME_ICON_PATH -resize 48x48 res/drawable-mdpi/ic_launcher.png

# Convert icon to XHDPI: 96x96
convert $GAME_ICON_PATH -resize 96x96 res/drawable-xhdpi/ic_launcher.png

# Convert icon to XXHPDI: 144x144
convert $GAME_ICON_PATH -resize 144x144 res/drawable-xxhdpi/ic_launcher.png

# Convert icon to XXXHDPI: 192x192
convert $GAME_ICON_PATH -resize 192x192 res/drawable-xxxhdpi/ic_launcher.png

# Convert icon to promoGraphic.png: 180x120
convert $GAME_ICON_PATH -resize 120x120 $GAME_ICON_PROMOGRAPHIC
convert $GAME_ICON_PROMOGRAPHIC -resize 180x120 -size 180x120 xc:none +swap -gravity center -composite $GAME_ICON_PROMOGRAPHIC

# Change metadata
rm -r $ANDROID_FOLDER/metadata
cp -r $GAME_METADATA $ANDROID_FOLDER/metadata
