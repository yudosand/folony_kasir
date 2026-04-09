# Requirements Summary

## Product Name
Folony Kasir

## Final Platform Target
Android application

## Current Reference
Mobile-style web demo used only as UI/UX and flow reference.

## MVP Scope
- Login via API
- Register via API
- Profile / store setting
- Product CRUD
- Product image upload
- Cart / checkout
- Payment methods:
  - cash
  - non_cash
  - split
- Invoice payload
- History / transaction detail
- Reprint / resharing invoice support

## Out of Scope for Current MVP
- Barcode scanning
- Advanced reports
- Multi-device sync
- Hardware-specific printer integration
- Multi-role/complex permission system

## Key UX Behavior from Demo
- Product cards show stock
- Home product card starts with `+`
- After adding an item, card changes to `- qty +`
- Checkout supports cash, non-cash, and split payment
- Underpayment is allowed and should show a partial status

## Important Technical Direction
- Backend first
- API-first architecture
- Android-ready response structure
- Filesystem/cloud for images, DB stores path only
