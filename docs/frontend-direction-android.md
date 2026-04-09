# Frontend Direction - Android First

## Important
The final client application is Android.
The existing web demo is only a behavior and visual reference.

## What frontend must preserve from the demo
- clear POS flow
- product cards with stock
- add-to-cart interaction (`+` then `- qty +`)
- checkout payment modes:
  - cash
  - non_cash
  - split
- invoice/history behavior
- invoice PDF actions:
  - share PDF
  - download PDF
  - print can remain unavailable until explicitly implemented

## What frontend must not copy blindly
- desktop/web-specific interaction patterns
- browser-specific workarounds
- layout assumptions that do not fit Android navigation patterns

## Android-minded API expectations
- stable JSON structure
- lightweight payloads
- clean error messages
- predictable auth flow
- explicit payment fields

## Product Image Handling
- image selection should stay simple for Android users
- product images should be optimized on-device before upload
- current target is a longest side around `1280px`
- current compressed quality target is around `78`
- if optimization fails, upload flow should fall back safely to the original image instead of blocking the form

## Suggested frontend phases later
1. auth screens
2. home / products
3. create/edit product
4. cart / checkout
5. history
6. invoice
7. settings
