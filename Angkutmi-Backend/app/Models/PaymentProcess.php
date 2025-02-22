<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentProcess extends Model
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
        'base_price',
        'final_price',
        'payment_status'
    ];

    public function trip(){
        return $this->belongsTo(Trip::class);
    }
    public function payment(){
        return $this->belongsTo(Payment::class);
    }
}
