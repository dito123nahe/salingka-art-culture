<?php

namespace App\Http\Controllers;

use App\Models\Client;
use Illuminate\Http\Request;

class ClientController extends Controller
{
    private function rules(): array
    {
        return [
            'nama' => 'required|string|max:255',
            'no_wa' => 'nullable|string|max:20',
            'sumber' => 'nullable|in:WhatsApp,Instagram',
        ];
    }

    public function index()
    {
        return Client::orderBy('nama')->get();
    }

    public function store(Request $request)
    {
        $client = Client::create($request->validate($this->rules()));

        return response()->json($client, 201);
    }

    public function show(Client $client)
    {
        return $client;
    }

    public function update(Request $request, Client $client)
    {
        $client->update($request->validate($this->rules()));

        return $client;
    }

    public function destroy(Client $client)
    {
        if (\DB::table('bookings')->where('client_id', $client->id)->exists()) {
            return response()->json(
                ['message' => 'Klien sudah memiliki booking, tidak bisa dihapus.'],
                422
            );
        }

        $client->delete();

        return response()->json(null, 204);
    }
}