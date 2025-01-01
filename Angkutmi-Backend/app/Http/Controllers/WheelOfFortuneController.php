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
    // Spin the wheel
    public function spin()
    {
        // Ensure the user is authenticated
        if (!Auth::check()) {
            return response()->json(['message' => 'User not authenticated.'], 401);
        }
    
        // Get the current user's ID
        $userId = Auth::id();
    
        // Get or create the user's progression bar
        $progressionBar = ProgressionBar::firstOrCreate([
            'user_id' => $userId,
        ]);
        
        // Check if the progress bar is full and the reward has already been claimed
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
    
        // Update the progression bar with the new progress
        $progressionBar->progress = min(100, $progressionBar->progress + $wheelSlice->percentage);
    
        // Check if the progress bar has reached 100 and mark the reward as claimed
        $progressBarFilled = false;
        if ($progressionBar->progress >= 100) {
            $progressionBar->reward_claimed = true;
            $progressBarFilled = true;
        }
    
        // Save the updated progression bar
        $progressionBar->save();
    
        // Return the response with the updated details
        return response()->json([
            'message' => $progressBarFilled ? 'Progress bar filled! Continue to claim your reward.' : 'Spin completed!',
            'slice' => [
                'label' => $wheelSlice->label,
                'percentage' => $wheelSlice->percentage,
                'image' => $wheelSlice->image ?? null,  // Assuming the WheelOfFortune model has an image attribute
            ],
            'progress' => $progressionBar->progress,
            'reward_claimed' => $progressionBar->reward_claimed,
        ]);
    }
    
    // Claim reward
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

    // Get all wheel slices (configuration)
    public function getWheelSlices()
    {
        // Fetch all available slices from the database
        $wheelSlices = WheelOfFortune::all();
    
        if ($wheelSlices->isEmpty()) {
            return response()->json(['message' => 'No wheel slices found.'], 404);
        }

        // Return the slices in a response
        return response()->json([
            'data' => $wheelSlices
        ]);
    }

    // Create a new wheel slice (admin feature)
    public function createWheelSlice(Request $request)
    {
        // Validate input data
        $validatedData = $request->validate([
            'label' => 'required|string|max:255',
            'percentage' => 'required|integer|min:1|max:100',
            'image' => 'nullable|string', // Assuming image is a URL or base64 encoded image string
        ]);
        
        // Create a new wheel slice
        $wheelSlice = new WheelOfFortune([
            'label' => $validatedData['label'],
            'percentage' => $validatedData['percentage'],
            'image' => $validatedData['image'] ?? null,
        ]);
        
        $wheelSlice->save();
    
        return response()->json([
            'message' => 'Wheel slice created successfully.',
            'slice' => $wheelSlice
        ], 201);
    }

    // Update an existing wheel slice (admin feature)
    public function updateWheelSlice($id, Request $request)
    {
        // Find the wheel slice by ID
        $wheelSlice = WheelOfFortune::findOrFail($id);
        
        // Validate input data
        $validatedData = $request->validate([
            'label' => 'nullable|string|max:255',
            'percentage' => 'nullable|integer|min:1|max:100',
            'image' => 'nullable|string', // Assuming image is a URL or base64 encoded image string
        ]);
        
        // Update the wheel slice
        $wheelSlice->update($validatedData);
    
        return response()->json([
            'message' => 'Wheel slice updated successfully.',
            'slice' => $wheelSlice
        ]);
    }

    // Delete an existing wheel slice (admin feature)
    public function deleteWheelSlice($id)
    {
        // Find the wheel slice by ID
        $wheelSlice = WheelOfFortune::findOrFail($id);
        
        // Delete the wheel slice
        $wheelSlice->delete();
    
        return response()->json([
            'message' => 'Wheel slice deleted successfully.'
        ]);
    }
}
