import '../../domain/entities/store_setting.dart';
import '../../core/utils/media_url_resolver.dart';

class StoreSettingDto {
  const StoreSettingDto({
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

  factory StoreSettingDto.fromJson(Map<String, dynamic> json) {
    return StoreSettingDto(
      id: (json['id'] as num?)?.toInt(),
      storeName: json['store_name'] as String? ?? '',
      storeAddress: json['store_address'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      invoiceFooter: json['invoice_footer'] as String? ?? '',
      logoUrl: MediaUrlResolver.resolve(json['logo_url'] as String?),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
    );
  }

  StoreSetting toEntity() {
    return StoreSetting(
      id: id,
      storeName: storeName,
      storeAddress: storeAddress,
      phoneNumber: phoneNumber,
      invoiceFooter: invoiceFooter,
      logoUrl: logoUrl,
      updatedAt: updatedAt,
    );
  }
}
