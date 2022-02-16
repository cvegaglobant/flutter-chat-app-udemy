import 'package:flutter/material.dart';

class CustomLabels extends StatelessWidget {
  final String rutaANavegar;
  final String texto1;
  final String texto2;

  const CustomLabels({
    Key? key,
    required this.rutaANavegar,
    required this.texto1,
    required this.texto2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Text(
            texto1,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // GestureDetector(

          // )
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, rutaANavegar);
            },
            child: Text(
              texto2,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
