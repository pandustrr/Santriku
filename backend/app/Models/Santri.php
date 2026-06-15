<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Santri extends Model
{
    protected $fillable = [
        'name',
        'nis',
        'wali_id',
        'qr_token',
    ];

    public function wali()
    {
        return $this->belongsTo(User::class, 'wali_id');
    }
}
