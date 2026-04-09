@extends('admin.layouts.app')

@section('title', 'Detail User')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">{{ $userDetail->name }}</h1>
            <div class="admin-topbar__subtitle">
                Detail user Folony Kasir, produk yang dimiliki, serta ringkasan transaksi terbaru.
            </div>
        </div>
        <a href="{{ route('admin.users.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;">Kembali ke Users</a>
    </div>

    <div class="card">
        <h2 class="card__title">Ringkasan User</h2>
        <div class="detail-grid">
            <div class="detail-card">
                <div class="detail-card__label">Nomor HP</div>
                <div class="detail-card__value">{{ $userDetail->phone ?: '-' }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Email</div>
                <div class="detail-card__value">{{ $userDetail->email ?: '-' }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Tanggal Bergabung</div>
                <div class="detail-card__value">{{ $userDetail->created_at?->format('d M Y') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Member ID Foloni App</div>
                <div class="detail-card__value">{{ $userDetail->external_member_id ?: '-' }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Total Produk</div>
                <div class="detail-card__value">{{ number_format($userDetail->products_count) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Total Transaksi</div>
                <div class="detail-card__value">{{ number_format($userDetail->transactions_count) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Total Omzet</div>
                <div class="detail-card__value">Rp {{ number_format((float) ($userDetail->total_transaction_value ?? 0), 0, ',', '.') }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Kurang Bayar Tercatat</div>
                <div class="detail-card__value">Rp {{ number_format((float) ($userDetail->total_due_value ?? 0), 0, ',', '.') }}</div>
            </div>
        </div>
    </div>

    <div class="admin-grid admin-grid--two" style="margin-top: 18px;">
        <div class="card">
            <h2 class="card__title">Produk Milik User</h2>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Nama Produk</th>
                            <th>Stok</th>
                            <th>Harga Modal</th>
                            <th>Harga Jual</th>
                            <th>Dibuat</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($products as $product)
                            <tr>
                                <td>{{ $product->name }}</td>
                                <td>{{ number_format($product->stock) }}</td>
                                <td>Rp {{ number_format((float) $product->cost_price, 0, ',', '.') }}</td>
                                <td>Rp {{ number_format((float) $product->selling_price, 0, ',', '.') }}</td>
                                <td>{{ $product->created_at?->format('d M Y') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5"><div class="empty-state">User ini belum punya produk.</div></td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
            @include('admin.partials.pagination', ['paginator' => $products])
        </div>

        <div class="card">
            <h2 class="card__title">Transaksi Terbaru</h2>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Invoice</th>
                            <th>Tanggal</th>
                            <th>Pembayaran</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($transactions as $transaction)
                            <tr>
                                <td><a href="{{ route('admin.invoices.show', $transaction) }}"><strong>{{ $transaction->invoice_number }}</strong></a></td>
                                <td>{{ $transaction->created_at?->format('d M Y H:i') }}</td>
                                <td><span class="badge">{{ ucfirst((string) $transaction->payment_method?->value ?? $transaction->payment_method) }}</span></td>
                                <td>Rp {{ number_format((float) $transaction->grand_total, 0, ',', '.') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4"><div class="empty-state">Belum ada transaksi untuk user ini.</div></td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
            @include('admin.partials.pagination', ['paginator' => $transactions])
        </div>
    </div>
@endsection
