<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingAssignment extends Model
{
    protected $fillable = ['booking_dance_id', 'member_id', 'role_id'];

    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function bookingDance()
    {
        return $this->belongsTo(BookingDance::class);
    }
}