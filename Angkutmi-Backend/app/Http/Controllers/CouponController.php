<?php

namespace App\Http\Controllers;

use App\Models\Coupon;
use App\Models\Redemption;
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
        // Manual validation using the Request object
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|unique:coupons,code',
            'limit' => 'nullable|integer',
            'product_name' => 'required|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
        ]);

        // Check if validation fails
        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        // Create the coupon using validated data
        $coupon = Coupon::create($validator->validated());

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
        $coupons = Coupon::where(function ($query) {
                $query->whereNull('start_date')
                    ->orWhere('start_date', '<=', now());
            })
            ->where(function ($query) {
                $query->whereNull('end_date')
                    ->orWhere('end_date', '>=', now());
            })
            ->get();

        return response()->json([
            'message' => 'Coupons retrieved successfully.',
            'data' => $coupons
        ], Response::HTTP_OK);
    }

    /**
     * Redeem a coupon.
     */
    public function redeem(Request $request): JsonResponse
    {
        $user = $request->user();
        $code = $request->input('code'); // Get the coupon code from the request body
    
        // Find the coupon by code
        $coupon = Coupon::where('code', $code)->first();
    
        // Check if the coupon exists
        if (!$coupon) {
            return response()->json(['message' => 'Invalid coupon code.'], Response::HTTP_BAD_REQUEST);
        }
    
        // Check if the coupon is still available
        if ($coupon->limit !== null && $coupon->limit <= 0) {
            return response()->json(['message' => 'This coupon is no longer available.'], Response::HTTP_BAD_REQUEST);
        }
    
        // Check if the user has already redeemed this coupon
        if ($user->redemptions()->where('coupon_id', $coupon->id)->exists()) {
            return response()->json(['message' => 'You have already redeemed this coupon.'], Response::HTTP_BAD_REQUEST);
        }
    
        // Create a redemption record
        Redemption::create([
            'user_id' => $user->id,
            'coupon_id' => $coupon->id,
        ]);
    
        // Decrement the coupon limit, if applicable
        if ($coupon->limit !== null) {
            $coupon->decrement('limit');
        }
    
        return response()->json([
            'message' => 'Coupon redeemed successfully.',
            'data' => [
                'product_name' => $coupon->product_name,
                'redeemed_at' => now(),
            ],
        ], Response::HTTP_OK);
    }
    

    /**
     * Get all redeemed products for the user.
     */
    public function redeemedProducts(Request $request): JsonResponse
    {
        $user = $request->user();

        $redeemedProducts = $user->redemptions()
            ->with('coupon') // Load coupon details
            ->get()
            ->map(function ($redemption) {
                return [
                    'product_name' => $redemption->coupon->product_name,
                    'redeemed_at' => $redemption->created_at,
                ];
            });

        return response()->json([
            'message' => 'Redeemed products retrieved successfully.',
            'data' => $redeemedProducts,
        ], Response::HTTP_OK);
    }
}
