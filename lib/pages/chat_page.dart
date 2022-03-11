import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/services/socket_service.dart';

import 'package:chatapp/models/mensajes_response.dart';
import 'package:chatapp/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _estaEscribiendo = false;
  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    super.initState();

    socketService.socket.on('mensaje-personal', escucharMensaje);

    _cargarHistorial(chatService.usuarioPara.uid);
  }

  void _cargarHistorial(String usuarioId) async {
    List<Mensaje> chat = await chatService.getChat(usuarioId);
    final history = chat.map((m) => ChatMessage(
          texto: m.mensaje,
          uuid: m.de,
          animationController: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 200),
          )..forward(),
        ));
    setState(() {
      _messages.insertAll(0, history);
    });
  }

  escucharMensaje(dynamic payload) {
    final ChatMessage message = ChatMessage(
      texto: payload['mensaje'],
      uuid: payload['de'],
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    setState(() {
      _messages.insert(0, message);
      message.animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const _AppBarContent(),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          const Divider(
            height: 10,
          ),
          //Caja de texto
          Container(
            color: Colors.white,
            child: _inputChat(),
          )
        ],
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: (value) => _handleSubmit(value),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      _estaEscribiendo = true;
                    } else {
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration:
                    const InputDecoration.collapsed(hintText: 'Enviar mensaje'),
                focusNode: _focusNode,
              ),
            ),
            //Boton de enviar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isAndroid
                  ? IconTheme(
                      data: IconThemeData(color: Colors.blue.shade400),
                      child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: _estaEscribiendo
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                          icon: const Icon(
                            Icons.send,
                          )),
                    )
                  : CupertinoButton(
                      child: const Text('Enviar'),
                      onPressed: _estaEscribiendo
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                    ),
            )
          ],
        ),
      ),
    );
  }

  _handleSubmit(String texto) {
    if (texto.isEmpty) return;
    _textController.clear();
    _focusNode.requestFocus();
    final ChatMessage message = ChatMessage(
      texto: texto,
      uuid: authService.usuario.uid,
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    setState(() {
      _messages.insert(0, message);
      message.animationController.forward();
      _estaEscribiendo = false;
    });

    socketService.emit(
      'mensaje-personal',
      {
        'de': authService.usuario.uid,
        'para': chatService.usuarioPara.uid,
        'mensaje': texto,
      },
    );
  }

  @override
  void dispose() {
    for (var item in _messages) {
      item.animationController.dispose();
    }
    socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}

class _AppBarContent extends StatelessWidget {
  const _AppBarContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatService>(
      builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              maxRadius: 14,
              child: Text(
                value.usuarioPara.nombre.substring(0, 2),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.blue.shade100,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              value.usuarioPara.nombre,
              style: const TextStyle(color: Colors.black87, fontSize: 10),
            )
          ],
        );
      },
    );
  }
}
