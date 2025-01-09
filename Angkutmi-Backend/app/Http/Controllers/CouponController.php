<?php

namespace App\Http\Controllers;

use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\Response;

class CouponController extends Controller
{
    /**
     * Store a newly created coupon.
     */
    public function store(Request $request): JsonResponse
    {
        // Validate the request
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|unique:coupons,code',
            'limit' => 'nullable|integer',
            'product_name' => 'required|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'picture_path' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048', // Validate picture file
        ]);

        // Check if validation fails
        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        // Process picture file if provided
        $picturePath = null;
        if ($request->hasFile('picture_path')) {
            $picturePath = $request->file('picture_path')->store('coupon_pictures', 'public');
        }

        // Create the coupon using validated data
        $coupon = Coupon::create(array_merge(
            $validator->validated(),
            ['picture_path' => $picturePath]
        ));

        return response()->json([
            'message' => 'Coupon created successfully.',
            'data' => $coupon
        ], Response::HTTP_CREATED);
    }

    /**
     * Get all active coupons.
     */
    public function get(): JsonResponse
    {
        $coupons = Coupon::all();

        return response()->json([
            'message' => 'Coupons retrieved successfully.',
            'data' => $coupons->map(function ($coupon) {
                return [
                    'id' => $coupon->id,
                    'code' => $coupon->code,
                    'product_name' => $coupon->product_name,
                    'start_date' => $coupon->start_date,
                    'end_date' => $coupon->end_date,
                    'picture_url' => $coupon->picture_path ? asset('storage/' . $coupon->picture_path) : null,
                ];
            }),
        ], Response::HTTP_OK);
    }

    /**
     * Redeem a coupon.
     */
    public function redeem(Request $request): JsonResponse
    {
        $user = $request->user();
        $code = $request->input('code');

        // Find the coupon by code
        $coupon = Coupon::where('code', $code)->first();

        if (!$coupon) {
            return response()->json(['message' => 'Invalid coupon code.'], Response::HTTP_BAD_REQUEST);
        }

        if ($coupon->limit !== null && $coupon->limit <= 0) {
            return response()->json(['message' => 'This coupon is no longer available.'], Response::HTTP_BAD_REQUEST);
        }

        $redemption = $user->redemptions()->where('coupon_id', $coupon->id)->first();

        if (!$redemption) {
            return response()->json(['message' => 'You have not claimed this coupon.'], Response::HTTP_BAD_REQUEST);
        }

        if ($redemption->status == 'redeemed') {
            return response()->json(['message' => 'You have already redeemed this coupon.'], Response::HTTP_BAD_REQUEST);
        }

        $redemption->status = 'redeemed';
        $redemption->save();

        if ($coupon->limit !== null) {
            $coupon->decrement('limit');
        }

        return response()->json([
            'message' => 'Coupon redeemed successfully.',
            'data' => [
                'product_name' => $coupon->product_name,
                'redeemed_at' => now(),
                'picture_url' => $coupon->picture_path ? asset('storage/' . $coupon->picture_path) : null,
            ],
        ], Response::HTTP_OK);
    }

    /**
     * Get all claimed coupons for the user.
     */
public function storeClaimedCoupon(Request $request): JsonResponse
{
    // Check if the user is authenticated
    $user = $request->user();

    if (!$user) {
        \Log::error("User not found or not authenticated.");
        return response()->json(['message' => 'User not authenticated.'], Response::HTTP_UNAUTHORIZED);
    }

    // Get the coupon ID from the request body
    $couponId = $request->input('coupon_id');

    if (empty($couponId)) {
        \Log::error("No coupon ID provided in the request.");
        return response()->json(['message' => 'Coupon ID is required.'], Response::HTTP_BAD_REQUEST);
    }

    \Log::info("Coupon ID received: " . $couponId); // Log the coupon ID

    // Ensure couponId is a valid integer
    if (!is_numeric($couponId) || (int) $couponId <= 0) {
        \Log::error("Invalid coupon ID: " . $couponId);
        return response()->json(['message' => 'Invalid coupon ID provided.'], Response::HTTP_BAD_REQUEST);
    }

    // Find the coupon by ID
    $coupon = Coupon::find($couponId);

    // Check if the coupon exists
    if (!$coupon) {
        \Log::error("Coupon not found for ID: " . $couponId); // Log if coupon is not found
        return response()->json(['message' => 'Coupon not found.'], Response::HTTP_NOT_FOUND);
    }

    // Check if the coupon has been soft deleted
    if ($coupon->trashed()) {
        \Log::error("Coupon with ID " . $couponId . " is deleted.");
        return response()->json(['message' => 'This coupon has been deleted.'], Response::HTTP_BAD_REQUEST);
    }

    // Check if the coupon is still available (limit not exceeded)
    if ($coupon->limit !== null && $coupon->limit <= 0) {
        \Log::warning("Coupon limit exceeded for ID: " . $couponId);
        return response()->json(['message' => 'This coupon is no longer available.'], Response::HTTP_BAD_REQUEST);
    }

    // Check if the user has already claimed this coupon (prevents double claims)
    $existingClaim = \DB::table('user_coupon_claims')
                        ->where('user_id', $user->id)
                        ->where('coupon_id', $coupon->id)
                        ->where('status', 'claimed')
                        ->exists();

    if ($existingClaim) {
        \Log::warning("User ID " . $user->id . " has already claimed coupon ID " . $couponId);
        return response()->json(['message' => 'You have already claimed this coupon.'], Response::HTTP_BAD_REQUEST);
    }

    // Attempt to insert the claimed coupon into the user_coupon_claims table
    try {
        \DB::table('user_coupon_claims')->insert([
            'user_id' => $user->id,
            'coupon_id' => $coupon->id,
            'status' => 'claimed',  // Set status as 'claimed'
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    } catch (\Exception $e) {
        \Log::error("Error inserting claimed coupon: " . $e->getMessage());
        return response()->json(['message' => 'An error occurred while claiming the coupon. Please try again later.'], Response::HTTP_INTERNAL_SERVER_ERROR);
    }

    // Decrement the coupon's limit if applicable
    try {
        if ($coupon->limit !== null) {
            $coupon->decrement('limit');
        }
    } catch (\Exception $e) {
        \Log::error("Error decrementing coupon limit for ID " . $couponId . ": " . $e->getMessage());
        return response()->json(['message' => 'An error occurred while updating the coupon limit.'], Response::HTTP_INTERNAL_SERVER_ERROR);
    }

    // Return the response with the coupon details, including the picture URL
    try {
        return response()->json([
            'message' => 'Coupon claimed successfully, but not yet redeemed.',
            'data' => [
                'product_name' => $coupon->product_name,
                'status' => 'claimed',
                'picture_url' => $coupon->picture_path ? asset('storage/' . $coupon->picture_path) : null, // Add the picture_url here
            ],
        ], Response::HTTP_OK);
    } catch (\Exception $e) {
        \Log::error("Error preparing response for claimed coupon: " . $e->getMessage());
        return response()->json(['message' => 'An error occurred while preparing the response. Please try again later.'], Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

    

    /**
 * Get a specific coupon by ID or code.
 */
public function show($id): JsonResponse
{
    // Retrieve the coupon by ID
    $coupon = Coupon::find($id);

    if (!$coupon) {
        return response()->json([
            'message' => 'Coupon not found.'
        ], Response::HTTP_NOT_FOUND);
    }

    return response()->json([
        'message' => 'Coupon retrieved successfully.',
        'data' => [
            'id' => $coupon->id,
            'code' => $coupon->code,
            'product_name' => $coupon->product_name,
            'start_date' => $coupon->start_date,
            'end_date' => $coupon->end_date,
            'picture_url' => $coupon->picture_path ? asset('storage/' . $coupon->picture_path) : null,
        ],
    ], Response::HTTP_OK);
}

}
