import 'package:chatapp/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/helpers/mostrar_alerta.dart';

import 'package:chatapp/widgets/btn_azul.dart';
import 'package:chatapp/widgets/custom_input.dart';
import 'package:chatapp/widgets/custom_labels.dart';
import 'package:chatapp/widgets/custom_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                CustomLogo(
                  titulo: 'Messenger',
                ),
                _Formulario(),
                CustomLabels(
                  rutaANavegar: 'register',
                  texto1: '¿No tienes cuenta?',
                  texto2: 'Crea una ahora!',
                ),
                Text(
                  'Terminos y condiciones de uso',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario({Key? key}) : super(key: key);

  @override
  __FormularioState createState() => __FormularioState();
}

class __FormularioState extends State<_Formulario> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailController,
          ),
          CustomInput(
            icon: Icons.password,
            placeholder: 'Contraseña',
            textController: passController,
            isPassword: true,
          ),
          Consumer<AuthService>(
            builder: (context, value, child) {
              return BotonAzul(
                text: 'Ingrese',
                onPressed: value.autenticando
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final loginOk = await authService.login(
                            emailController.text.trim(),
                            passController.text.trim());
                        if (loginOk) {
                          socketService.connect();
                          Navigator.pushReplacementNamed(context, 'usuarios');
                        } else {
                          //Mostrar Alerta
                          mostrarAlerta(context, 'Login incorrecto.',
                              'Revise sus credenciales.');
                        }
                      },
              );
            },
          ),
        ],
      ),
    );
  }
}
