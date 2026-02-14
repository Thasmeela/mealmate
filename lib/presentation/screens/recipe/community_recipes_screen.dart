import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_provider.dart';
import '../recipe/add_recipe_screen.dart';
import '../recipe/recipe_details_screen.dart';

class CommunityRecipesScreen extends StatelessWidget {
  const CommunityRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: const Text('Community Cooks',
              style: TextStyle(color: Colors.white))),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          if (provider.userRecipes.isEmpty) {
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
            itemCount: provider.userRecipes.length,
            itemBuilder: (context, index) {
              final recipe = provider.userRecipes[index];
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
                    child: recipe.image.startsWith('http')
                        ? Image.network(recipe.image,
                            width: 60, height: 60, fit: BoxFit.cover)
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.white.withOpacity(0.2),
                            child:
                                const Icon(Icons.image, color: Colors.white)),
                  ),
                  title: Text(recipe.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(
                    '${recipe.cuisine} • ${recipe.difficulty}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RecipeDetailsScreen(recipe: recipe)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
        ),
        label: const Text('Add Recipe'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
