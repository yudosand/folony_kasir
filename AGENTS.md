# AGENTS.md

## Project Identity
This repository is for **Folony Kasir**, a POS application whose **final target platform is Android**.
The existing web demo / GitHub Pages link is **only a visual and flow reference**, not the final platform.

## Core Principle
Build this project like a **professional, maintainable, production-oriented codebase**.
Do not generate quick prototype code unless explicitly requested.

## Product Direction
- Final product target: Android application
- Current reference: mobile-style web demo
- Backend first, frontend second
- Backend must be API-first and ready to serve Android clients
- UI/UX should follow the approved demo flow and behavior

## Working Mode
For medium or large changes:
1. Read relevant docs in `/docs`
2. Write a short implementation plan before coding
3. Implement in small, reviewable steps
4. Explain changed files and testing steps

Use **plan-first** for complex work such as auth, transactions, payment logic, invoice handling, or schema changes.

## Non-Negotiable Coding Standards
- Use clear, descriptive naming
- Keep files focused and modular
- Separate responsibilities properly
- Avoid duplicated logic
- Add comments only where they help understanding, not for obvious code
- Prefer service classes / use-case classes for business logic
- Keep controllers thin
- Validate all input
- Return consistent API responses
- Make future maintenance easy

## Backend Standards
Target stack:
- Laravel API
- MySQL
- Sanctum token auth

Architecture expectations:
- `app/Http/Controllers/Api` for controllers
- `app/Http/Requests` for validation
- `app/Http/Resources` for response formatting
- `app/Services` for business logic
- `app/Models` for Eloquent models
- database schema via migrations only
- use transactions for critical write flows

Response format:
```json
{
  "success": true,
  "message": "Message",
  "data": {}
}
```

Error format:
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {}
}
```

## Business Rules You Must Follow
- One active token/session per user/device policy
- Login/register via API
- User creates their own products
- Product price used in checkout comes from master product at transaction time
- Transaction items must store snapshots of product name and prices
- Stock decreases when transaction is successfully saved
- Payment methods:
  - `cash`
  - `non_cash`
  - `split`
- Underpayment is allowed; payment status must become `partial`
- Invoice must be re-openable, printable, and shareable
- Web demo is only a behavior reference; do not assume web-specific UI patterns are final for Android

## Payment Logic Rules
### cash
- `amount_paid = cash_amount`
- If paid > total: set `change_amount`
- If paid < total: set `due_amount` and `payment_status = partial`

### non_cash
- `amount_paid = non_cash_amount`
- `change_amount = 0`
- If paid < total: set `due_amount` and `payment_status = partial`

### split
- `amount_paid = cash_amount + non_cash_amount`
- If paid > total: set `change_amount`
- If paid < total: set `due_amount` and `payment_status = partial`

## Data / Media Rules
- Database name: `folony_pos`
- Product/store images: store files in filesystem/cloud, store path/url in DB
- Do not store image binary in database

## Documentation Discipline
When making major changes, update relevant docs in `/docs` if the behavior, schema, API contract, or task breakdown changes.

## What To Avoid
- Do not collapse everything into one controller
- Do not mix validation, query logic, and formatting in one method
- Do not hardcode random responses or magic values
- Do not ignore edge cases for stock, payment, or ownership
- Do not rewrite agreed business rules without explicit reason

## Definition of Done
A task is only done if:
- code is structured and readable
- business rules are respected
- validation exists
- outputs are consistent
- changed files are explained
- testing steps are provided
