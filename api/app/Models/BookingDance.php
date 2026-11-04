<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingDance extends Model
{
    protected $fillable = ['booking_id', 'dance_id'];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function dance()
    {
        return $this->belongsTo(Dance::class);
    }

    public function assignments()
    {
        return $this->hasMany(BookingAssignment::class);
    }
}