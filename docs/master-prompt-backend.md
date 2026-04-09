# Master Prompt - Backend

You are working on **Folony Kasir**, a POS application.
The final target platform is **Android**, but this task is **backend first**.
The existing web demo is only a visual and behavior reference.

Before coding:
1. Read `AGENTS.md`
2. Read all files in `/docs`
3. Summarize the implementation plan
4. Then start coding in small, reviewable steps

Your task:
Build a professional **Laravel API backend** for Folony Kasir using:
- Laravel
- MySQL
- Sanctum

Database name:
- `folony_pos`

Modules to implement:
1. Auth API
2. Store Setting API
3. Product CRUD API
4. Transaction API
5. Invoice payload API

Required standards:
- clean project structure
- thin controllers
- validation in Form Requests
- business logic in service classes
- consistent JSON responses
- clear naming
- maintainable code
- comments only where they improve understanding

Required business rules:
- one active token per user policy
- user manages their own products only
- transaction uses product price snapshots
- stock decreases after successful transaction save
- payment methods: `cash`, `non_cash`, `split`
- underpayment is allowed and must become `partial`

Required tables:
- users
- personal_access_tokens
- store_settings
- products
- transactions
- transaction_items

Expected deliverables:
- migrations
- models
- requests
- resources
- controllers
- services
- routes
- seeders if useful
- explanation of changed files
- setup/run steps
- suggested manual testing checklist

Do not skip structure quality for speed.
