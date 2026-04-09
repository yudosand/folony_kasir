@extends('admin.layouts.app')

@section('title', 'Detail Invoice')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">{{ $invoice->invoice_number }}</h1>
            <div class="admin-topbar__subtitle">
                Detail invoice, item transaksi, pembayaran, dan penggunaan poin member jika ada.
            </div>
        </div>
        <a href="{{ route('admin.invoices.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;">Kembali ke Invoices</a>
    </div>

    <div class="card">
        <h2 class="card__title">Ringkasan Invoice</h2>
        <div class="detail-grid">
            <div class="detail-card">
                <div class="detail-card__label">Tanggal</div>
                <div class="detail-card__value">{{ $invoice->created_at?->format('d M Y H:i') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">User</div>
                <div class="detail-card__value">{{ $invoice->user?->name ?? $invoice->cashier_name_snapshot }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Metode Pembayaran</div>
                <div class="detail-card__value">{{ ucfirst((string) $invoice->payment_method?->value ?? $invoice->payment_method) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Status Pembayaran</div>
                <div class="detail-card__value">{{ ((string) $invoice->payment_status?->value ?? $invoice->payment_status) === 'paid' ? 'Lunas' : 'Belum Lunas' }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Total Item</div>
                <div class="detail-card__value">{{ number_format($invoice->item_count) }} item</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Subtotal</div>
                <div class="detail-card__value">Rp {{ number_format((float) $invoice->subtotal, 0, ',', '.') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Grand Total</div>
                <div class="detail-card__value">Rp {{ number_format((float) $invoice->grand_total, 0, ',', '.') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Total Dibayar</div>
                <div class="detail-card__value">Rp {{ number_format((float) $invoice->amount_paid + (float) $invoice->member_points_value_amount, 0, ',', '.') }}</div>
            </div>
        </div>
    </div>

    <div class="admin-grid admin-grid--two" style="margin-top: 18px;">
        <div class="card">
            <h2 class="card__title">Item Transaksi</h2>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Produk</th>
                            <th>Qty</th>
                            <th>Harga Jual</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($invoice->items as $item)
                            <tr>
                                <td>{{ $item->product_name_snapshot }}</td>
                                <td>{{ number_format($item->quantity) }}</td>
                                <td>Rp {{ number_format((float) $item->selling_price_snapshot, 0, ',', '.') }}</td>
                                <td>Rp {{ number_format((float) $item->line_subtotal, 0, ',', '.') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4"><div class="empty-state">Item transaksi belum tersedia.</div></td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="stack">
            <div class="card">
                <h2 class="card__title">Pembayaran</h2>
                <div class="list">
                    <div class="list-item">
                        <div>
                            <div class="list-item__title">Tunai</div>
                            <div class="list-item__meta">Nominal cash yang tercatat</div>
                        </div>
                        <div class="list-item__title">Rp {{ number_format((float) $invoice->cash_amount, 0, ',', '.') }}</div>
                    </div>
                    <div class="list-item">
                        <div>
                            <div class="list-item__title">Non Tunai</div>
                            <div class="list-item__meta">Nominal non cash yang tercatat</div>
                        </div>
                        <div class="list-item__title">Rp {{ number_format((float) $invoice->non_cash_amount, 0, ',', '.') }}</div>
                    </div>
                    <div class="list-item">
                        <div>
                            <div class="list-item__title">Kurang Bayar</div>
                            <div class="list-item__meta">Sisa tagihan invoice</div>
                        </div>
                        <div class="list-item__title">Rp {{ number_format((float) $invoice->due_amount, 0, ',', '.') }}</div>
                    </div>
                </div>
            </div>

            <div class="card">
                <h2 class="card__title">Poin Member</h2>
                @if ((int) $invoice->member_points_used > 0)
                    <div class="list">
                        <div class="list-item">
                            <div>
                                <div class="list-item__title">Member</div>
                                <div class="list-item__meta">{{ $invoice->member_name_snapshot ?: '-' }}</div>
                            </div>
                            <div class="list-item__title">ID {{ $invoice->member_external_id ?: '-' }}</div>
                        </div>
                        <div class="list-item">
                            <div>
                                <div class="list-item__title">Poin Dipakai</div>
                                <div class="list-item__meta">Konversi 1 poin = Rp 1</div>
                            </div>
                            <div class="list-item__title">{{ number_format((int) $invoice->member_points_used) }} poin</div>
                        </div>
                        <div class="list-item">
                            <div>
                                <div class="list-item__title">Nilai Potongan</div>
                                <div class="list-item__meta">{{ $invoice->member_point_status ?: 'Status belum ada' }}</div>
                            </div>
                            <div class="list-item__title">Rp {{ number_format((float) $invoice->member_points_value_amount, 0, ',', '.') }}</div>
                        </div>
                    </div>
                @else
                    <div class="empty-state">Invoice ini tidak memakai poin member.</div>
                @endif
            </div>
        </div>
    </div>
@endsection
