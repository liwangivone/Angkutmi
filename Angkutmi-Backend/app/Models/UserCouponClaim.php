<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserCouponClaim extends Model
{
    use HasFactory;

    // Define the table name if it's different from the plural form of the model name
    protected $table = 'user_coupon_claims';

    // Define the fillable attributes
    protected $fillable = [
        'user_id',
        'coupon_id',
        'status',
    ];

    // Define the relationships

    /**
     * Get the user that owns the coupon claim.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the coupon that the user claimed.
     */
    public function coupon()
    {
        return $this->belongsTo(Coupon::class);
    }
}
