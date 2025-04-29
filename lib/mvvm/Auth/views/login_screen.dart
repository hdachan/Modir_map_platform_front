import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Supabase 로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: viewModel.emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: viewModel.passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await viewModel.signIn();
                if (viewModel.jwt != null) {
                  context.go('/community');
                }
              },
              child: const Text('로그인'),
            ),
            const SizedBox(height: 12),
            if (viewModel.errorMessage != null)
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: viewModel.errorMessage!.contains('성공') ? Colors.green : Colors.red),
              ),
            if (viewModel.jwt != null)
              Text(
                '✅ JWT: ${viewModel.jwt!.substring(0, 20)}...',
                style: const TextStyle(color: Colors.green),
              ),
            if (viewModel.springResponse != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  viewModel.springResponse!,
                  style: TextStyle(
                    color: viewModel.springResponse!.contains("응답") ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
