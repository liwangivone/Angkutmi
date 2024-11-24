<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class DriverController extends Controller
{
    public function show(Request $request){
        $user = $request->user();
        $user->load('driver');
    }

    public function update(Request $request){
        $request->validate([
            'type'=> 'required',
            'capacity'=>'required',
            'plat'=>'required'
        ]);

        $user = $request->user();
    }
}
