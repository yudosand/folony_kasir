# Folony Kasir - Codex Starter Setup

This folder contains context files to help Codex work like a professional developer on the Folony Kasir project.

## Recommended repository structure

```text
folony_kasir/
├─ AGENTS.md
├─ README_Codex_Setup.md
├─ docs/
│  ├─ requirements-summary.md
│  ├─ business-rules.md
│  ├─ backend-architecture.md
│  ├─ frontend-direction-android.md
│  ├─ task-breakdown.md
│  ├─ master-prompt-backend.md
│  └─ master-prompt-frontend.md
└─ screenshots/
   ├─ login.png
   ├─ register.png
   ├─ home.png
   ├─ products.png
   ├─ checkout-cash.png
   ├─ checkout-non-cash.png
   ├─ checkout-split.png
   ├─ history.png
   └─ invoice.png
```

## How to use with Codex
1. Put these files in the root of your repo.
2. Add screenshots from the approved demo into the `screenshots/` folder.
3. Initialize Git before asking Codex to change code.
4. Ask Codex to read `AGENTS.md` and the docs before coding.
5. Start with backend work first.

## Recommended working order
1. Backend plan
2. Database migrations
3. Models and relations
4. Auth API
5. Store settings API
6. Product CRUD API
7. Transactions API
8. Invoice payload API
9. Basic tests / manual verification
10. Frontend Android integration

## Suggested Git workflow
- commit after each major module
- keep changes small and reviewable
- ask Codex to explain changed files after each task

## Notes
- Final app target is Android.
- The web demo is only a visual/flow reference.
- Backend should stay platform-neutral and API-first.
