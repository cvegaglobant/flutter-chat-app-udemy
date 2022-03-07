import 'package:chatapp/models/usuario.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({Key? key}) : super(key: key);

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final usuarios = [
    Usuario(online: true, email: 'test1@test.com', nombre: 'Maria', uid: '1'),
    Usuario(online: true, email: 'test2@test.com', nombre: 'Carlos', uid: '2'),
    Usuario(
        online: false, email: 'test3@test.com', nombre: 'Fernando', uid: '3'),
  ];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthService>(
          builder: (context, auth, child) {
            return Text(
              auth.usuario.nombre,
              style: const TextStyle(
                color: Colors.black54,
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            //TODO: desconectar del socket server
            AuthService.deleteToken();
            Navigator.pushReplacementNamed(context, 'login');
          },
          icon: const Icon(
            Icons.exit_to_app,
            color: Colors.black54,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            // child: Icon(Icons.check_circle, color: Colors.blue.shade400),
            child: const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: SmartRefresher(
        physics: const BouncingScrollPhysics(),
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: () => _cargarUsuarios(),
        header: WaterDropHeader(
          complete: Icon(
            Icons.check,
            color: Colors.blue.shade400,
          ),
          waterDropColor: Colors.blue,
        ),
        child: _ListViewUsuarios(usuarios: usuarios),
      ),
    );
  }

  _cargarUsuarios() async {
    await Future.delayed(const Duration(seconds: 2));
    _refreshController.refreshCompleted();
  }
}

class _ListViewUsuarios extends StatelessWidget {
  const _ListViewUsuarios({
    Key? key,
    required this.usuarios,
  }) : super(key: key);

  final List<Usuario> usuarios;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) =>
          _UsuarioListTile(usuario: usuarios[index]),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: usuarios.length,
    );
  }
}

class _UsuarioListTile extends StatelessWidget {
  const _UsuarioListTile({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(usuario.email),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade200,
        child: Text(usuario.nombre.substring(0, 2)),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (usuario.online) ? Colors.green.shade300 : Colors.red),
      ),
    );
  }
}
