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
       Schema::create('honor_payments', function (Blueprint $table) {
    $table->id();
    $table->foreignId('booking_id')->constrained('bookings')->cascadeOnDelete();
    $table->foreignId('member_id')->constrained('members');
    $table->unsignedInteger('jumlah_penampilan');
    $table->decimal('jumlah_honor', 12, 2);
    $table->string('status_bayar')->default('belum');
    $table->date('tanggal_bayar')->nullable();
    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('honor_payments');
    }
};
