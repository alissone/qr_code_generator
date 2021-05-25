# Simple QR Code Generator

This is a Flutter app created to generate QR Codes from text. Should be used within the `share` modal on Android (there is no iOS support currently).


You can either scan the code from another device or share the resulting transparent PNG image to any other app. 

## Sample screenshots

### Opening app from launcher icon
<img src='https://github.com/alissone/qr_code_generator/raw/main/screenshots/Screenshot_2021-05-25-16-11-15-937_com.alissone.qrCodeGen.jpg' height='250'>


### Opening app from `Share` modal
<img src='https://github.com/alissone/qr_code_generator/raw/main/screenshots/Screenshot_2021-05-25-16-11-02-159_com.alissone.qrCodeGen.jpg' height='250'>

## Running locally

Execute in a terminal emulator

    flutter pub get

and then

    flutter run

## Installing prebuilt binaries
There is a prebuilt APK file on `beta` folder that can be downloaded [here](https://github.com/alissone/qr_code_generator/raw/main/beta/app-release.apk).

## TODO
- The exported image is black on some apps. This is due to the PNG background transparency being treated differently among apps. Adding a white background to the image before exporting should solve this issue;
- Being able to generate a code from clipboard content should be a nice addition;
