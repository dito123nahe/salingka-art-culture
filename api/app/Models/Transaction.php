<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = ['booking_id', 'jenis', 'keterangan', 'jumlah', 'tanggal'];
}