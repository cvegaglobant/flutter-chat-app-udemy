import 'dart:convert';
import 'package:chatapp/models/register_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chatapp/global/enviroments.dart';

import 'package:chatapp/models/usuario.dart';
import 'package:chatapp/models/login_response.dart';

class AuthService with ChangeNotifier {
  late Usuario _usuario;
  final _storage = const FlutterSecureStorage();
  late String _mensajeRegistro;

  bool _autenticando = false;

  bool get autenticando => _autenticando;
  set autenticando(bool valor) {
    _autenticando = valor;
    notifyListeners();
  }

  String get mensajeRegistro => _mensajeRegistro;
  set mensajeRegistro(String valor) {
    _mensajeRegistro = valor;
    notifyListeners();
  }

  Usuario get usuario => _usuario;
  set usuario(Usuario valor) {
    _usuario = valor;
    notifyListeners();
  }

  //getters estaticos para token
  static Future<String?> getToken() async {
    const _storage = FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    const _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    autenticando = true;

    final data = {
      'email': email,
      'password': password,
    };

    final resp = await http.post(Uri.parse('${Enviroments.apiUrl}/login'),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
        });

    if (resp.statusCode == 200) {
      final respuestaLogin = loginResponseFromJson(resp.body);
      usuario = respuestaLogin.usuario;

      await _guardarToken(respuestaLogin.token);

      autenticando = false;

      return true;
    } else {
      autenticando = false;

      return false;
    }
  }

  Future<bool> register(String nombre, String email, String password) async {
    autenticando = true;

    final data = {
      'nombre': nombre,
      'email': email,
      'password': password,
    };

    final resp = await http.post(Uri.parse('${Enviroments.apiUrl}/login/new'),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
        });

    if (resp.statusCode == 200) {
      final respuestaRegistro = registerResponseFromJson(resp.body);
      usuario = respuestaRegistro.usuario;

      await _guardarToken(respuestaRegistro.token);

      autenticando = false;
      return true;
    } else {
      autenticando = false;
      Map<String, dynamic> error = json.decode(resp.body);
      mensajeRegistro = error.containsKey('msg')
          ? error['msg']
          : 'Faltan campos obligatorios';
      return false;
    }
  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    return await _storage.delete(key: 'token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');

    final resp = await http
        .get(Uri.parse('${Enviroments.apiUrl}/login/renew'), headers: {
      'Content-Type': 'application/json',
      'x-token': token ?? '',
    });

    if (resp.statusCode == 200) {
      final respuestaLogin = loginResponseFromJson(resp.body);
      usuario = respuestaLogin.usuario;
      await _guardarToken(respuestaLogin.token);

      return true;
    } else {
      logout();

      return false;
    }
  }
}
