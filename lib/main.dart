import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryBlue =
      Color(0xFF1565C0); // contraste alto com branco
  static const Color onSurfaceGray = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language App',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          background: Colors.white,
          primary: primaryBlue,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: onSurfaceGray,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 -> Configurações (padrão), 1 -> Praticar, 2 -> Estatísticas, 3 -> Histórico
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Configurações',
    'Praticar',
    'Estatísticas',
    'Histórico',
  ];

  static const List<IconData> _icons = [
    Icons.settings,
    Icons.play_circle_fill,
    Icons.bar_chart,
    Icons.history,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language App'),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            _titles[_currentIndex],
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: List.generate(4, (i) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            label: _titles[i],
          );
        }),
      ),
    );
  }
}
