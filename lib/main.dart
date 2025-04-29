import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'cofing/SupabaseConfig.dart';
import 'mvvm/Mypage/viewmodels/ProfileViewModel.dart';
import 'utils/router.dart';
import 'utils/SessionManager.dart';
import 'mvvm/Auth/services/AuthService.dart';
import 'mvvm/Auth/viewmodels/auth_view_model.dart';
import 'mvvm/feed/services/FeedService.dart';
import 'mvvm/feed/viewmodels/FeedViewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  SessionManager().initializeAuthListener();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeedViewModel(FeedRepository())),
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp.router(
        title: 'modirApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A1A)),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}