<?php

namespace App\Http\Controllers;

use App\Models\WheelOfFortune;
use App\Models\ProgressionBar;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Redemption;


class WheelOfFortuneController extends Controller
{
    public function spin()
    {
        // Get or create the user's progression bar
        $progressionBar = ProgressionBar::firstOrCreate([
            'user_id' => Auth::id(),
        ]);

        // Check if the progress bar is full
        if ($progressionBar->progress >= 100 && $progressionBar->reward_claimed) {
            return response()->json([
                'message' => 'Progress bar is full! Please claim your reward before spinning again.',
                'progress' => $progressionBar->progress,
                'reward_claimed' => $progressionBar->reward_claimed,
            ], 403);
        }

        // Get a random wheel slice
        $wheelSlice = WheelOfFortune::inRandomOrder()->first();

        if (!$wheelSlice) {
            return response()->json(['message' => 'Wheel configuration not found!'], 500);
        }

        // Update the progression bar
        $progressionBar->progress = min(100, $progressionBar->progress + $wheelSlice->percentage);

        // Check if progress bar is filled
        $progressBarFilled = false;
        if ($progressionBar->progress >= 100) {
            $progressionBar->reward_claimed = true;
            $progressBarFilled = true;
        }

        $progressionBar->save();

        return response()->json([
            'message' => $progressBarFilled ? 'Progress bar filled! Continue to claim your reward.' : 'Spin completed!',
            'slice' => $wheelSlice,
            'progress' => $progressionBar->progress,
            'reward_claimed' => $progressionBar->reward_claimed,
        ]);
    }

    public function claimReward()
    {
        $progressionBar = ProgressionBar::where('user_id', Auth::id())->firstOrFail();
    
        if ($progressionBar->reward_claimed) {
            // Retrieve the coupon that has available stock
            $coupon = Coupon::where('limit', '>', 0)->first();
    
            if (!$coupon) {
                return response()->json(['message' => 'No available coupons.'], 404);
            }
    
            // Store the coupon in the user_coupon_claims table with status 'claimed'
            \DB::table('user_coupon_claims')->insert([
                'user_id' => Auth::id(),
                'coupon_id' => $coupon->id,
                'status' => 'claimed',  // Status set as 'claimed'
                'created_at' => now(),
                'updated_at' => now(),
            ]);
    
            // Decrement the coupon limit to reflect it has been claimed but not redeemed
            $coupon->decrement('limit');
    
            // Reset the progression bar
            $progressionBar->progress = 0;
            $progressionBar->reward_claimed = false;
            $progressionBar->save();
    
            return response()->json([
                'message' => 'Reward claimed successfully, but not yet redeemed.',
                'coupon' => [
                    'code' => $coupon->code,
                    'product_name' => $coupon->product_name,
                    'expires_at' => $coupon->end_date,
                ],
            ]);
        }
    
        return response()->json(['message' => 'Reward not available'], 403);
    }
    
}
