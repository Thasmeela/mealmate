import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
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
  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    Future.microtask(() {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        final recipeProvider =
            Provider.of<RecipeProvider>(context, listen: false);
        // Assuming listenToFavorites handles potential re-subscriptions gracefully
        // or check if already listening if possible.
        recipeProvider.listenToFavorites(user.uid);
        recipeProvider.fetchUserRecipes(user.uid);
        recipeProvider.fetchAllUserRecipes();
        recipeProvider.fetchPublicRecipes();
      }
    });
  }


  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> get _screens => [
    HomeScreen(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
    const CommunityRecipesScreen(),
    const AIAssistantScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (_selectedIndex >= _screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      key: _scaffoldKey, // Add a key to open drawer
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF24DC3D)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF24DC3D)),
              ),
              accountName: Text(authProvider.user?.displayName ?? 'Chef Explorer'),
              accountEmail: Text(authProvider.user?.email ?? 'chef@mealmate.com'),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings coming soon!")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                authProvider.logout();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/download.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF24DC3D),
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF24DC3D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              label: 'AI Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
