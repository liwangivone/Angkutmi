<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\PaymentProcess;
use App\Models\Trip;
use Illuminate\Support\Facades\Validator;

/**
 * @OA\Tag(
 *     name="Payments",
 *     description="API untuk mengelola pembayaran dan proses pembayaran"
 * )
 */
class PaymentController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/payments",
     *     summary="Membuat pembayaran dan proses pembayaran",
     *     description="Menginput data pembayaran baru dan menyimpan data proses pembayaran",
     *     tags={"Payments"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"trip_id", "payment_type", "base_price", "final_price"},
     *             @OA\Property(property="trip_id", type="integer", example=1, description="ID Trip yang telah selesai"),
     *             @OA\Property(property="payment_type", type="string", enum={"debit", "ovo"}, example="debit", description="Tipe pembayaran"),
     *             @OA\Property(property="base_price", type="integer", example=50000, description="Harga awal"),
     *             @OA\Property(property="final_price", type="integer", example=45000, description="Harga akhir setelah diskon")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Pembayaran berhasil diproses",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Pembayaran berhasil diproses."),
     *             @OA\Property(property="payment", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="payment_type", type="string", example="debit"),
     *                 @OA\Property(property="created_at", type="string", example="2024-06-15T10:00:00"),
     *                 @OA\Property(property="updated_at", type="string", example="2024-06-15T10:00:00")
     *             ),
     *             @OA\Property(property="payment_process", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="trip_id", type="integer", example=1),
     *                 @OA\Property(property="payment_id", type="integer", example=1),
     *                 @OA\Property(property="base_price", type="integer", example=50000),
     *                 @OA\Property(property="final_price", type="integer", example=45000),
     *                 @OA\Property(property="payment_status", type="boolean", example=true),
     *                 @OA\Property(property="created_at", type="string", example="2024-06-15T10:00:00"),
     *                 @OA\Property(property="updated_at", type="string", example="2024-06-15T10:00:00")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validasi gagal",
     *         @OA\JsonContent(
     *             @OA\Property(property="errors", type="object")
     *         )
     *     )
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'trip_id' => 'required|exists:trips,id',
            'payment_type' => 'required|in:debit,ovo',
            'base_price' => 'required|integer|min:0',
            'final_price' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $trip = Trip::find($request->trip_id);
        if (!$trip || !$trip->is_started) {
            return response()->json(['error' => 'Trip belum selesai atau tidak valid.'], 400);
        }

        $payment = Payment::create([
            'payment_type' => $request->payment_type,
        ]);

        $paymentProcess = PaymentProcess::create([
            'trip_id' => $request->trip_id,
            'payment_id' => $payment->id,
            'base_price' => $request->base_price,
            'final_price' => $request->final_price,
            'payment_status' => true,
        ]);

        return response()->json([
            'message' => 'Pembayaran berhasil diproses.',
            'payment' => $payment,
            'payment_process' => $paymentProcess,
        ], 201);
    }

    /**
     * @OA\Get(
     *     path="/api/payments/{trip_id}",
     *     summary="Melihat detail pembayaran berdasarkan trip ID",
     *     description="Mengambil data proses pembayaran dan pembayaran berdasarkan trip ID",
     *     tags={"Payments"},
     *     @OA\Parameter(
     *         name="trip_id",
     *         in="path",
     *         required=true,
     *         description="ID Trip yang ingin dilihat detail pembayarannya",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Data pembayaran berhasil ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="payment_process", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="trip_id", type="integer", example=1),
     *                 @OA\Property(property="payment_id", type="integer", example=1),
     *                 @OA\Property(property="base_price", type="integer", example=50000),
     *                 @OA\Property(property="final_price", type="integer", example=45000),
     *                 @OA\Property(property="payment_status", type="boolean", example=true)
     *             ),
     *             @OA\Property(property="payment", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="payment_type", type="string", example="debit")
     *             ),
     *             @OA\Property(property="trip", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="is_started", type="boolean", example=true)
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Data pembayaran tidak ditemukan",
     *         @OA\JsonContent(
     *             @OA\Property(property="error", type="string", example="Data pembayaran tidak ditemukan.")
     *         )
     *     )
     * )
     */
    public function show($trip_id)
    {
        $paymentProcess = PaymentProcess::with('trip', 'payment')
            ->where('trip_id', $trip_id)
            ->first();

        if (!$paymentProcess) {
            return response()->json(['error' => 'Data pembayaran tidak ditemukan.'], 404);
        }

        return response()->json([
            'payment_process' => $paymentProcess,
            'payment' => $paymentProcess->payment,
            'trip' => $paymentProcess->trip,
        ]);
    }
}
