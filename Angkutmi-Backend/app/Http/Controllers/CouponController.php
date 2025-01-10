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
    
    public function show(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
    
            // Get all claimed coupons for the user
            $claimedCoupons = \DB::table('user_coupon_claims')
                ->where('user_id', $user->id)
                ->where('status', 'claimed')  // Only get 'claimed' coupons
                ->join('coupons', 'user_coupon_claims.coupon_id', '=', 'coupons.id')
                ->select('coupons.id', 'coupons.code', 'coupons.product_name', 'coupons.start_date', 'coupons.end_date', 'coupons.picture_path', 'user_coupon_claims.status')
                ->get();
    
            // Map the results to include full picture URL
            $data = $claimedCoupons->map(function ($coupon) {
                return [
                    'id' => $coupon->id,
                    'code' => $coupon->code,
                    'product_name' => $coupon->product_name,
                    'start_date' => $coupon->start_date,
                    'end_date' => $coupon->end_date,
                    'picture_url' => $coupon->picture_path ? asset('storage/' . $coupon->picture_path) : null,
                ];
            });
    
            return response()->json([
                'message' => 'Claimed coupons retrieved successfully.',
                'data' => $data,
            ], Response::HTTP_OK);
        } catch (\Throwable $e) {
            // Return a proper JSON error response
            return response()->json([
                'message' => 'An error occurred while retrieving coupons.',
                'error' => $e->getMessage(),
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    }
