import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_provider.dart';
import '../recipe/add_recipe_screen.dart';
import '../recipe/recipe_details_screen.dart';
import '../../widgets/recipe_image.dart';

class CommunityRecipesScreen extends StatefulWidget {
  const CommunityRecipesScreen({super.key});

  @override
  State<CommunityRecipesScreen> createState() => _CommunityRecipesScreenState();
}

class _CommunityRecipesScreenState extends State<CommunityRecipesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      if (provider.allUserRecipes.isEmpty) {
        provider.fetchAllUserRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: const Text('Community Cooks',
              style: TextStyle(color: Colors.white))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.allUserRecipes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No community recipes yet. Be the first!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.allUserRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = provider.allUserRecipes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RecipeImage(
                          imageUrl: recipe.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(recipe.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      subtitle: Text(
                        '${recipe.cuisine} • ${recipe.difficulty}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailsScreen(recipe: recipe)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
          // Refresh after adding
          if (mounted) {
            Provider.of<RecipeProvider>(context, listen: false)
                .fetchAllUserRecipes();
          }
        },
        label: const Text('Add Recipe'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
