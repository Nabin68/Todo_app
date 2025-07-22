import 'package:flutter/material.dart';
import 'todo_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todo App",
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: TodoHomePage(isDarkMode: isDarkMode, onToggleTheme: toggleTheme),
    );
  }
}
