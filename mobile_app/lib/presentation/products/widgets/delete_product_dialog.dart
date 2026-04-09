import 'package:flutter/material.dart';

class DeleteProductDialog extends StatelessWidget {
  const DeleteProductDialog({
    super.key,
    required this.productName,
  });

  final String productName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Produk'),
      content: Text('Yakin ingin menghapus "$productName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
