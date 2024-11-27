<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Driver extends Model
{
    use HasFactory;
    /**
     * fillable
     *
     * @var array
     */
    protected $fillable = [
        'driver_id',
        'user_id',
        'vehicle_id',
        'phone_number',
        'full_name',
        'password',
        'profile_picture'
    ];

    public function trip(){
        return $this->hasMany(Trip::class);
    }

    /**
     * Get the user that owns the driver (user details like phone, password, etc.).
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the vehicle associated with the driver.
     */
    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class, 'vehicle_id');
    }
}
