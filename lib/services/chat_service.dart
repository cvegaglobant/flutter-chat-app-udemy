import 'package:chatapp/models/mensajes_response.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:chatapp/global/enviroments.dart';

import 'package:chatapp/models/usuario.dart';

class ChatService with ChangeNotifier {
  late Usuario usuarioPara;

  Future<List<Mensaje>> getChat(String usuarioId) async {
    String? token = await AuthService.getToken();
    final resp = await http
        .get(Uri.parse('${Enviroments.apiUrl}/mensajes/$usuarioId'), headers: {
      'Content-Type': 'application/json',
      'x-token': token ?? '',
    });

    if (resp.statusCode == 200) {
      final mensajesResponse = mensajesResponseFromJson(resp.body);
      return mensajesResponse.mensajes;
    } else {
      return [];
    }
  }
}
