<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vehicle extends Model
{
    use HasFactory;

    /**
     * fillable
     *
     * @var array
     */
    protected $fillable = [
        'vehicle_id',
        'type',
        'capacity',
        'plat'
    ];

    public function drivers()
{
    return $this->hasMany(Driver::class, 'vehicle_id');
}

}
