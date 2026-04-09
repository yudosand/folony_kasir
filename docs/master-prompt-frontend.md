# Master Prompt - Frontend

You are now implementing the **Android client** for Folony Kasir.
The existing web demo is only a reference for flow and visual behavior.
Do not copy web-specific behavior blindly.

Before coding:
1. Read `AGENTS.md`
2. Read all files in `/docs`
3. Explain the app structure and screen plan
4. Then implement incrementally

Frontend goals:
- consume the Laravel API backend
- keep behavior consistent with the approved demo
- use Android-appropriate structure and navigation
- keep code modular and maintainable

Core screens:
- login
- register
- home / products
- create/edit product
- checkout
- history
- invoice
- settings

Important behavior to preserve:
- product card shows stock
- home add-to-cart starts with `+`
- after adding, card shows `- qty +`
- checkout supports `cash`, `non_cash`, `split`
- underpayment is allowed
- invoice can be reopened later

Deliverables expected from you:
- clean screen/module structure
- clear state handling
- API integration layer
- reusable components
- explanation of changed files
- testing steps
