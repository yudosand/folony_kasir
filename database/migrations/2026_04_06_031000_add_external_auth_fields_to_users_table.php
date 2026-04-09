<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('email')->nullable()->change();
            $table->string('phone', 30)->nullable()->unique()->after('email');
            $table->string('external_member_id')->nullable()->unique()->after('phone');
            $table->string('account_type')->nullable()->after('external_member_id');
            $table->string('default_lat', 50)->nullable()->after('account_type');
            $table->string('default_long', 50)->nullable()->after('default_lat');
            $table->text('external_auth_token')->nullable()->after('default_long');
            $table->json('external_profile_payload')->nullable()->after('external_auth_token');
            $table->timestamp('external_synced_at')->nullable()->after('external_profile_payload');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'phone',
                'external_member_id',
                'account_type',
                'default_lat',
                'default_long',
                'external_auth_token',
                'external_profile_payload',
                'external_synced_at',
            ]);

            $table->string('email')->nullable(false)->change();
        });
    }
};
