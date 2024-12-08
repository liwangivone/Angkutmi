<?php

namespace App\Http\Controllers;

use App\Models\Subscription;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * @OA\Info(title="Angkutmi API Documentation", version="1.0")
 */
class SubscriptionController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/packages",
     *     summary="Menampilkan daftar paket langganan",
     *     tags={"Subscription"},
     *     @OA\Response(
     *         response=200,
     *         description="Daftar paket berhasil ditampilkan.",
     *         @OA\JsonContent(
     *             type="array",
     *             @OA\Items(
     *                 @OA\Property(property="name", type="string", example="Paket 1 Bulan"),
     *                 @OA\Property(property="price", type="integer", example=450000)
     *             )
     *         )
     *     )
     * )
     */
    public function packages()
    {
        $packages = [
            ['name' => 'Paket 1 Bulan', 'price' => 450000],
            ['name' => 'Paket 3 Bulan', 'price' => 800000],
            ['name' => 'Paket 6 Bulan', 'price' => 1250000],
        ];

        return response()->json($packages, 200);
    }

    /**
     * @OA\Post(
     *     path="/api/subscriptions",
     *     summary="Membuat langganan baru",
     *     tags={"Subscription"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="package_name", type="string", example="Paket 3 Bulan"),
     *             @OA\Property(property="price", type="integer", example=800000),
     *             @OA\Property(property="address", type="string", example="Jl. Contoh No. 123"),
     *             @OA\Property(property="schedule_date", type="string", format="date", example="2024-12-15"),
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Langganan berhasil dibuat.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Subscription created successfully"),
     *             @OA\Property(
     *                 property="subscription",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="package_name", type="string", example="Paket 3 Bulan"),
     *                 @OA\Property(property="price", type="integer", example=800000),
     *                 @OA\Property(property="address", type="string", example="Jl. Contoh No. 123"),
     *                 @OA\Property(property="schedule_date", type="string", format="date", example="2024-12-15"),
     *             )
     *         )
     *     ),
     *     @OA\Response(response=422, description="Validasi input gagal.")
     * )
     */
    public function createSubscription(Request $request)
    {
        $validated = $request->validate([
            'package_name' => 'required|string',
            'price' => 'required|numeric',
            'address' => 'required|string',
            'schedule_date' => 'required|date',
        ]);

        $subscription = Subscription::create([
            'user_id' => Auth::id(),
            'package_name' => $validated['package_name'],
            'price' => $validated['price'],
            'address' => $validated['address'],
            'schedule_date' => $validated['schedule_date'],
        ]);

        return response()->json(['message' => 'Subscription created successfully', 'subscription' => $subscription], 201);
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
