import 'package:chatapp/global/enviroments.dart';
import 'package:chatapp/models/usuario.dart';
import 'package:chatapp/models/usuarios_response.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      String? token = await AuthService.getToken();
      final resp = await http.get(
        Uri.parse('${Enviroments.apiUrl}/usuarios?desde=0'),
        headers: {
          'Content-Type': 'application/json',
          'x-Token': token!,
        },
      );

      if (resp.statusCode == 200) {
        final usuariosResponse = usuariosResponseFromJson(resp.body);
        return usuariosResponse.usuarios;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
