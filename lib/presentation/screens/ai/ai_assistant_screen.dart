import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _ingredientController = TextEditingController();
  final List<String> _ingredients = [];

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Magic Chef')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\'s in your fridge?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add 2-3 ingredients and let Gemini create a recipe for you!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: const InputDecoration(hintText: 'e.g. Tomato'),
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _ingredients
                  .map((ing) => Chip(
                        label: Text(ing),
                        onDeleted: () =>
                            setState(() => _ingredients.remove(ing)),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _ingredients.isEmpty
                    ? null
                    : () => aiProvider.generateRecipe(_ingredients),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('GENERATE RECIPE'),
              ),
            ),
            const SizedBox(height: 32),
            const Text('AI Suggestion:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: aiProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          aiProvider.aiResponse.isEmpty
                              ? 'Waiting for your ingredients...'
                              : aiProvider.aiResponse,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
