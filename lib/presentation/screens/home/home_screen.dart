import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/recipe_provider.dart';
import '../recipe/recipe_details_screen.dart';
import '../recipe/community_recipes_screen.dart';
import '../../widgets/recipe_image.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const HomeScreen({super.key, this.onMenuTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Recipes';
  final List<String> _categories = [
    'All Recipes',
    'Pizza',
    'Pasta',
    'Burgers',
    'Dessert',
    'Salad'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<RecipeProvider>(context, listen: false)
        .fetchPublicRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.onMenuTap != null) {
                            widget.onMenuTap!();
                          } else {
                            Scaffold.of(context).openDrawer();
                          }
                        },
                        icon: const Icon(Icons.menu, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discover',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            "What's on the menu today?",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No new notifications")),
                          );
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.notifications_none,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              Provider.of<RecipeProvider>(context,
                                      listen: false)
                                  .searchRecipes(value);
                            } else {
                              Provider.of<RecipeProvider>(context,
                                      listen: false)
                                  .fetchPublicRecipes();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search ingredients...',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white70),
                            fillColor: Colors.white.withOpacity(0.1),
                            filled: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Filters coming soon!")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF24DC3D),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Provider.of<RecipeProvider>(context, listen: false)
                                .filterRecipesByTag(category);
                          },
                          child: _categoryChip(
                              category, _selectedCategory == category),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Featured Recipes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Featured Recipes',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      GestureDetector(
                        onTap: () {
                          // View All leads to Community Recipes / Browse
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CommunityRecipesScreen(),
                            ),
                          );
                        },
                        child: Text('View All',
                            style: TextStyle(
                                color: const Color(0xFF24DC3D),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: Consumer<RecipeProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final featured =
                            provider.publicRecipes.take(5).toList();
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: featured.length,
                          itemBuilder: (context, index) {
                            return _featuredCard(featured[index]);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Recommended
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recommended for You',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const Icon(Icons.info_outline,
                          color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return Consumer<RecipeProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) return const SizedBox();
                          final recommended = provider.publicRecipes.length > 5
                              ? provider.publicRecipes.skip(5).toList()
                              : provider.publicRecipes;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: recommended.length,
                            itemBuilder: (context, index) {
                              return _recommendedCard(recommended[index]);
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Bottom nav space
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF24DC3D)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: isSelected
            ? null
            : Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _featuredCard(recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RecipeDetailsScreen(recipe: recipe))),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              Positioned.fill(
                child: RecipeImage(imageUrl: recipe.image),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF24DC3D),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text("CHEF'S CHOICE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recommendedCard(recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RecipeDetailsScreen(recipe: recipe))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: RecipeImage(
                      imageUrl: recipe.image,
                      width: double.infinity,
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.favorite_border,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFFB300), size: 14),
                      Text(" ${recipe.rating}",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70)),
                      Text(" (${recipe.reviewCount})",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
