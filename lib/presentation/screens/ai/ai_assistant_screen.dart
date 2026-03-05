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
  final ScrollController _scrollController = ScrollController();
  final List<String> _ingredients = [];
  final List<dynamic> _chatHistory = [];

  void _addIngredient() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_controller.text);
        _controller.clear();
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _triggerGeneration() async {
    final text = _controller.text.trim();
    
    // If we have a direct question or no ingredients queued, treat as chat
    if (_ingredients.isEmpty && text.isNotEmpty) {
      final message = text;
      _controller.clear();
      setState(() {
        _chatHistory.add([message]); // Wrap in list to show as "user bubble"
      });
      _scrollToBottom();

      final ai = Provider.of<AIProvider>(context, listen: false);
      final response = await ai.sendMessage(message);
      
      setState(() {
        _chatHistory.add(response);
      });
      _scrollToBottom();
      return;
    }

    if (text.isNotEmpty) {
      _addIngredient();
    }
    
    if (_ingredients.isNotEmpty) {
      final prompt = List<String>.from(_ingredients);
      setState(() {
        _chatHistory.add(prompt);
        _ingredients.clear();
      });
      _scrollToBottom();

      final ai = Provider.of<AIProvider>(context, listen: false);
      await ai.generateRecipe(prompt);
      
      if (ai.generatedRecipe != null) {
        setState(() {
          _chatHistory.add(ai.generatedRecipe!);
        });
      } else if (ai.aiResponse.isNotEmpty) {
        setState(() {
          _chatHistory.add(ai.aiResponse);
        });
      }
      ai.clearResponse();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an ingredient or ask a question!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
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
                            icon: const Icon(Icons.refresh, color: Colors.white70),
                            onPressed: () {
                              Provider.of<AIProvider>(context, listen: false).clearResponse();
                              setState(() {
                                _ingredients.clear();
                                _chatHistory.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Chat cleared")),
                              );
                            }),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(24),
                        children: [
                          // AI Hello
                          _aiBubble(
                              "Hi! I'm your healthy cooking assistant. Tell me what ingredients you have in your fridge, and I'll generate a nutritious recipe for you!"),
                          const SizedBox(height: 24),
                          
                          // Chat History
                          ...(_chatHistory ?? []).map((item) {
                            if (item is List) {
                              return _userIngredientsBubble(item);
                            } else if (item is Recipe) {
                              return Column(
                                children: [
                                  _richRecipeCard(item),
                                  const SizedBox(height: 24),
                                ],
                              );
                            } else if (item is String) {
                              return Column(
                                children: [
                                  _aiBubble(item),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }
                            return const SizedBox();
                          }).toList(),

                          // Current User Input (Drafting)
                          if ((_ingredients ?? []).isNotEmpty)
                            _userIngredientsBubble(_ingredients),

                          // Active loading state
                          Consumer<AIProvider>(
                            builder: (context, ai, child) {
                              if (ai.isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                      child: CircularProgressIndicator(color: Color(0xFF24DC3D))),
                                );
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
                                onSubmitted: (_) => _triggerGeneration(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                             onTap: _triggerGeneration,
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
          ),
        ],
      ),
    );
  }

  Widget _userIngredientsBubble(dynamic ingredients) {
    final List<dynamic> list = ingredients is List ? ingredients : [];
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: list.map((ing) => _ingredientChip(ing.toString())).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _aiBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF24DC3D).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Color(0xFF24DC3D), size: 30),
        ),
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
