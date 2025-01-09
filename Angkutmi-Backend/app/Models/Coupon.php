<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'code',
        'limit',
        'product_name',
        'start_date',
        'end_date',
        'picture_path', // Added picture_path to fillable
    ];

    /**
     * Get the start date in a formatted way.
     *
     * @return string|null
     */
    public function getFormattedStartDateAttribute()
    {
        return $this->start_date ? $this->start_date->format('Y-m-d') : null;
    }

    /**
     * Get the end date in a formatted way.
     *
     * @return string|null
     */
    public function getFormattedEndDateAttribute()
    {
        return $this->end_date ? $this->end_date->format('Y-m-d') : null;
    }

    /**
     * Check if the coupon is currently active.
     *
     * @return bool
     */
    public function isActive()
    {
        $now = now();

        return (!$this->start_date || $this->start_date <= $now) &&
               (!$this->end_date || $this->end_date >= $now);
    }

    /**
     * Decrease the usage limit by 1, if applicable.
     *
     * @return void
     */
    public function decrementLimit()
    {
        if (!is_null($this->limit) && $this->limit > 0) {
            $this->decrement('limit');
        }
    }

    /**
     * Define a relationship with the Redemption model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function redemptions()
    {
        return $this->hasMany(Redemption::class);
    }

    /**
     * Get the full URL of the picture if the path is stored.
     *
     * @return string|null
     */
    public function getPictureUrlAttribute()
    {
        return $this->picture_path ? asset('storage/' . $this->picture_path) : null;
    }
}
