# RM2kx Android Builder on Docker

This project allows you to convert **RPG Maker 2000/2003** games for **Android** using **Docker** and **[EasyRPG](https://easyrpg.org/)**.

## Install

To install this **Docker image**, you must have **Docker** installed on your machine and in the terminal execute the following command:

```sh
docker pull carlsonsantana/rm2kx-android-builder:latest
```

Or build it yourself executing the following command on the terminal:

```sh
docker build -t rm2kx-android-builder .
```

## Usage

Run the Docker image, mounting your game files and passing the environment variables that describe your game. The generated `.apk` and `.aab` files will be written to the directory you mount at `/output`.

### Unsigned build

```sh
docker run --rm \
  -v "$(pwd)/rpgmaker2kx_game:/rpgmaker2kx_game" \
  -v "$(pwd)/icon.png:/icon.png" \
  -v "$(pwd)/output:/output" \
  -e GAME_APK_NAME="com.mycompany.mygame" \
  -e GAME_NAME="My Game" \
  -e GAME_VERSION_CODE="100" \
  -e GAME_VERSION_NAME="1.0.0" \
  -e GAME_METADATA_SITE="https://example.com/" \
  -e GAME_OPTIMIZATION_MINIFY_IMAGES="true" \
  carlsonsantana/rm2kx-android-builder:latest
```

### Signed build

To sign the output, also mount your keystore file at `/game_certificate.key` and provide the keystore credentials, either through environment variables or through secret files. This example uses environment variables:

```sh
docker run --rm \
  -v "$(pwd)/rpgmaker2kx_game:/rpgmaker2kx_game" \
  -v "$(pwd)/icon.png:/icon.png" \
  -v "$(pwd)/output:/output" \
  -v "$(pwd)/game_certificate.key:/game_certificate.key" \
  -e GAME_APK_NAME="com.mycompany.mygame" \
  -e GAME_NAME="My Game" \
  -e GAME_VERSION_CODE="100" \
  -e GAME_VERSION_NAME="1.0.0" \
  -e GAME_METADATA_SITE="https://example.com/" \
  -e GAME_OPTIMIZATION_MINIFY_IMAGES="true" \
  -e GAME_KEYSTORE_PASSWORD="your_keystore_password" \
  -e GAME_KEYSTORE_KEY_ALIAS="your_key_alias" \
  -e GAME_KEYSTORE_KEY_PASSWORD="your_key_password" \
  carlsonsantana/rm2kx-android-builder:latest
```

To keep the keystore credentials out of the command line, mount them as plain text secret files instead of setting the `GAME_KEYSTORE_PASSWORD`, `GAME_KEYSTORE_KEY_ALIAS` and `GAME_KEYSTORE_KEY_PASSWORD` variables:

```sh
docker run --rm \
  -v "$(pwd)/rpgmaker2kx_game:/rpgmaker2kx_game" \
  -v "$(pwd)/icon.png:/icon.png" \
  -v "$(pwd)/output:/output" \
  -v "$(pwd)/game_certificate.key:/game_certificate.key" \
  -v "$(pwd)/keystore_password.txt:/run/secrets/game_keystore_password" \
  -v "$(pwd)/key_alias.txt:/run/secrets/game_keystore_key_alias" \
  -v "$(pwd)/key_password.txt:/run/secrets/game_keystore_key_password" \
  -e GAME_APK_NAME="com.mycompany.mygame" \
  -e GAME_NAME="My Game" \
  -e GAME_VERSION_CODE="100" \
  -e GAME_VERSION_NAME="1.0.0" \
  -e GAME_METADATA_SITE="https://example.com/" \
  -e GAME_OPTIMIZATION_MINIFY_IMAGES="true" \
  carlsonsantana/rm2kx-android-builder:latest
```

### Volumes

You must mount the following volumes when running the Docker image. These mounts provide the necessary input files and define the location for the final output.

* `/rpgmaker2kx_game` your RPG Maker 2000/2003 game (remove the files that Android will not use, such as `RPG_RT.exe`, any documentation, any extras and, of course, `Thumbs.db` files);
* `/icon.png` the icon for your Android game;
* `/output` the directory where the aligned or signed `.apk` and `.aab` will be created;
* **(Optional)** `/game_certificate.key` the keystore file used to [sign the `.apk` file](https://developer.android.com/build/building-cmdline#sign_manually) and [sign the `.aab` file](https://learn.microsoft.com/en-us/power-apps/maker/common/wrap/code-sign-aab-file); if provided, you must also set the `GAME_KEYSTORE_PASSWORD`, `GAME_KEYSTORE_KEY_ALIAS` and `GAME_KEYSTORE_KEY_PASSWORD` environment variables;
* **(Optional)** `/run/secrets/game_keystore_password` a plain text file containing the keystore password, required when the `/game_certificate.key` volume is provided and the `GAME_KEYSTORE_PASSWORD` environment variable isn't set;
* **(Optional)** `/run/secrets/game_keystore_key_alias` a plain text file containing the key alias in the keystore, required when the `/game_certificate.key` volume is provided and the `GAME_KEYSTORE_KEY_ALIAS` environment variable isn't set;
* **(Optional)** `/run/secrets/game_keystore_key_password` a plain text file containing the key password in the keystore, required when the `/game_certificate.key` volume is provided and the `GAME_KEYSTORE_KEY_PASSWORD` environment variable isn't set.

### Environment Variables

* `GAME_APK_NAME` the [Application ID](https://developer.android.com/build/configure-app-module#set-application-id) (e.g., `com.mycompany.mygame`) of your Android game;
* `GAME_NAME` the name displayed beneath the app icon on the device;
* `GAME_VERSION_CODE` the version code of your game (example: "100"); newer versions must have a greater value than older ones;
* `GAME_VERSION_NAME` the version name shown to the user, which may contain letters and dots (example: "1.0.0");
* `GAME_KEYSTORE_PASSWORD` the keystore password, required when the `/game_certificate.key` volume is provided and the `/run/secrets/game_keystore_password` volume isn't provided;
* `GAME_KEYSTORE_KEY_ALIAS` the key alias in the keystore, required when the `/game_certificate.key` volume is provided and the `/run/secrets/game_keystore_key_alias` volume isn't provided;
* `GAME_KEYSTORE_KEY_PASSWORD` the key password in the keystore, required when the `/game_certificate.key` volume is provided and the `/run/secrets/game_keystore_key_password` volume isn't provided;
* `GAME_METADATA_SITE` the website shown in the side menu;
* `GAME_OPTIMIZATION_MINIFY_IMAGES` set to `true` to minify images without losing quality.
