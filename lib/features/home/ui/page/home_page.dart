import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.logout),
        onPressed: () {
          context.read<AuthCubit>().signOut();
        },
      ),
      body: const Center(
        child: SunRaysShaderWidget(
          alignment: .topCenter,
        ),
      ),
    );
  }
}
