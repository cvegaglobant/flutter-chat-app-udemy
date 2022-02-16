import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  final String titulo;
  const CustomLogo({
    Key? key,
    required this.titulo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            const Image(
              image: AssetImage('assets/tag-logo.png'),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              titulo,
              style: const TextStyle(fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}
