<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    /**
     * fillable
     *
     * @var array
     */
    protected $fillable = [
        'trip_id',
        'payment_id',
        'payment_type'
    ];

    // In Payment model
public function trip()
{
    return $this->belongsTo(Trip::class);
}

}
