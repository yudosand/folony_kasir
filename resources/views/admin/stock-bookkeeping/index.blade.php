@extends('admin.layouts.app')

@section('title', 'Stock Bookkeeping')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Stock Bookkeeping</h1>
            <div class="admin-topbar__subtitle">
                Pantau stok awal, mutasi masuk-keluar, status barang menipis, dan kebutuhan restock seluruh user Folony Kasir.
            </div>
        </div>
        <a href="{{ route('admin.stock-bookkeeping.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="card">
        <h2 class="card__title">Pembukuan Stok Global</h2>

        <form method="GET" class="filters">
            <div class="field">
                <label for="search">Cari produk</label>
                <input id="search" type="text" name="search" value="{{ $filters['search'] ?? '' }}" placeholder="Nama produk">
            </div>
            <div class="field">
                <label for="owner">Pemilik</label>
                <input id="owner" type="text" name="owner" value="{{ $filters['owner'] ?? '' }}" placeholder="Nama / nomor HP">
            </div>
            <div class="field">
                <label for="status">Status</label>
                <select id="status" name="status">
                    <option value="">Semua status</option>
                    <option value="healthy" @selected(($filters['status'] ?? '') === 'healthy')>Aman</option>
                    <option value="low" @selected(($filters['status'] ?? '') === 'low')>Menipis</option>
                    <option value="out" @selected(($filters['status'] ?? '') === 'out')>Habis</option>
                    <option value="restock" @selected(($filters['status'] ?? '') === 'restock')>Perlu restock</option>
                </select>
            </div>
            <div class="field">
                <label for="date_from">Dari tanggal</label>
                <input id="date_from" type="date" name="date_from" value="{{ $filters['date_from'] ?? '' }}">
            </div>
            <div class="field">
                <label for="date_to">Sampai tanggal</label>
                <input id="date_to" type="date" name="date_to" value="{{ $filters['date_to'] ?? '' }}">
            </div>
            <div class="field" style="align-self:end;">
                <button type="submit" class="button">Terapkan Filter</button>
            </div>
            <div class="field" style="align-self:end;">
                <a href="{{ route('admin.stock-bookkeeping.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Produk</th>
                        <th>Pemilik</th>
                        <th>Stok Awal</th>
                        <th>Awal Periode</th>
                        <th>Masuk</th>
                        <th>Keluar</th>
                        <th>Stok Kini</th>
                        <th>Min. Stok</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($products as $product)
                        <tr>
                            <td>
                                <strong>{{ $product->name }}</strong>
                                <div class="list-item__meta">{{ $product->created_at?->format('d M Y') }}</div>
                            </td>
                            <td>{{ $product->user?->name ?? '-' }}</td>
                            <td>{{ number_format((int) ($product->initial_stock ?? 0)) }}</td>
                            <td>{{ number_format((int) ($product->stock_at_period_start ?? 0)) }}</td>
                            <td>{{ number_format((int) ($product->stock_in ?? 0)) }}</td>
                            <td>{{ number_format((int) ($product->stock_out ?? 0)) }}</td>
                            <td>{{ number_format((int) $product->stock) }}</td>
                            <td>{{ number_format((int) $product->minimum_stock) }}</td>
                            <td>
                                @php
                                    $badgeClass = match ($product->stock_status ?? 'healthy') {
                                        'out' => 'badge badge--danger',
                                        'low' => 'badge badge--warning',
                                        default => 'badge badge--success',
                                    };
                                @endphp
                                <span class="{{ $badgeClass }}">{{ $product->stock_status_label ?? 'Aman' }}</span>
                            </td>
                            <td><a href="{{ route('admin.stock-bookkeeping.show', $product) }}" class="badge badge--primary">Detail</a></td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="10"><div class="empty-state">Belum ada data pembukuan stok yang cocok dengan filter ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $products])
    </div>
@endsection
