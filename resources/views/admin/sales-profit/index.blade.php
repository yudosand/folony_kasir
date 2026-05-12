@extends('admin.layouts.app')

@section('title', 'Sales Profit')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Sales Profit</h1>
            <div class="admin-topbar__subtitle">
                Pantau omzet, modal, dan profit kotor dari setiap barang yang keluar, termasuk item manual yang dimasukkan saat transaksi.
            </div>
        </div>
        <a href="{{ route('admin.sales-profit.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="admin-grid admin-grid--stats" style="margin-bottom: 18px;">
        <div class="card stat-card">
            <div class="stat-card__label">Total Transaksi</div>
            <div class="stat-card__value">{{ number_format((int) $summary['transaction_count']) }}</div>
            <div class="stat-card__hint">Invoice yang masuk ke laporan ini.</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Total Omzet</div>
            <div class="stat-card__value">Rp {{ number_format((float) $summary['total_revenue'], 0, ',', '.') }}</div>
            <div class="stat-card__hint">Nilai jual dari seluruh item keluar.</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Total Modal</div>
            <div class="stat-card__value">Rp {{ number_format((float) $summary['total_cost'], 0, ',', '.') }}</div>
            <div class="stat-card__hint">Akumulasi modal berdasarkan snapshot transaksi.</div>
        </div>
        <div class="card stat-card">
            <div class="stat-card__label">Total Profit</div>
            <div class="stat-card__value">Rp {{ number_format((float) $summary['total_profit'], 0, ',', '.') }}</div>
            <div class="stat-card__hint">Margin {{ number_format((float) $summary['profit_margin_percent'], 2, ',', '.') }}%</div>
        </div>
    </div>

    <div class="card">
        <h2 class="card__title">Laporan Penjualan & Profit</h2>

        <form method="GET" class="filters">
            <div class="field">
                <label for="search">Cari</label>
                <input id="search" type="text" name="search" value="{{ $filters['search'] ?? '' }}" placeholder="Invoice, produk, kasir">
            </div>
            <div class="field">
                <label for="payment_method">Metode Pembayaran</label>
                <select id="payment_method" name="payment_method">
                    <option value="">Semua</option>
                    <option value="cash" @selected(($filters['payment_method'] ?? '') === 'cash')>Tunai</option>
                    <option value="non_cash" @selected(($filters['payment_method'] ?? '') === 'non_cash')>Non Tunai</option>
                    <option value="split" @selected(($filters['payment_method'] ?? '') === 'split')>Split</option>
                </select>
            </div>
            <div class="field">
                <label for="profit_status">Status Profit</label>
                <select id="profit_status" name="profit_status">
                    <option value="">Semua</option>
                    <option value="profit" @selected(($filters['profit_status'] ?? '') === 'profit')>Untung</option>
                    <option value="break_even" @selected(($filters['profit_status'] ?? '') === 'break_even')>Impas</option>
                    <option value="loss" @selected(($filters['profit_status'] ?? '') === 'loss')>Rugi</option>
                </select>
            </div>
            <div class="field">
                <label for="date_from">Dari Tanggal</label>
                <input id="date_from" type="date" name="date_from" value="{{ $filters['date_from'] ?? '' }}">
            </div>
            <div class="field">
                <label for="date_to">Sampai Tanggal</label>
                <input id="date_to" type="date" name="date_to" value="{{ $filters['date_to'] ?? '' }}">
            </div>
            <div class="field" style="align-self:end;">
                <button type="submit" class="button">Terapkan Filter</button>
            </div>
            <div class="field" style="align-self:end;">
                <a href="{{ route('admin.sales-profit.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Tanggal</th>
                        <th>Invoice</th>
                        <th>Produk</th>
                        <th>Qty</th>
                        <th>Metode</th>
                        <th>Harga Modal</th>
                        <th>Harga Jual</th>
                        <th>Total Modal</th>
                        <th>Total Jual</th>
                        <th>Profit</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($rows as $row)
                        <tr>
                            <td>
                                {{ \Illuminate\Support\Carbon::parse($row->transaction_date)->format('d M Y H:i') }}
                                <div class="list-item__meta">{{ $row->cashier_name }}</div>
                            </td>
                            <td><strong>{{ $row->invoice_number }}</strong></td>
                            <td>{{ $row->product_name_snapshot }}</td>
                            <td>{{ number_format((int) $row->quantity) }}</td>
                            <td>{{ ucfirst((string) $row->payment_method) }}</td>
                            <td>Rp {{ number_format((float) $row->cost_price_snapshot, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $row->selling_price_snapshot, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $row->total_cost, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $row->total_selling, 0, ',', '.') }}</td>
                            <td>
                                @php
                                    $profitValue = (float) $row->total_profit;
                                    $profitBadgeClass = $profitValue > 0
                                        ? 'badge badge--success'
                                        : ($profitValue < 0 ? 'badge badge--danger' : 'badge');
                                @endphp
                                <span class="{{ $profitBadgeClass }}">
                                    Rp {{ number_format($profitValue, 0, ',', '.') }}
                                </span>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="10"><div class="empty-state">Belum ada data penjualan yang cocok dengan filter ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $rows])
    </div>
@endsection
