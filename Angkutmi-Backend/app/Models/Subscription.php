<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;

    /**
     * fillable
     *
     * @var array
     */
    protected $fillable = [
        'subscription_id',
        'user_id',
        'duration',
        'purchase_date',
        'expired_date',
        'discount_rate'
    ];

    public function user(){
        return $this->belongsTo(User::class);
    }
}
