<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Dashboard Admin') - Folony Kasir</title>
    <style>
        :root {
            --bg: #f3f4f6;
            --surface: #ffffff;
            --surface-soft: #f9fafb;
            --text: #1f2937;
            --text-soft: #667085;
            --border: #e5e7eb;
            --primary: #f97316;
            --primary-soft: #fff2e9;
            --success: #166534;
            --warning: #b45309;
            --danger: #b91c1c;
            --shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
            --radius-lg: 22px;
            --radius-md: 16px;
            --radius-sm: 12px;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg);
            color: var(--text);
        }
        a { color: inherit; text-decoration: none; }
        .admin-shell { min-height: 100vh; display: grid; grid-template-columns: 280px minmax(0, 1fr); }
        .admin-sidebar {
            padding: 28px 22px;
            background: linear-gradient(180deg, #fff7f2 0%, #ffffff 100%);
            border-right: 1px solid var(--border);
            position: sticky;
            top: 0;
            height: 100vh;
        }
        .admin-brand { display: grid; gap: 6px; margin-bottom: 28px; }
        .admin-brand__title { font-size: 22px; font-weight: 600; }
        .admin-brand__caption { color: var(--text-soft); font-size: 14px; }
        .admin-nav { display: grid; gap: 10px; }
        .admin-nav__item {
            padding: 14px 16px;
            border-radius: var(--radius-md);
            color: var(--text-soft);
            font-weight: 500;
        }
        .admin-nav__item.is-active { background: var(--primary-soft); color: var(--primary); }
        .admin-sidebar__footer {
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid var(--border);
            display: grid;
            gap: 8px;
        }
        .admin-user-badge {
            padding: 14px 16px;
            border-radius: var(--radius-md);
            background: var(--surface);
            border: 1px solid var(--border);
        }
        .admin-user-badge__name { font-weight: 500; }
        .admin-user-badge__meta { color: var(--text-soft); font-size: 13px; margin-top: 4px; }
        .admin-logout {
            width: 100%;
            border: 0;
            border-radius: var(--radius-md);
            background: #111827;
            color: white;
            font: inherit;
            padding: 12px 14px;
            cursor: pointer;
            font-weight: 500;
        }
        .admin-main { padding: 28px; }
        .admin-topbar {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 24px;
        }
        .admin-topbar__title { font-size: 30px; font-weight: 600; margin: 0; letter-spacing: -0.01em; }
        .admin-topbar__subtitle { margin-top: 8px; color: var(--text-soft); max-width: 720px; }
        .admin-grid { display: grid; gap: 18px; }
        .admin-grid--stats { grid-template-columns: repeat(4, minmax(0, 1fr)); }
        .admin-grid--two { grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr); }
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
            padding: 22px;
        }
        .card__title { margin: 0; font-size: 18px; font-weight: 600; }
        .card__subtitle { color: var(--text-soft); margin-top: 8px; font-size: 14px; }
        .stat-card__label { color: var(--text-soft); font-size: 14px; }
        .stat-card__value { font-size: 27px; font-weight: 600; margin-top: 10px; }
        .stat-card__hint { margin-top: 10px; color: var(--text-soft); font-size: 13px; }
        .filters { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 12px; margin-top: 18px; }
        .filters--compact { grid-template-columns: repeat(4, minmax(0, 1fr)); }
        .field { display: grid; gap: 8px; }
        .field label { font-size: 13px; font-weight: 600; color: var(--text-soft); }
        .field input, .field select {
            width: 100%;
            min-height: 44px;
            padding: 0 14px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            background: white;
            font: inherit;
        }
        .button {
            min-height: 44px;
            border-radius: var(--radius-sm);
            border: 0;
            background: var(--primary);
            color: white;
            padding: 0 16px;
            font: inherit;
            font-weight: 500;
            cursor: pointer;
        }
        .button--ghost { background: white; border: 1px solid var(--border); color: var(--text); }
        .table-wrapper { overflow: auto; margin-top: 18px; }
        table { width: 100%; border-collapse: collapse; }
        th, td {
            padding: 14px 12px;
            border-bottom: 1px solid var(--border);
            vertical-align: top;
            text-align: left;
            font-size: 14px;
        }
        th { font-size: 12px; letter-spacing: 0.03em; text-transform: uppercase; color: var(--text-soft); }
        .badge {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 8px 12px;
            font-size: 12px;
            font-weight: 500;
            background: var(--surface-soft);
            color: var(--text-soft);
        }
        .badge--success { background: #ecfdf3; color: var(--success); }
        .badge--warning { background: #fff7ed; color: var(--warning); }
        .badge--danger { background: #fef2f2; color: var(--danger); }
        .badge--primary { background: var(--primary-soft); color: var(--primary); }
        .stack { display: grid; gap: 16px; }
        .list { display: grid; gap: 12px; margin-top: 18px; }
        .list-item {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            padding: 14px 16px;
            border-radius: var(--radius-md);
            background: var(--surface-soft);
            border: 1px solid var(--border);
        }
        .list-item__title { font-weight: 500; }
        .list-item__meta { margin-top: 6px; color: var(--text-soft); font-size: 13px; }
        .detail-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; margin-top: 18px; }
        .detail-card {
            padding: 16px;
            background: var(--surface-soft);
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
        }
        .detail-card__label { color: var(--text-soft); font-size: 13px; }
        .detail-card__value { margin-top: 8px; font-size: 18px; font-weight: 600; }
        .empty-state {
            padding: 24px;
            border-radius: var(--radius-md);
            border: 1px dashed var(--border);
            background: var(--surface-soft);
            color: var(--text-soft);
            text-align: center;
        }
        .admin-pagination {
            margin-top: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .admin-pagination__meta, .admin-pagination__current { color: var(--text-soft); font-size: 14px; }
        .admin-pagination__actions { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
        .admin-pagination__button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 40px;
            padding: 0 14px;
            border-radius: 999px;
            background: white;
            border: 1px solid var(--border);
            color: var(--text);
            font-weight: 500;
        }
        strong { font-weight: 600; }
        .admin-pagination__button.is-disabled { color: #9ca3af; cursor: default; }
        .alert {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: var(--radius-md);
            border: 1px solid #fed7aa;
            background: #fff7ed;
            color: #9a3412;
            font-weight: 600;
        }
        @media (max-width: 1100px) {
            .admin-shell { grid-template-columns: 1fr; }
            .admin-sidebar {
                position: static;
                height: auto;
                border-right: 0;
                border-bottom: 1px solid var(--border);
            }
            .admin-grid--stats, .admin-grid--two, .filters, .filters--compact, .detail-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="admin-shell">
        <aside class="admin-sidebar">
            <div class="admin-brand">
                <div class="admin-brand__title">Folony Kasir</div>
                <div class="admin-brand__caption">Dashboard Admin v1</div>
            </div>

            <nav class="admin-nav">
                <a href="{{ route('admin.dashboard') }}" class="admin-nav__item {{ request()->routeIs('admin.dashboard') ? 'is-active' : '' }}">Dashboard</a>
                <a href="{{ route('admin.users.index') }}" class="admin-nav__item {{ request()->routeIs('admin.users.*') ? 'is-active' : '' }}">Users</a>
                <a href="{{ route('admin.invoices.index') }}" class="admin-nav__item {{ request()->routeIs('admin.invoices.*') ? 'is-active' : '' }}">Invoices</a>
                <a href="{{ route('admin.transactions.index') }}" class="admin-nav__item {{ request()->routeIs('admin.transactions.*') ? 'is-active' : '' }}">Transactions</a>
                <a href="{{ route('admin.products.index') }}" class="admin-nav__item {{ request()->routeIs('admin.products.*') ? 'is-active' : '' }}">Products</a>
                <a href="{{ route('admin.member-points.index') }}" class="admin-nav__item {{ request()->routeIs('admin.member-points.*') ? 'is-active' : '' }}">Member Points</a>
            </nav>

            <div class="admin-sidebar__footer">
                <div class="admin-user-badge">
                    <div class="admin-user-badge__name">{{ $adminUser['name'] ?? 'Admin Dashboard' }}</div>
                    <div class="admin-user-badge__meta">{{ $adminUser['email'] ?? config('admin-dashboard.email') }}</div>
                </div>

                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button type="submit" class="admin-logout">Keluar</button>
                </form>
            </div>
        </aside>

        <main class="admin-main">
            @if (session('status'))
                <div class="alert">{{ session('status') }}</div>
            @endif

            @yield('content')
        </main>
    </div>
</body>
</html>
