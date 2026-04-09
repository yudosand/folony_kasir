# Folony Kasir Mobile App

Phase 1 Flutter structure for the Android client.

Current scope:

- app scaffold
- theme and router foundation
- Dio API client
- secure token storage
- login, register, restore session, logout on invalid token
- authenticated home placeholder

Notes:

- The backend API is the source of truth.
- The default API base URL targets the Android emulator host: `http://10.0.2.2:8000/api`
- Override it when needed with:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

- This workspace does not currently have Flutter SDK installed, so Android platform folders still need to be generated locally with Flutter tooling when available.
