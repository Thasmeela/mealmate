import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';

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
      backgroundColor: const Color(0xFFF9FBF9),
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
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.history, color: Colors.grey),
              onPressed: () {}),
        ],
      ),
      body: Column(
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
                // AI Response Card (Mocking the rich structure from reference)
                Consumer<AIProvider>(
                  builder: (context, ai, child) {
                    if (ai.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (ai.aiResponse.isNotEmpty) {
                      return _richRecipeCard(ai.aiResponse);
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter ingredients (e.g., Tomato, Egg...)',
                      fillColor: Colors.grey[100],
                      prefixIcon:
                          const Icon(Icons.info_outline, color: Colors.grey),
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
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFF24DC3D),
          radius: 18,
          child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child:
                Text(text, style: const TextStyle(fontSize: 15, height: 1.5)),
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

  Widget _richRecipeCard(String response) {
    // This mocks the rich card shown in the reference image
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.network(
              'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=1000&auto=format&fit=crop',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
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
                    const Expanded(
                      child: Text('Mediterranean Protein Scramble',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.history_toggle_off,
                          size: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                    'A low-carb, high-protein breakfast to start your day.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                      const Text('320 kcal',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('HEALTHY SWAPS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                const SizedBox(height: 12),
                _swapRow('Cheddar Cheese', 'Feta Crumbs (-40 cal)'),
                _swapRow('Butter', 'Avocado Oil (-60 cal)'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Full Recipe Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _swapRow(String bad, String good) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(bad, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_rounded,
              size: 14, color: Colors.green),
          const SizedBox(width: 12),
          Text(good,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
