class StoreSetting {
  const StoreSetting({
    this.id,
    this.storeName = '',
    this.storeAddress = '',
    this.phoneNumber = '',
    this.invoiceFooter = '',
    this.logoUrl,
    this.updatedAt,
  });

  final int? id;
  final String storeName;
  final String storeAddress;
  final String phoneNumber;
  final String invoiceFooter;
  final String? logoUrl;
  final DateTime? updatedAt;
}
