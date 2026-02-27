import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/recipe.dart';
import '../../providers/ai_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.share, color: Colors.black),
                    ),
                    onPressed: () {},
                  ),
                  Consumer<RecipeProvider>(
                    builder: (context, provider, child) {
                      final isFav = provider.isFavorite(widget.recipe.id);
                      return IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          if (user != null) {
                            provider.toggleFavorite(user.uid, widget.recipe);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: widget.recipe.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        border: Border(
                            top: BorderSide(
                                color: Colors.white.withOpacity(0.1))),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'HEALTHY CHOICE',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.recipe.name,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _infoCard(Icons.local_fire_department,
                                  '${widget.recipe.caloriesPerServing} kcal'),
                              _infoCard(Icons.timer,
                                  '${widget.recipe.prepTimeMinutes + widget.recipe.cookTimeMinutes} min'),
                              _infoCard(
                                  Icons.bar_chart, widget.recipe.difficulty),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Tabs
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white60,
                            indicatorColor: const Color(0xFF24DC3D),
                            indicatorWeight: 3,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            tabs: const [
                              Tab(text: 'Ingredients'),
                              Tab(text: 'Steps'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tab Content - Render directly based on index to avoid height issues in Slivers
                          _tabController.index == 0
                              ? _ingredientsList()
                              : _stepsList(),
                          const SizedBox(height: 100), // Space for button
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Start Cook Button
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF24DC3D),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF24DC3D).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Start Cook',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF24DC3D), size: 24),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _ingredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ingredients',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('${widget.recipe.servings} Servings',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(widget.recipe.ingredients.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF24DC3D),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.recipe.ingredients[index],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Text('1 cup',
                    style: TextStyle(
                        color: Colors.white60, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        // AI Tip Highlight
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF24DC3D).withOpacity(0.1)),
          ),
          child: Row(
            children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24DC3D).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF24DC3D), size: 30),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MEALMATE AI',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24DC3D))),
                    Text(
                      'Want to know how to pick the perfect avocado for this bowl?',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(widget.recipe.instructions.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF24DC3D).withOpacity(0.1),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Color(0xFF24DC3D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.recipe.instructions[index],
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
