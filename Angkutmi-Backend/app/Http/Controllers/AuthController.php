<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // Fitur Register
    public function register(Request $request)
    {
        // Validasi input
        $validator = Validator::make($request->all(), [
            'username' => 'required|string|max:45',
            'phone_number' => 'required|integer|unique:users,phone_number',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        // Simpan user baru ke database
        User::create([
            'username' => $request->username,
            'phone_number' => $request->phone_number,
            'password' => Hash::make($request->password),
        ]);

        return redirect()->route('login')->with('success', 'Registration successful!');
    }

    // Fitur Login
    public function login(Request $request)
    {
        // Validasi input
        $credentials = $request->only('phone_number', 'password');

        $user = User::where('phone_number', $credentials['phone_number'])->first();

        if ($user && Hash::check($credentials['password'], $user->password)) {
            // Simpan user dalam session (atau JWT jika API)
            session(['user' => $user]);

            return redirect()->route('home')->with('success', 'Login successful!');
        }

        return back()->withErrors(['error' => 'Invalid phone number or password.']);
    }

    // Logout
    public function logout()
    {
        session()->forget('user');

        return redirect()->route('login')->with('success', 'You have been logged out.');
    }
}
