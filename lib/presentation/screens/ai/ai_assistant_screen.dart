import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../../domain/entities/recipe.dart';
import '../recipe/recipe_details_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _ingredients = [];

  void _addIngredient() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: const [
            Text('MEALMATE AI',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF24DC3D),
                    fontWeight: FontWeight.bold)),
            Text('Chef Assistant',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.history, color: Colors.white70),
              onPressed: () {}),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // AI Hello
                    _aiBubble(
                        "Hi! I'm your healthy cooking assistant. Tell me what ingredients you have in your fridge, and I'll generate a nutritious recipe for you!"),
                    const SizedBox(height: 24),
                    // User input bubbles
                    if (_ingredients.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _ingredients
                              .map((ing) => _ingredientChip(ing))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // AI Response Card
                    Consumer<AIProvider>(
                      builder: (context, ai, child) {
                        if (ai.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (ai.generatedRecipe != null) {
                          return _richRecipeCard(ai.generatedRecipe!);
                        }
                        if (ai.aiResponse.isNotEmpty) {
                          return _aiBubble(ai.aiResponse);
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
              // Input Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter ingredients (e.g., Tomato, Egg...)',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.5)),
                          fillColor: Colors.white.withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_ingredients.isNotEmpty) {
                          Provider.of<AIProvider>(context, listen: false)
                              .generateRecipe(_ingredients);
                        } else {
                          _addIngredient();
                        }
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF24DC3D),
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.auto_awesome, color: Colors.white),
                      ),
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

  Widget _aiBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/mealmate.png', height: 90, width: 90),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15, height: 1.5, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _ingredientChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF24DC3D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _richRecipeCard(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.network(
              recipe.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(recipe.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.timer,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                              "${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${recipe.cuisine} • ${recipe.difficulty}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('CALORIES',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${recipe.caloriesPerServing} kcal',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailsScreen(recipe: recipe),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24DC3D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text('View Full Recipe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
