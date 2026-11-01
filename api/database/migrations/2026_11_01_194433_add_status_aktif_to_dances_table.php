<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::table('dances', function (Blueprint $table) {
        $table->boolean('status_aktif')->default(true)->after('deskripsi');
    });
}

public function down(): void
{
    Schema::table('dances', function (Blueprint $table) {
        $table->dropColumn('status_aktif');
    });
}
};
