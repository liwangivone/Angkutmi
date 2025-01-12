<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\Trip; // Pastikan model Trip sudah dibuat

class PaymentController extends Controller
{
    public function paymentProcess(Request $request)
    {
        // Validasi input
        $validated = $request->validate([
            'trip_id' => 'required|exists:trips,id', // Pastikan trip_id valid
            'payment_type' => 'required|string'
        ]);

        // Ambil total_price dari tabel trips berdasarkan trip_id
        $trip = Trip::find($validated['trip_id']);
        if (!$trip) {
            return response()->json(['message' => 'Trip not found'], 404);
        }

        $totalPrice = $trip->total_price;

        // Simpan data payment
        $payment = Payment::create([
            'trip_id' => $validated['trip_id'],
            'total_price' => $totalPrice,
            'payment_type' => $validated['payment_type'],
        ]);

        // Kembalikan response
        return response()->json([
            'message' => 'Payment created successfully',
            'data' => $payment
        ], 201);
    }

    public function show($id)
    {
        $payment = Payment::find($id);

        if (!$payment) {
            return response()->json(['message' => 'Payment not found'], 404);
        }

        return response()->json($payment);
    }
}
