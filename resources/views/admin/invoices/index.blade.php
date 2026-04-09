@extends('admin.layouts.app')

@section('title', 'Invoices')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Invoices</h1>
            <div class="admin-topbar__subtitle">
                Rekap invoice Folony Kasir dengan filter tanggal, status pembayaran, dan metode pembayaran.
            </div>
        </div>
        <a href="{{ route('admin.invoices.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="card">
        <h2 class="card__title">Daftar Invoice</h2>

        <form method="GET" class="filters">
            <div class="field">
                <label for="search">Cari invoice</label>
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
                <a href="{{ route('admin.invoices.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Tanggal</th>
                        <th>Nomor Invoice</th>
                        <th>Nama</th>
                        <th>Total Item</th>
                        <th>Harga Total</th>
                        <th>Pembayaran</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($invoices as $invoice)
                        <tr>
                            <td>{{ $invoice->created_at?->format('d M Y H:i') }}</td>
                            <td><strong>{{ $invoice->invoice_number }}</strong></td>
                            <td>{{ $invoice->user?->name ?? $invoice->cashier_name_snapshot }}</td>
                            <td>{{ number_format($invoice->item_count) }} item</td>
                            <td>Rp {{ number_format((float) $invoice->grand_total, 0, ',', '.') }}</td>
                            <td>{{ ucfirst((string) $invoice->payment_method?->value ?? $invoice->payment_method) }}</td>
                            <td>
                                <span class="badge {{ ((string) $invoice->payment_status?->value ?? $invoice->payment_status) === 'paid' ? 'badge--success' : 'badge--warning' }}">
                                    {{ ((string) $invoice->payment_status?->value ?? $invoice->payment_status) === 'paid' ? 'Lunas' : 'Belum Lunas' }}
                                </span>
                            </td>
                            <td><a href="{{ route('admin.invoices.show', $invoice) }}" class="badge badge--primary">Detail</a></td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8"><div class="empty-state">Belum ada invoice yang cocok dengan filter ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $invoices])
    </div>
@endsection
