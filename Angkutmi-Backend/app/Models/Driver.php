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

    /**
     * Get all trips associated with the driver.
     */
    public function trip()
    {
        return $this->hasMany(Trip::class);
    }

    /**
     * Get trips by a specific vehicle type.
     *
     * @param string $type
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function tripsByVehicleType(string $type)
    {
        return $this->trip()->where('vehicle_type', $type)->get();
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
