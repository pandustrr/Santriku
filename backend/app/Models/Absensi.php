<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    protected $fillable = [
        'santri_id',
        'pengurus_id',
        'status',
        'latitude',
        'longitude',
        'is_in_range',
        'waktu_absen',
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class);
    }

    public function pengurus()
    {
        return $this->belongsTo(User::class, 'pengurus_id');
    }
}
