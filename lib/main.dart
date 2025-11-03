import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/add_screen.dart';

void main() => runApp(const HelpWantedApp());

class HelpWantedApp extends StatefulWidget {
  const HelpWantedApp({super.key});
  @override
  State<HelpWantedApp> createState() => _HelpWantedAppState();
}

class _HelpWantedAppState extends State<HelpWantedApp> {
  int index = 0;

  final screens = const [MapScreen(), FeedScreen(), AddScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Help Wanted",
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: Scaffold(
        appBar: AppBar(title: const Text("Help Wanted")),
        body: screens[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map), label: "Map"),
            NavigationDestination(icon: Icon(Icons.list), label: "Feed"),
            NavigationDestination(icon: Icon(Icons.add_a_photo), label: "Add"),
          ],
        ),
      ),
    );
  }
}

