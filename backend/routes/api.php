<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;

use App\Http\Controllers\AdminController;

Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
        Route::get('me', [AuthController::class, 'me']);
        Route::post('device-token', [AuthController::class, 'storeDeviceToken']);
        Route::delete('device-token', [AuthController::class, 'destroyDeviceToken']);
    });
});

Route::middleware(['auth:sanctum'])->prefix('admin')->group(function () {
    Route::get('dashboard-stats', [AdminController::class, 'dashboardStats']);
    
    Route::get('users', [AdminController::class, 'getUsers']);
    Route::post('users', [AdminController::class, 'storeUser']);
    Route::put('users/{id}', [AdminController::class, 'updateUser']);
    Route::delete('users/{id}', [AdminController::class, 'destroyUser']);
    
    Route::get('santri', [AdminController::class, 'getSantris']);
    Route::post('santri', [AdminController::class, 'storeSantri']);
    Route::put('santri/{id}', [AdminController::class, 'updateSantri']);
    Route::delete('santri/{id}', [AdminController::class, 'destroySantri']);
});
