<?php

namespace App\Http\Controllers;

use App\Models\Role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    public function index()
    {
        return Role::orderBy('nama_peran')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate(['nama_peran' => 'required|string|max:100']);
        return response()->json(Role::create($data), 201);
    }

    public function show(Role $role)
    {
        return $role;
    }

    public function update(Request $request, Role $role)
    {
        $data = $request->validate(['nama_peran' => 'required|string|max:100']);
        $role->update($data);
        return $role;
    }

    public function destroy(Role $role)
    {
        $role->delete();
        return response()->json(null, 204);
    }
}