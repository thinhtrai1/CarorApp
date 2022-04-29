# Caror

## Getting Started
- To generate localizations, run commands:
  - dart pub global activate intl_utils <intl_utils_version>
  - flutter gen-l10n --template-arb-file=intl_en.arb
  - dart pub global run intl_utils:generate
- Mobile_scanner library may have problem on flutter channel dev. Please switched to branch stable by command: flutter channel stable

## Note
- flutter build apk --obfuscate --split-debug-info=split-debug-info
  - E:\Flutter Project\Caror\build\app\outputs\flutter-apk
- [APK](https://github.com/thinhtrai1/CarorApp/blob/develop/Caror.apk)