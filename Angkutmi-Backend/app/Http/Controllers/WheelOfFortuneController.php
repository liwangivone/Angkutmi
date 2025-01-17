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
    
        $user = Auth::user();
        
        // Fetch or create the user's progression bar
        $progressionBar = ProgressionBar::firstOrCreate(['user_id' => $user->id]);
        
        // Prevent spinning if the reward is not claimed after reaching 100%
        if ($progressionBar->progress >= 100 && $progressionBar->reward_claimed === false) {
            return response()->json([
                'message' => 'You must claim your reward before spinning again.',
                'progress' => $progressionBar->progress,
                'reward_claimed' => $progressionBar->reward_claimed,
            ], 403);
        }
        
        // Check if the user has completed 3 trips before being eligible for a spin
        if ($user->trip_count < 3) {
            return response()->json([
                'message' => 'You need to complete 3 trips before you can spin the wheel.',
                'trips_to_next_spin' => 3 - $user->trip_count,
            ], 403);
        }
        
        // Get a random wheel slice
        $wheelSlice = WheelOfFortune::inRandomOrder()->first();
        
        if (!$wheelSlice) {
            return response()->json(['message' => 'Wheel configuration not found!'], 500);
        }
        
        // Update the progression bar
        $progressionBar->progress = min(100, $progressionBar->progress + $wheelSlice->percentage);
        
        // Check if the progress bar has reached 100 and mark the reward as claimed
        $progressBarFilled = false;
        if ($progressionBar->progress >= 100) {
            $progressionBar->reward_claimed = false; // Set to false until the user claims the reward
            $progressBarFilled = true;
        }
        
        // Reset the user's trip count to 0 after spinning
        $user->trip_count = 0;
        $user->save();
        
        // Save the updated progression bar
        $progressionBar->save();
        
        // Return the response
        return response()->json([
            'message' => $progressBarFilled ? 'Progress bar filled! Claim your reward before spinning again.' : 'Spin completed!',
            'slice' => [
                'label' => $wheelSlice->label,
                'percentage' => $wheelSlice->percentage,
                'image' => $wheelSlice->image ?? null,
            ],
            'progress' => $progressionBar->progress,
            'reward_claimed' => $progressionBar->reward_claimed,
        ]);
    }
    
    
    // Claim reward
    public function claimReward()
    {
        // Ensure the user is authenticated
        if (!Auth::check()) {
            return response()->json(['message' => 'User not authenticated.'], 401);
        }
        
        $progressionBar = ProgressionBar::where('user_id', Auth::id())->firstOrFail();
        
        // Check if the progress bar is full and reward is available to claim
        if ($progressionBar->progress < 100 || $progressionBar->reward_claimed === false) {
            return response()->json(['message' => 'You must fill the progress bar and claim your reward before proceeding.'], 403);
        }
        
        // Retrieve a coupon with available stock
        $coupon = Coupon::where('limit', '>', 0)->first();
        
        if (!$coupon) {
            return response()->json(['message' => 'No available coupons.'], 404);
        }
        
        // Store the coupon claim in the user_coupon_claims table
        \DB::table('user_coupon_claims')->insert([
            'user_id' => Auth::id(),
            'coupon_id' => $coupon->id,
            'status' => 'claimed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        
        // Decrease the coupon limit (claiming the coupon)
        $coupon->decrement('limit');
        
        // Reset the progression bar
        $progressionBar->progress = 0;
        $progressionBar->reward_claimed = false; // Reset reward claim status
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

    // Get user's progression bar progress
// Get user's progression bar progress
public function getProgress()
{
    // Ensure the user is authenticated
    if (!Auth::check()) {
        return response()->json(['message' => 'User not authenticated.'], 401);
    }

    // Fetch the user's progression bar
    $progressionBar = ProgressionBar::where('user_id', Auth::id())->first();

    // If the progression bar doesn't exist, return an error message
    if (!$progressionBar) {
        return response()->json(['message' => 'Progression bar not found.'], 404);
    }

    // Return the current progress value
    return response()->json([
        'progress' => $progressionBar->progress,
    ]);
}

}
