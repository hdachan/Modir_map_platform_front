import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'cofing/SupabaseConfig.dart';
import 'utils/firebase_options.dart';
import 'mvvm/Mypage/viewmodels/ProfileViewModel.dart';
import 'mvvm/Mypage/viewmodels/WithdrawalViewModel.dart';
import 'utils/router.dart';
import 'utils/SessionManager.dart';
import 'mvvm/Auth/services/AuthService.dart';
import 'mvvm/Auth/viewmodels/auth_view_model.dart';
import 'mvvm/feed/services/FeedService.dart';
import 'mvvm/feed/viewmodels/FeedViewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase 초기화
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Supabase 로그인 상태 리스너 초기화
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
        ChangeNotifierProvider(create: (_) => WithdrawalViewModel()),
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