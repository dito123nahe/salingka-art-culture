<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $fillable = [
        'client_id', 'jenis_acara', 'tanggal', 'jam_mulai', 'jam_selesai',
        'lokasi', 'link_maps', 'total_biaya', 'status', 'catatan',
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    public function dances()
    {
        return $this->belongsToMany(Dance::class, 'booking_dances')
            ->withTimestamps();
    }
}