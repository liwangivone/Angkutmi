<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Driver extends Model
{
    use HasFactory;
    protected $primaryKey = 'driver_id';
    /**
     * Fillable attributes for the Driver model.
     *
     * @var array
     */
    protected $fillable = [
        'user_id',        // Foreign key for User
        'vehicle_id',     // Foreign key for Vehicle
        'profile_picture' // Driver's profile picture
    ];

    /**
     * Get the trips associated with the driver.
     */
    public function trips()
    {
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
