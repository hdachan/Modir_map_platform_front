import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavScreen extends StatefulWidget {
  final Widget child;
  const BottomNavScreen({super.key, required this.child});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  static final List<String> _routes = ['/map', '/community', '/mypage'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    setState(() {
      _selectedIndex = location.startsWith('/community') ? 1
          : location.startsWith('/mypage') ? 2 : 0;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() { _selectedIndex = index; });
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_kabaddi_outlined), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이'),
        ],
      ),
    );
  }
}




