<?php

namespace App\Http\Controllers;

use App\Models\Attendance;
use App\Models\Member;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    // Absensi satu tanggal: semua anggota aktif + status (null jika belum dicatat)
    public function index(Request $request)
    {
        $request->validate(['tanggal' => 'required|date']);
        $tanggal = $request->query('tanggal');

        $tercatat = Attendance::whereDate('tanggal', $tanggal)
            ->pluck('status', 'member_id');

        return Member::where('status_aktif', true)
            ->orderBy('nama')
            ->get()
            ->map(fn ($m) => [
                'member_id' => $m->id,
                'nama' => $m->nama,
                'status' => $tercatat[$m->id] ?? null,
            ]);
    }

    // Simpan absensi satu tanggal sekaligus
    public function store(Request $request)
    {
        $data = $request->validate([
            'tanggal' => 'required|date',
            'items' => 'required|array',
            'items.*.member_id' => 'required|exists:members,id',
            'items.*.status' => 'required|in:hadir,tidak',
        ]);

        foreach ($data['items'] as $item) {
        Attendance::updateOrCreate(
            ['member_id' => $item['member_id'], 'tanggal' => $data['tanggal']],
            ['status' => $item['status']]
        );
    }

    return response()->json(['message' => 'Tersimpan']);
}

    // Rekap kehadiran per anggota
    public function rekap()
    {
        $total = Attendance::distinct('tanggal')->count('tanggal');

        $rows = Member::where('status_aktif', true)
            ->orderBy('nama')
            ->get()
            ->map(function ($m) use ($total) {
                $hadir = Attendance::where('member_id', $m->id)
                    ->where('status', 'hadir')->count();
                return [
                    'member_id' => $m->id,
                    'nama' => $m->nama,
                    'hadir' => $hadir,
                    'total_sesi' => $total,
                    'persen' => $total > 0 ? round($hadir / $total * 100) : 0,
                ];
            });

        return response()->json(['total_sesi' => $total, 'data' => $rows]);
    }
}