@extends('admin.layouts.app')

@section('title', 'Detail Produk')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">{{ $product->name }}</h1>
            <div class="admin-topbar__subtitle">
                Detail produk global untuk melihat pemilik, harga, stok, dan histori penjualan dasarnya.
            </div>
        </div>
        <a href="{{ route('admin.products.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;">Kembali ke Products</a>
    </div>

    <div class="card">
        <h2 class="card__title">Ringkasan Produk</h2>
        <div class="detail-grid">
            <div class="detail-card">
                <div class="detail-card__label">Pemilik</div>
                <div class="detail-card__value">{{ $product->user?->name ?? '-' }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Kontak Pemilik</div>
                <div class="detail-card__value">{{ $product->user?->phone ?: ($product->user?->email ?: '-') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Stok Saat Ini</div>
                <div class="detail-card__value">{{ number_format($product->stock) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Harga Modal</div>
                <div class="detail-card__value">Rp {{ number_format((float) $product->cost_price, 0, ',', '.') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Harga Jual</div>
                <div class="detail-card__value">Rp {{ number_format((float) $product->selling_price, 0, ',', '.') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Jumlah Baris Terjual</div>
                <div class="detail-card__value">{{ number_format($product->transaction_items_count) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Total Qty Terjual</div>
                <div class="detail-card__value">{{ number_format((int) ($product->total_quantity_sold ?? 0)) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Dibuat</div>
                <div class="detail-card__value">{{ $product->created_at?->format('d M Y') }}</div>
            </div>
        </div>
    </div>

    <div class="card" style="margin-top: 18px;">
        <h2 class="card__title">Riwayat Penjualan Terkait</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Invoice</th>
                        <th>Tanggal</th>
                        <th>Qty</th>
                        <th>Harga Snapshot</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($product->transactionItems as $transactionItem)
                        <tr>
                            <td>
                                @if ($transactionItem->transaction)
                                    <a href="{{ route('admin.invoices.show', $transactionItem->transaction) }}"><strong>{{ $transactionItem->transaction->invoice_number }}</strong></a>
                                @else
                                    -
                                @endif
                            </td>
                            <td>{{ $transactionItem->transaction?->created_at?->format('d M Y H:i') ?? '-' }}</td>
                            <td>{{ number_format($transactionItem->quantity) }}</td>
                            <td>Rp {{ number_format((float) $transactionItem->selling_price_snapshot, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $transactionItem->line_subtotal, 0, ',', '.') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5"><div class="empty-state">Belum ada riwayat penjualan untuk produk ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
