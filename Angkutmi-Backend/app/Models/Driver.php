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
        'phone_number',
        'vehicle_id',
        'full_name',
        'password',
        'profile_picture'
    ];

    public function trips(){
        return $this->hasMany(Trip::class);
    }
}
