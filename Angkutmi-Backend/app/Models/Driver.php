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

    public function user(){
        return $this->hasMany(User::class);
    }

    public function vehicle(){
        return $this->hasMany(Vehicle::class);
    }
}
