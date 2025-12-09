FROM archlinux:base-devel-20251019.0.436919 as android-sdk-builder

# Build arguments
ARG APKTOOL_VERSION="2.12.1"

# Install dependencies
RUN pacman -Syu --noconfirm --disable-download-timeout && \
  pacman -S unzip jdk17-openjdk make git wget imagemagick autoconf automake libtool cmake perl patch pkgconf gcc meson --noconfirm --disable-download-timeout && \
  rm -R /var/cache/pacman/pkg/*
RUN mkdir /apktool && \
  curl -L "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_""$APKTOOL_VERSION"".jar" --output /apktool/apktool.jar

# Copy Easy RPG buildscripts repository
COPY easyrpg_buildscripts /easyrpg_buildscripts
COPY easyrpg_player /easyrpg_buildscripts/android/Player
RUN rm /easyrpg_buildscripts/android/Player/.git && mkdir /easyrpg_buildscripts/android/Player/.git

# Create source builder
WORKDIR /easyrpg_buildscripts/android
RUN keytool -genkey -noprompt -v \
    -keystore /easyrpg_buildscripts/android/game_certificate.jks \
    -storepass 123456 \
    -keypass 123456 \
    -alias game_cert \
    -keyalg RSA \
    -dname "CN=gamename.mycompany.com, OU=O, O=O, L=O, S=O, C=US" && \
  sed -i "s|^KEYSTORE_PATH=$|KEYSTORE_PATH=/easyrpg_buildscripts/android/game_certificate.jks|g" /easyrpg_buildscripts/android/4_build_android_port.sh && \
  sed -i "s|^KEY_ALIAS=$|KEY_ALIAS=game_cert|g" /easyrpg_buildscripts/android/4_build_android_port.sh && \
  sed -i "s|^KEY_PASSWORD=$|KEY_PASSWORD=123456|g" /easyrpg_buildscripts/android/4_build_android_port.sh && \
  sed -i "s|applicationId \"org\.easyrpg\.player\"|applicationId \"aaaa.bbbbb.ccccc\"|g" /easyrpg_buildscripts/android/Player/builds/android/app/build.gradle && \
  export BUILD_LIBLCF=1 && \
  ./0_build_everything.sh && \
  java -jar /apktool/apktool.jar d /easyrpg_buildscripts/android/Player/builds/android/app/build/outputs/apk/release/app-release.apk -o /easyrpg-android && \
  rm -r ~/.gradle ~/.android ~/.local && \
  rm -r android-sdk/ arm64-v8a-toolchain/ armeabi-v7a-toolchain/ x86-toolchain/ x86_64-toolchain/ && \
  rm -r /easyrpg_buildscripts/android/Player/builds/android/app/build && \
  rm /easyrpg_buildscripts/android/game_certificate.jks && \
  unset BUILD_LIBLCF
