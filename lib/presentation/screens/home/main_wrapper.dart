import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import '../recipe/community_recipes_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (userId != null) {
        Provider.of<RecipeProvider>(context, listen: false)
            .fetchPublicRecipes();
        Provider.of<RecipeProvider>(context, listen: false)
            .listenToFavorites(userId);
        Provider.of<RecipeProvider>(context, listen: false)
            .fetchUserRecipes(userId);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityRecipesScreen(),
    const AIAssistantScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group),
                label: 'Community'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'AI Helper'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
