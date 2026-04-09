@extends('admin.layouts.app')

@section('title', 'Users')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Users</h1>
            <div class="admin-topbar__subtitle">
                Daftar pengguna Folony Kasir beserta jumlah transaksi, total produk, dan waktu bergabung.
            </div>
        </div>
        <a href="{{ route('admin.users.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="card">
        <h2 class="card__title">Daftar User</h2>
        <form method="GET" class="filters filters--compact">
            <div class="field">
                <label for="search">Cari user</label>
                <input id="search" type="text" name="search" value="{{ $filters['search'] ?? '' }}" placeholder="Nama, HP, email, member id">
            </div>
            <div class="field" style="align-self:end;">
                <button type="submit" class="button">Terapkan Filter</button>
            </div>
            <div class="field" style="align-self:end;">
                <a href="{{ route('admin.users.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Kontak</th>
                        <th>Tanggal Bergabung</th>
                        <th>Total Transaksi</th>
                        <th>Total Produk</th>
                        <th>Omzet</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($users as $user)
                        <tr>
                            <td>
                                <strong>{{ $user->name }}</strong>
                                @if ($user->storeSetting?->store_name)
                                    <div class="list-item__meta">{{ $user->storeSetting->store_name }}</div>
                                @endif
                            </td>
                            <td>
                                <div>{{ $user->phone ?: '-' }}</div>
                                <div class="list-item__meta">{{ $user->email ?: '-' }}</div>
                            </td>
                            <td>{{ $user->created_at?->format('d M Y') }}</td>
                            <td>{{ number_format($user->transactions_count) }}</td>
                            <td>{{ number_format($user->products_count) }}</td>
                            <td>Rp {{ number_format((float) ($user->total_transaction_value ?? 0), 0, ',', '.') }}</td>
                            <td><a href="{{ route('admin.users.show', $user) }}" class="badge badge--primary">Detail</a></td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7"><div class="empty-state">Belum ada user yang cocok dengan filter ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $users])
    </div>
@endsection
