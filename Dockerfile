FROM --platform=$BUILDPLATFORM alpine:3.18.12 AS android-sdk-builder

# Build arguments
ARG APKTOOL_VERSION="2.12.1"

# Install dependencies
RUN apk --update --no-cache add curl openjdk17-jdk bash unzip make git wget imagemagick autoconf automake libtool cmake perl patch pkgconf build-base gcc g++ oxipng && \
  apk --no-cache add python3 samurai libc6-compat gcompat && \
  apk --update --no-cache fetch meson --repository=https://dl-cdn.alpinelinux.org/alpine/v3.23/main && \
  tar -zxvf meson-* && \
  mv /usr/lib/python3.12/site-packages/mesonbuild/ /usr/lib/python3.11/site-packages/mesonbuild && \
  mv /usr/lib/python3.12/site-packages/meson-*/ /usr/lib/python3.11/site-packages/ && \
  rm meson-* && \
  rm -r /usr/lib/python3.12/
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
  sed -i "s|applicationId \"org\.easyrpg\.player\"|applicationId \"aaaaa.bbbbb.ccccc\"|g" /easyrpg_buildscripts/android/Player/builds/android/app/build.gradle && \
  export BUILD_LIBLCF=1 && \
  bash ./0_build_everything.sh && \
  java -jar /apktool/apktool.jar d /easyrpg_buildscripts/android/Player/builds/android/app/build/outputs/apk/release/app-release.apk -o /easyrpg-android && \
  oxipng -r -o 2 --strip safe /easyrpg-android/res && \
  rm -r ~/.gradle ~/.android ~/.local && \
  rm -r android-sdk/ arm64-v8a-toolchain/ armeabi-v7a-toolchain/ x86-toolchain/ x86_64-toolchain/ && \
  rm -r /easyrpg_buildscripts/android/Player/builds/android/app/build /easyrpg_buildscripts/android/Player/builds/android/app/.cxx && \
  rm /easyrpg_buildscripts/android/game_certificate.jks && \
  unset BUILD_LIBLCF


# Another image with only used resources
FROM alpine:3.23.3

# Install dependencies
RUN apk --update --no-cache add openjdk17-jdk curl imagemagick oxipng zip abseil-cpp-hash gtest libprotobuf fmt && \
  apk --update --no-cache add android-build-tools --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN curl -L "https://github.com/carlsonsantana/signmyapp/releases/download/1.1.0/signmyapp.jar" --output /opt/signmyapp.jar && \
  curl -L "https://github.com/google/bundletool/releases/download/1.18.3/bundletool-all-1.18.3.jar" --output /opt/bundletool.jar && \
  curl -L "https://github.com/Sable/android-platforms/raw/f2ca864c44f277bbc09afda0ba36437ce22105f0/android-36/android.jar" --output /opt/android.jar

# Copy files from previous build
RUN mkdir /apktool
COPY --from=android-sdk-builder /apktool/apktool.jar /apktool/apktool.jar
COPY --from=android-sdk-builder /easyrpg-android /easyrpg-android

# Volumes
RUN mkdir /output
VOLUME /rpgmaker2kx_game
VOLUME /icon.png
VOLUME /output
VOLUME /game_certificate.key
VOLUME /run/secrets/game_keystore_password
VOLUME /run/secrets/game_keystore_key_alias
VOLUME /run/secrets/game_keystore_key_password

# Environment variables
ENV GAME_APK_NAME="com.mycompany.gamename"
ENV GAME_NAME="Game Name"
ENV GAME_VERSION_CODE="100"
ENV GAME_VERSION_NAME="1.0.0"
ENV GAME_METADATA_SITE="http://example.com/"
ENV GAME_OPTIMIZATION_MINIFY_IMAGES="false"

# Run build
WORKDIR /
COPY script /script
CMD ["sh", "/script/run.sh"]
