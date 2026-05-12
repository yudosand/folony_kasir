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
- Stock bookkeeping / inventory ledger
- Restock insight for low-stock and out-of-stock products
- Sales profit report
- Cart / checkout
- Payment methods:
  - cash
  - non_cash
  - split
- Invoice payload
- History / transaction detail
- Reprint / resharing invoice support
- PDF export / share for stock bookkeeping report
- Admin export for sales profit report

## Out of Scope for Current MVP
- Barcode scanning
- Multi-device sync
- Hardware-specific printer integration
- Multi-role/complex permission system

## Stock Bookkeeping Scope

- Menyimpan stok awal saat produk pertama kali dibuat
- Menyimpan mutasi stok untuk:
  - penjualan
  - restock manual
  - penyesuaian manual
- Menandai barang:
  - aman
  - menipis
  - habis
  - perlu restock
- Menyediakan kartu stok per produk
- Menyediakan laporan pembukuan stok yang bisa diexport dan dibagikan

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
