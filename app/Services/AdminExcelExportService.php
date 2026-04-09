<?php

namespace App\Services;

use Illuminate\Http\Response;
use Illuminate\Support\Str;

class AdminExcelExportService
{
    public function download(string $fileLabel, string $title, array $headers, array $rows): Response
    {
        $filename = $this->safeFilename($fileLabel).'.xls';

        return response($this->buildHtml($title, $headers, $rows), 200, [
            'Content-Type' => 'application/vnd.ms-excel; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="'.$filename.'"',
            'Cache-Control' => 'max-age=0, no-cache, no-store, must-revalidate',
            'Pragma' => 'public',
        ]);
    }

    private function buildHtml(string $title, array $headers, array $rows): string
    {
        $headCells = collect($headers)
            ->map(fn (string $header) => '<th>'.$this->escape($header).'</th>')
            ->implode('');

        $bodyRows = collect($rows)
            ->map(function (array $row) {
                $cells = collect($row)
                    ->map(fn ($value) => '<td>'.$this->escape((string) $value).'</td>')
                    ->implode('');

                return '<tr>'.$cells.'</tr>';
            })
            ->implode('');

        return <<<HTML
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; }
        h1 { font-size: 20px; margin-bottom: 16px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #d1d5db; padding: 8px 10px; font-size: 12px; text-align: left; }
        th { background: #fff2e9; color: #9a3412; font-weight: 700; }
    </style>
</head>
<body>
    <h1>{$this->escape($title)}</h1>
    <table>
        <thead>
            <tr>{$headCells}</tr>
        </thead>
        <tbody>
            {$bodyRows}
        </tbody>
    </table>
</body>
</html>
HTML;
    }

    private function safeFilename(string $value): string
    {
        return Str::of($value)
            ->lower()
            ->replaceMatches('/[^a-z0-9_-]+/', '_')
            ->trim('_')
            ->value();
    }

    private function escape(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}
