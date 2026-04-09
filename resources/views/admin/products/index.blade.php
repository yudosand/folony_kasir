@extends('admin.layouts.app')

@section('title', 'Products')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Products</h1>
            <div class="admin-topbar__subtitle">
                Daftar produk global milik seluruh user Folony Kasir untuk melihat stok, harga, dan aktivitas penjualan dasar.
            </div>
        </div>
        <a href="{{ route('admin.products.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="card">
        <h2 class="card__title">Daftar Produk</h2>

        <form method="GET" class="filters filters--compact">
            <div class="field">
                <label for="search">Cari produk</label>
                <input id="search" type="text" name="search" value="{{ $filters['search'] ?? '' }}" placeholder="Nama produk atau user">
            </div>
            <div class="field">
                <label for="owner">Pemilik</label>
                <input id="owner" type="text" name="owner" value="{{ $filters['owner'] ?? '' }}" placeholder="Nama user">
            </div>
            <div class="field" style="align-self:end;">
                <button type="submit" class="button">Terapkan Filter</button>
            </div>
            <div class="field" style="align-self:end;">
                <a href="{{ route('admin.products.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Produk</th>
                        <th>Pemilik</th>
                        <th>Stok</th>
                        <th>Harga Modal</th>
                        <th>Harga Jual</th>
                        <th>Terjual</th>
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
                            <td>{{ number_format($product->stock) }}</td>
                            <td>Rp {{ number_format((float) $product->cost_price, 0, ',', '.') }}</td>
                            <td>Rp {{ number_format((float) $product->selling_price, 0, ',', '.') }}</td>
                            <td>{{ number_format((int) ($product->total_quantity_sold ?? 0)) }}</td>
                            <td><a href="{{ route('admin.products.show', $product) }}" class="badge badge--primary">Detail</a></td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7"><div class="empty-state">Belum ada produk yang cocok dengan filter ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $products])
    </div>
@endsection
