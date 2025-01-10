<?php

// app/Http/Controllers/SubscriptionController.php

namespace App\Http\Controllers;

use App\Models\Subscription;
use App\Models\TpaLocation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SubscriptionController extends Controller
{
    public function createSubscription(Request $request)
    {
        // Validate the input, expecting latitude and longitude for the address
        $validated = $request->validate([
            'package_name' => 'required|string',
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'schedule_date' => 'required|date',
        ]);
    
        // Define available packages and their prices
        $packages = [
            ['name' => 'Paket 1 Bulan', 'price' => 45000],
            ['name' => 'Paket 3 Bulan', 'price' => 80000],
            ['name' => 'Paket 6 Bulan', 'price' => 125000],
        ];
    
        // Find the selected package
        $package = collect($packages)->firstWhere('name', $validated['package_name']);
    
        if (!$package) {
            return response()->json(['error' => 'Invalid package selected'], 400);
        }
    
        // Find the nearest TPA
        $nearestTpa = TpaLocation::all()->sortBy(function ($tpa) use ($validated) {
            return $this->haversine(
                $validated['lat'],
                $validated['lng'],
                $tpa->latitude,
                $tpa->longitude
            );
        })->first();
    
        if (!$nearestTpa) {
            return response()->json(['error' => 'No TPA locations found.'], 400);
        }
    
        // Create the subscription
        $subscription = Subscription::create([
            'user_id' => Auth::id(),
            'package_name' => $validated['package_name'],
            'price' => $package['price'],
            'address' => json_encode(['lat' => $validated['lat'], 'lng' => $validated['lng']]), // Store lat/lng as a JSON string
            'schedule_date' => $validated['schedule_date'],
            'tpa_id' => $nearestTpa->id, // Store the nearest TPA location
        ]);
    
        // Automatically schedule the daily trips for this subscription
        $subscription->scheduleSubscriptionTrips();
    
        return response()->json([
            'message' => 'Subscription created and daily trips scheduled successfully',
            'subscription' => $subscription,
        ]);
    }
    
    private function haversine($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo)
    {
        $radius = 6371; // Earth's radius in kilometers
        $latFrom = deg2rad($latitudeFrom);
        $lonFrom = deg2rad($longitudeFrom);
        $latTo = deg2rad($latitudeTo);
        $lonTo = deg2rad($longitudeTo);
    
        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;
    
        $a = sin($latDelta / 2) * sin($latDelta / 2) +
            cos($latFrom) * cos($latTo) *
            sin($lonDelta / 2) * sin($lonDelta / 2);
    
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    
        return $radius * $c;
    }
    



    /**
     * @OA\Post(
     *     path="/api/subscriptions/{id}/payment",
     *     summary="Membuat pembayaran untuk langganan",
     *     tags={"Subscription"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID dari langganan",
     *         @OA\Schema(type="integer", example=1)
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="payment_method", type="string", example="OVO")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Pembayaran berhasil.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Payment successful"),
     *             @OA\Property(
     *                 property="payment",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="subscription_id", type="integer", example=1),
     *                 @OA\Property(property="payment_method", type="string", example="OVO"),
     *                 @OA\Property(property="status", type="string", example="success"),
     *             )
     *         )
     *     ),
     *     @OA\Response(response=404, description="Langganan tidak ditemukan."),
     *     @OA\Response(response=422, description="Validasi input gagal.")
     * )
     */
    public function createPayment(Request $request, $id)
    {
        $validated = $request->validate([
            'payment_method' => 'required|string',
        ]);

        $subscription = Subscription::findOrFail($id);

        $payment = Payment::create([
            'subscription_id' => $subscription->id,
            'payment_method' => $validated['payment_method'],
            'status' => 'pending', // Default status
        ]);

        // Simulasi pembayaran berhasil
        $payment->update(['status' => 'success']);

        return response()->json(['message' => 'Payment successful', 'payment' => $payment], 200);
    }
}
