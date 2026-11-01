<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Member extends Model
{
    protected $fillable = ['nama', 'no_hp', 'status_aktif'];

    protected $casts = [
        'status_aktif' => 'boolean',
    ];

    public function roles()
    {
        return $this->belongsToMany(Role::class, 'member_roles');
    }
}