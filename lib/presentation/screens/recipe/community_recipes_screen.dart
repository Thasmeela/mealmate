import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../recipe/add_recipe_screen.dart';
import '../recipe/recipe_details_screen.dart';

class CommunityRecipesScreen extends StatelessWidget {
  const CommunityRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Cooks')),
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
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: recipe.image.startsWith('http')
                      ? Image.network(recipe.image,
                          width: 60, height: 60, fit: BoxFit.cover)
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image)),
                ),
                title: Text(recipe.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${recipe.cuisine} • ${recipe.difficulty}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RecipeDetailsScreen(recipe: recipe)),
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
