<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DriverController;
use App\Http\Controllers\TripController;
<<<<<<< HEAD
use App\Http\Controllers\SubscriptionController;
use L5Swagger\Http\Controllers\SwaggerController;
=======
use App\Http\Controllers\CouponController;
use App\Http\Controllers\WheelOfFortuneController;
>>>>>>> 18e0c2c8ef5cbd1669fbeb8f1a4eb4193125864f

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);


Route::group(['middleware' => 'auth:sanctum'], function () {
    Route::get('/driver', [DriverController::class, 'show']);
    Route::post('/driver', [DriverController::class, 'update']);

    Route::post('/trip', [TripController::class, 'store']);
    Route::get('/trip/{trip}', [TripController::class, 'show']);
    Route::post('/trip/{trip}/accept', [TripController::class, 'accept']);
    Route::post('/trip/{trip}/start', [TripController::class, 'start']);
    Route::post('/trip/{trip}/end', [TripController::class, 'end']);
    Route::post('/trip/{trip}/location', [TripController::class, 'location']);

    Route::get('/user', function(Request $request){
        return $request->user();
    });
<<<<<<< HEAD
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/packages', [SubscriptionController::class, 'packages']); // Menampilkan daftar paket
    Route::post('/subscriptions', [SubscriptionController::class, 'createSubscription']); // Membuat langganan
    Route::post('/subscriptions/{id}/payment', [SubscriptionController::class, 'createPayment']); // Membuat pembayaran
});
=======
    Route::post('/coupons', [CouponController::class, 'store']);
    Route::get('/coupons', [CouponController::class, 'get']);
    Route::get('/coupons/inventory', [CouponController::class, 'getUserClaimedCoupons']);
    Route::post('/coupons/{coupon}/redeem', [CouponController::class, 'redeem']);
    Route::get('/coupons/redeemed', [CouponController::class, 'redeemedProducts']);

    Route::post('/wheel/spin', [WheelOfFortuneController::class, 'spin']);
    Route::post('/reward/claim', [WheelOfFortuneController::class, 'claimReward']);


    
}

);
>>>>>>> 18e0c2c8ef5cbd1669fbeb8f1a4eb4193125864f
