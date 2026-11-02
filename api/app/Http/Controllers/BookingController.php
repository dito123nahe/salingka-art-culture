<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    private function rules(): array
    {
        return [
            'client_id' => 'required|exists:clients,id',
            'jenis_acara' => 'required|string|max:255',
            'tanggal' => 'required|date',
            'jam_mulai' => 'nullable|date_format:H:i',
            'jam_selesai' => 'nullable|date_format:H:i',
            'lokasi' => 'nullable|string|max:255',
            'link_maps' => 'nullable|url|max:500',
            'total_biaya' => 'required|numeric|min:0|max:9999999999',
            'status' => 'required|in:menunggu,dp,lunas,selesai,batal',
            'catatan' => 'nullable|string',
            'dance_ids' => 'array',
            'dance_ids.*' => 'exists:dances,id',
        ];
    }

    // Booking lain di tanggal yang sama (selain yang batal) -> hanya peringatan
    private function bentrok(string $tanggal, ?int $exceptId = null): array
    {
        return Booking::with('client')
            ->whereDate('tanggal', $tanggal)
            ->where('status', '!=', 'batal')
            ->when($exceptId, fn ($q) => $q->where('id', '!=', $exceptId))
            ->get()
            ->map(fn ($b) => $b->jenis_acara . ' (' . ($b->client->nama ?? '-') . ')')
            ->all();
    }

    public function index()
    {
        return Booking::with(['client', 'dances'])
            ->orderBy('tanggal', 'desc')
            ->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate($this->rules());

        $booking = Booking::create(collect($data)->except('dance_ids')->toArray());
        $booking->dances()->sync($data['dance_ids'] ?? []);

        $booking->load(['client', 'dances']);
        $booking->setAttribute('bentrok', $this->bentrok($data['tanggal'], $booking->id));

        return response()->json($booking, 201);
    }

    public function show(Booking $booking)
    {
        return $booking->load(['client', 'dances']);
    }

    public function update(Request $request, Booking $booking)
    {
        $data = $request->validate($this->rules());

        $booking->update(collect($data)->except('dance_ids')->toArray());
        if ($request->has('dance_ids')) {
            $booking->dances()->sync($data['dance_ids']);
        }

        $booking->load(['client', 'dances']);
        $booking->setAttribute('bentrok', $this->bentrok($data['tanggal'], $booking->id));

        return $booking;
    }

    public function destroy(Booking $booking)
    {
        if (\DB::table('transactions')->where('booking_id', $booking->id)->exists()) {
            return response()->json(
                ['message' => 'Booking sudah punya catatan keuangan. Ubah statusnya menjadi batal saja.'],
                422
            );
        }

        $booking->delete();

        return response()->json(null, 204);
    }
}