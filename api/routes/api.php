<?php
use App\Http\Controllers\MemberController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\DanceController;
use App\Http\Controllers\ClientController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\AssignmentController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\HonorController;


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
Route::get('attendances', [AttendanceController::class, 'index']);
Route::post('attendances', [AttendanceController::class, 'store']);
Route::get('attendances/rekap', [AttendanceController::class, 'rekap']);
Route::get('bookings/{booking}/transactions', [TransactionController::class, 'index']);
Route::post('bookings/{booking}/transactions', [TransactionController::class, 'store']);
Route::delete('bookings/{booking}/transactions/{transaction}', [TransactionController::class, 'destroy']);
Route::put('bookings/{booking}/kas', [TransactionController::class, 'updateKas']);
Route::get('bookings/{booking}/honor', [HonorController::class, 'index']);
Route::post('bookings/{booking}/honor/hitung', [HonorController::class, 'hitung']);
Route::put('bookings/{booking}/honor/{honor}', [HonorController::class, 'update']);