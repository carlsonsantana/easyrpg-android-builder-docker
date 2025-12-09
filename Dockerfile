FROM archlinux:base-devel-20251019.0.436919

# Build arguments
ARG SDK_VERSION="9477386_latest"
ARG APKTOOL_VERSION="2.12.1"

# Install dependencies
RUN pacman -Syu --noconfirm
RUN pacman -S unzip jdk17-openjdk make git wget imagemagick autoconf automake libtool cmake perl patch pkgconf gcc meson --noconfirm && \
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
    -dname "CN=gamename.mycompany.com, OU=O, O=O, L=O, S=O, C=US"
RUN sed -i "s|^KEYSTORE_PATH=$|KEYSTORE_PATH=/easyrpg_buildscripts/android/game_certificate.jks|g" /easyrpg_buildscripts/android/4_build_android_port.sh && \
  sed -i "s|^KEY_ALIAS=$|KEY_ALIAS=game_cert|g" /easyrpg_buildscripts/android/4_build_android_port.sh && \
  sed -i "s|^KEY_PASSWORD=$|KEY_PASSWORD=123456|g" /easyrpg_buildscripts/android/4_build_android_port.sh
ENV BUILD_LIBLCF 1
RUN ./0_build_everything.sh
