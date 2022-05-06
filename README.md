# Caror

## Getting Started
- To generate localizations, run commands:
  - (If needed) dart pub global activate intl_utils 2.6.1
  - flutter pub run intl_utils:generate
- Mobile_scanner library may have problem on flutter channel dev. Please switched to branch stable by command: flutter channel stable

## Work on
- Build APK:
  - flutter build apk --obfuscate --split-debug-info=split-debug-info
    - E:\Flutter Project\CarorApp\build\app\outputs\flutter-apk
    - [APK](https://github.com/thinhtrai1/CarorApp/blob/develop/Caror.apk)