# Smoke Test Notes

Flutter SDK is not installed in this workspace yet, so runtime checks for the mobile app still need to be executed locally after Flutter is available.

Recommended first checks:

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```
