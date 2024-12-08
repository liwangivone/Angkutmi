<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DriverController;
use App\Http\Controllers\TripController;
use App\Http\Controllers\SubscriptionController;
use L5Swagger\Http\Controllers\SwaggerController;

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
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/packages', [SubscriptionController::class, 'packages']); // Menampilkan daftar paket
    Route::post('/subscriptions', [SubscriptionController::class, 'createSubscription']); // Membuat langganan
    Route::post('/subscriptions/{id}/payment', [SubscriptionController::class, 'createPayment']); // Membuat pembayaran
});
