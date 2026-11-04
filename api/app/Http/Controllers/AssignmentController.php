<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\BookingAssignment;
use App\Models\BookingDance;
use Illuminate\Http\Request;

class AssignmentController extends Controller
{
    // Susunan pemain satu booking: tiap tari + kebutuhan + penugasan
    public function show(Booking $booking)
    {
        $bds = BookingDance::with(['dance.roles', 'assignments.member', 'assignments.role'])
            ->where('booking_id', $booking->id)
            ->get();

        return $bds->map(function ($bd) {
            return [
                'booking_dance_id' => $bd->id,
                'dance' => $bd->dance,
                'kebutuhan' => $bd->dance->roles->map(fn ($r) => [
                    'role_id' => $r->id,
                    'nama_peran' => $r->nama_peran,
                    'jumlah' => (int) $r->pivot->jumlah_orang,
                ])->values(),
                'assignments' => $bd->assignments->map(fn ($a) => [
                    'member_id' => $a->member_id,
                    'nama' => $a->member->nama,
                    'role_id' => $a->role_id,
                ])->values(),
            ];
        });
    }

    // Simpan seluruh susunan pemain satu booking sekaligus
    public function sync(Request $request, Booking $booking)
    {
        $data = $request->validate([
            'items' => 'required|array',
            'items.*.booking_dance_id' => 'required|integer',
            'items.*.assignments' => 'array',
            'items.*.assignments.*.member_id' => 'required|exists:members,id',
            'items.*.assignments.*.role_id' => 'required|exists:roles,id',
        ]);

        $validIds = BookingDance::where('booking_id', $booking->id)->pluck('id')->all();

        foreach ($data['items'] as $item) {
            if (!in_array($item['booking_dance_id'], $validIds)) {
                return response()->json(['message' => 'Tari tidak termasuk booking ini.'], 422);
            }

            $members = collect($item['assignments'] ?? [])->pluck('member_id');
            if ($members->count() !== $members->unique()->count()) {
                return response()->json(
                    ['message' => 'Satu anggota tidak boleh memegang dua peran di tari yang sama.'],
                    422
                );
            }
        }

        foreach ($data['items'] as $item) {
            BookingAssignment::where('booking_dance_id', $item['booking_dance_id'])->delete();
            foreach ($item['assignments'] ?? [] as $a) {
                BookingAssignment::create([
                    'booking_dance_id' => $item['booking_dance_id'],
                    'member_id' => $a['member_id'],
                    'role_id' => $a['role_id'],
                ]);
            }
        }

        // Peringatan: anggota yang juga bertugas di booking lain pada tanggal sama
        $memberIds = collect($data['items'])
            ->flatMap(fn ($i) => collect($i['assignments'] ?? [])->pluck('member_id'))
            ->unique()->values();

        $bentrok = BookingAssignment::with(['member', 'bookingDance.booking'])
            ->whereIn('member_id', $memberIds)
            ->whereHas('bookingDance.booking', function ($q) use ($booking) {
                $q->whereDate('tanggal', $booking->tanggal)
                    ->where('id', '!=', $booking->id)
                    ->where('status', '!=', 'batal');
            })
            ->get()
            ->map(fn ($a) => $a->member->nama)
            ->unique()->values();

        return response()->json(['message' => 'Tersimpan', 'bentrok' => $bentrok]);
    }
}