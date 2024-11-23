<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubscriptionPayment extends Model
{
    use HasFactory;

    /**
     * fillable
     *
     * @var array
     */
    protected $fillable = [
        'subscription_id',
        'payment_id',
        'subscription_price',
        'payment_status'
    ];

    public function subscription(){
        return $this->belongsTo(Subscription::class);
    }
    public function payment(){
        return $this->belongsTo(Payment::class);
    }
}
