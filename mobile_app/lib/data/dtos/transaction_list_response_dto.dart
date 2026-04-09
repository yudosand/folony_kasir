import 'transaction_dto.dart';

class TransactionListResponseDto {
  const TransactionListResponseDto({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final List<TransactionDto> transactions;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory TransactionListResponseDto.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] is Map<String, dynamic>
        ? json['pagination'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return TransactionListResponseDto(
      transactions: (json['transactions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TransactionDto.fromJson)
          .toList(),
      currentPage: (pagination['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (pagination['last_page'] as num?)?.toInt() ?? 1,
      perPage: (pagination['per_page'] as num?)?.toInt() ?? 100,
      total: (pagination['total'] as num?)?.toInt() ?? 0,
    );
  }
}
