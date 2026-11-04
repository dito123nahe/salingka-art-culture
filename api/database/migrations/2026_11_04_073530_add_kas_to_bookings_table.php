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
        Schema::table('bookings', function (Blueprint $table) {
               $table->string('kas_tipe')->default('nominal')->after('total_biaya');
        $table->decimal('kas_nilai', 12, 2)->default(0)->after('kas_tipe');//
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
        $table->dropColumn(['kas_tipe', 'kas_nilai']);
        });
    }
};
