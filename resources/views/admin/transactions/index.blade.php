@extends('admin.layouts.app')

@section('title', 'Transactions')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Transactions</h1>
            <div class="admin-topbar__subtitle">
                Monitoring operasional transaksi Folony Kasir, termasuk nominal dibayar, kurang bayar, dan penggunaan poin member.
            </div>
        </div>
        <a href="{{ route('admin.transactions.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="card">
        <h2 class="card__title">Daftar Transaksi</h2>

        <form method="GET" class="filters">
            <div class="field">
                <label for="search">Cari transaksi</label>
                <input id="search" type="text" name="search" value="{{ $filters['search'] ?? '' }}" placeholder="Invoice, user, member">
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
                <label for="payment_status">Status</label>
                <select id="payment_status" name="payment_status">
                    <option value="">Semua</option>
                    <option value="paid" @selected(($filters['payment_status'] ?? '') === 'paid')>Lunas</option>
                    <option value="partial" @selected(($filters['payment_status'] ?? '') === 'partial')>Belum Lunas</option>
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
                <a href="{{ route('admin.transactions.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Tanggal</th>
                        <th>Invoice</th>
                        <th>User</th>
                        <th>Metode</th>
                        <th>Grand Total</th>
                        <th>Total Dibayar</th>
                        <th>Kurang Bayar</th>
                        <th>Poin</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($transactions as $transaction)
                        <tr>
                            <td>{{ $transaction->created_at?->format('d M Y H:i') }}</td>
                            <td><a href="{{ route('admin.invoices.show', $transaction) }}"><strong>{{ $transaction->invoice_number }}</strong></a></td>
                            <td>{{ $transaction->user?->name ?? $transaction->cashier_name_snapshot }}</td>
                            <td>{{ ucfirst((string) $transaction->payment_method?->value ?? $transaction->payment_method) }}</td>
                            <td>Rp {{ number_format((float) $transaction->grand_total, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $transaction->amount_paid + (float) $transaction->member_points_value_amount, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $transaction->due_amount, 0, ',', '.') }}</td>
                            <td>{{ number_format((int) $transaction->member_points_used) }} poin</td>
                            <td>
                                <span class="badge {{ ((string) $transaction->payment_status?->value ?? $transaction->payment_status) === 'paid' ? 'badge--success' : 'badge--warning' }}">
                                    {{ ((string) $transaction->payment_status?->value ?? $transaction->payment_status) === 'paid' ? 'Lunas' : 'Belum Lunas' }}
                                </span>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="9"><div class="empty-state">Belum ada transaksi yang cocok dengan filter ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $transactions])
    </div>
@endsection
