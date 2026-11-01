<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Dance extends Model
{
    protected $fillable = ['nama_tari', 'deskripsi', 'status_aktif'];

    protected $casts = [
        'status_aktif' => 'boolean',
    ];

    public function roles()
    {
        return $this->belongsToMany(Role::class, 'dance_roles')
            ->withPivot('jumlah_orang');
    }
}