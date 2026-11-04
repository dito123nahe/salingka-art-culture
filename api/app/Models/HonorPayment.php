<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HonorPayment extends Model
{
    protected $fillable = [
        'booking_id', 'member_id', 'jumlah_penampilan',
        'jumlah_honor', 'status_bayar', 'tanggal_bayar',
    ];

    public function member()
    {
        return $this->belongsTo(Member::class);
    }
}