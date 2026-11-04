<?php
use App\Http\Controllers\MemberController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\DanceController;
use App\Http\Controllers\ClientController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\AssignmentController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::apiResource('members', MemberController::class);
Route::apiResource('roles', RoleController::class);
Route::apiResource('dances', DanceController::class);
Route::apiResource('clients', ClientController::class);
Route::apiResource('bookings', BookingController::class);
Route::get('bookings/{booking}/assignments', [AssignmentController::class, 'show']);
Route::put('bookings/{booking}/assignments', [AssignmentController::class, 'sync']);