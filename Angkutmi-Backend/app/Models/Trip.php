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
        'user_id',
        'driver_id',
        'subscription_id',
        'is_started',
        'is_completed',
        'origin',
        'destination',
        'driver_location',
        'reserve_datetime'
    ];

    protected $casts = [
        'origin' => 'array',
        'destination' =>'array',
        'driver_location' => 'array',
        'is_started'=>'boolean',
        'is_completed'=>'boolean',

    ];

    public function user(){
        return $this->belongsTo(User::class);
    }
    public function driver()
    {
        return $this->belongsTo(Driver::class, 'driver_id', 'id');
    }
    
    public function subscription(){
        return $this->belongsTo(Subscription::class);
    }
}
