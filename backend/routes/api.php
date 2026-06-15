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

use App\Http\Controllers\PengurusController;

Route::middleware(['auth:sanctum'])->prefix('pengurus')->group(function () {
    Route::post('attendance', [PengurusController::class, 'storeAttendance']);
    Route::post('consumption', [PengurusController::class, 'storeConsumption']);
    Route::get('permissions', [PengurusController::class, 'getPermissions']);
    Route::put('permissions/{id}', [PengurusController::class, 'updatePermissionStatus']);
    Route::get('consumption-stats', [PengurusController::class, 'getConsumptionStats']);
    Route::post('consumption-stats', [PengurusController::class, 'storeConsumptionStats']);
    Route::get('dashboard-stats', [PengurusController::class, 'getDashboardStats']);
    Route::get('activity-logs', [PengurusController::class, 'getActivityLogs']);
});

use App\Http\Controllers\WaliController;

Route::middleware(['auth:sanctum'])->prefix('wali')->group(function () {
    Route::get('santri', [WaliController::class, 'getSantris']);
    Route::get('santri/{id}/dashboard', [WaliController::class, 'getDashboardStats']);
    Route::get('santri/{id}/permissions', [WaliController::class, 'getPermissions']);
    Route::post('santri/{id}/permissions', [WaliController::class, 'storePermission']);
});
