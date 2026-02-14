import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/recipe.dart';
import '../../providers/ai_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  void _showAIModal(
      BuildContext context, String title, Future<void> Function() aiCall) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<AIProvider>(
                builder: (context, ai, child) {
                  if (ai.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Text(
                      ai.aiResponse.isEmpty
                          ? 'Generating insight...'
                          : ai.aiResponse,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    aiCall();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: recipe.image,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            actions: [
              Consumer<RecipeProvider>(
                builder: (context, provider, child) {
                  final isFav = provider.isFavorite(recipe.id);
                  return IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white),
                    onPressed: () {
                      if (user != null) {
                        provider.toggleFavorite(user.uid, recipe);
                      }
                    },
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(recipe.name,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(recipe.difficulty,
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoCard(Icons.timer,
                          '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min'),
                      const SizedBox(width: 12),
                      _infoCard(Icons.local_fire_department,
                          '${recipe.caloriesPerServing} kcal'),
                      const SizedBox(width: 12),
                      _infoCard(Icons.people, '${recipe.servings} servings'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('AI Assistant',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _aiButton(
                          context,
                          'Simplify',
                          Icons.lightbulb_outline,
                          () => _showAIModal(
                              context,
                              'Simplified Steps',
                              () =>
                                  aiProvider.explainSteps(recipe.instructions)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _aiButton(
                          context,
                          'Healthier',
                          Icons.health_and_safety_outlined,
                          () => _showAIModal(
                              context,
                              'Healthy Alternatives',
                              () => aiProvider.suggestAlternatives(
                                  recipe.name, recipe.ingredients)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Ingredients',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.ingredients.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Text(recipe.ingredients[index],
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Instructions',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.instructions.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.deepOrange,
                            child: Text('${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Text(recipe.instructions[index],
                                  style: const TextStyle(
                                      fontSize: 16, height: 1.5))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _aiButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.deepOrange, Colors.orangeAccent]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
