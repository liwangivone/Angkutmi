<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Trip extends Model
{
    use HasFactory;

    /**
     * fillable
     *
     * @var array
     */
    protected $fillable = [
        'trip_id',
        'driver_id',
        'user_id',
        'subscription_id',
        'is_started',
        'is_completed',
        'origin',
        'destination',
        'driver_location',
        'reserve_datetime'
    ];

    public function user(){
        return $this->belongsTo(User::class);
    }
    public function driver(){
        return $this->belongsTo(Driver::class);
    }
    public function subscription(){
        return $this->belongsTo(Subscription::class);
    }
}
