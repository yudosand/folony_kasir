import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/entities/invoice.dart';

final invoiceControllerProvider =
    FutureProvider.autoDispose.family<Invoice, int>((ref, transactionId) {
  return ref.read(getInvoiceUseCaseProvider).call(transactionId);
});
