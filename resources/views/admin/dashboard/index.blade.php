@extends('admin.layouts.app')

@section('title', 'Dashboard')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Dashboard</h1>
            <div class="admin-topbar__subtitle">
                Ringkasan cepat performa Folony Kasir dari sisi user, transaksi, invoice, dan penggunaan poin member.
            </div>
        </div>
    </div>

    <div class="admin-grid admin-grid--stats">
        <div class="card stat-card">
            <div class="stat-card__label">Total User</div>
            <div class="stat-card__value">{{ number_format($overview['total_users']) }}</div>
            <div class="stat-card__hint">Pengguna terdaftar Folony Kasir</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Total Produk</div>
            <div class="stat-card__value">{{ number_format($overview['total_products']) }}</div>
            <div class="stat-card__hint">Produk milik seluruh user</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Total Transaksi</div>
            <div class="stat-card__value">{{ number_format($overview['total_transactions']) }}</div>
            <div class="stat-card__hint">Semua invoice yang sudah tercatat</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Omzet Tercatat</div>
            <div class="stat-card__value">Rp {{ number_format($overview['total_revenue'], 0, ',', '.') }}</div>
            <div class="stat-card__hint">Akumulasi grand total transaksi</div>
        </div>
    </div>

    <div class="admin-grid admin-grid--stats" style="margin-top: 18px;">
        <div class="card stat-card">
            <div class="stat-card__label">Tagihan Belum Lunas</div>
            <div class="stat-card__value">Rp {{ number_format($overview['outstanding_due'], 0, ',', '.') }}</div>
            <div class="stat-card__hint">Total due amount seluruh transaksi</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Nilai Poin Dipakai</div>
            <div class="stat-card__value">Rp {{ number_format($overview['points_value_redeemed'], 0, ',', '.') }}</div>
            <div class="stat-card__hint">Akumulasi potongan poin member</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Invoice Terbaru</div>
            <div class="stat-card__value">{{ number_format($overview['recent_invoices']->count()) }}</div>
            <div class="stat-card__hint">Snapshot cepat transaksi terbaru</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">User Baru</div>
            <div class="stat-card__value">{{ number_format($overview['recent_users']->count()) }}</div>
            <div class="stat-card__hint">User terbaru yang baru bergabung</div>
        </div>
    </div>

    <div class="admin-grid admin-grid--two" style="margin-top: 18px;">
        <div class="card">
            <h2 class="card__title">Performa 7 Hari Terakhir</h2>
            <div class="card__subtitle">Ringkas supaya cepat dibaca tanpa grafik yang berat.</div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Tanggal</th>
                            <th>Total Transaksi</th>
                            <th>Total Omzet</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($overview['daily_transactions'] as $daily)
                            <tr>
                                <td>{{ \Illuminate\Support\Carbon::parse($daily->transaction_date)->format('d M Y') }}</td>
                                <td>{{ number_format($daily->total_transactions) }}</td>
                                <td>Rp {{ number_format((float) $daily->total_revenue, 0, ',', '.') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="3"><div class="empty-state">Belum ada data transaksi 7 hari terakhir.</div></td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="stack">
            <div class="card">
                <h2 class="card__title">Invoice Terbaru</h2>
                <div class="list">
                    @forelse ($overview['recent_invoices'] as $invoice)
                        <a href="{{ route('admin.invoices.show', $invoice) }}" class="list-item">
                            <div>
                                <div class="list-item__title">{{ $invoice->invoice_number }}</div>
                                <div class="list-item__meta">{{ $invoice->user?->name ?? $invoice->cashier_name_snapshot }} · {{ $invoice->created_at?->format('d M Y H:i') }}</div>
                            </div>
                            <div style="text-align:right;">
                                <div class="list-item__title">Rp {{ number_format((float) $invoice->grand_total, 0, ',', '.') }}</div>
                                <div class="list-item__meta">{{ ucfirst((string) $invoice->payment_status?->value ?? $invoice->payment_status) }}</div>
                            </div>
                        </a>
                    @empty
                        <div class="empty-state">Belum ada invoice yang tercatat.</div>
                    @endforelse
                </div>
            </div>

            <div class="card">
                <h2 class="card__title">User Terbaru</h2>
                <div class="list">
                    @forelse ($overview['recent_users'] as $user)
                        <a href="{{ route('admin.users.show', $user) }}" class="list-item">
                            <div>
                                <div class="list-item__title">{{ $user->name }}</div>
                                <div class="list-item__meta">{{ $user->phone ?: ($user->email ?: '-') }}</div>
                            </div>
                            <div class="list-item__meta">{{ $user->created_at?->format('d M Y') }}</div>
                        </a>
                    @empty
                        <div class="empty-state">Belum ada user baru.</div>
                    @endforelse
                </div>
            </div>
        </div>
    </div>
@endsection
