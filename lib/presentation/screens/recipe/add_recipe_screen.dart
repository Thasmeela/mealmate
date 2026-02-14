import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../domain/entities/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<TextEditingController> _ingredientsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _stepsControllers = [
    TextEditingController()
  ];

  File? _image;
  bool _isUploading = false;
  double _cookTime = 30;
  double _servings = 4;
  bool _isPublic = true;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _addIngredient() =>
      setState(() => _ingredientsControllers.add(TextEditingController()));
  void _addStep() =>
      setState(() => _stepsControllers.add(TextEditingController()));

  Future<String?> _uploadImage(String userId) async {
    if (_image == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('recipes')
        .child(userId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(_image!);
    return await ref.getDownloadURL();
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      final imageUrl = await _uploadImage(user.uid);

      final newRecipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        ingredients: _ingredientsControllers
            .map((c) => c.text)
            .where((s) => s.isNotEmpty)
            .toList(),
        instructions: _stepsControllers
            .map((c) => c.text)
            .where((s) => s.isNotEmpty)
            .toList(),
        prepTimeMinutes: 10,
        cookTimeMinutes: _cookTime.toInt(),
        servings: _servings.toInt(),
        difficulty: 'Medium',
        cuisine: 'Various',
        caloriesPerServing: 350,
        tags: ['User Created'],
        userId: user.uid,
        image: imageUrl ??
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        rating: 4.5,
        reviewCount: 0,
        mealType: ['Dinner'],
        isUserGenerated: true,
      );

      await Provider.of<RecipeProvider>(context, listen: false)
          .addUserRecipe(newRecipe);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        centerTitle: true,
        title: const Text('New Recipe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text('Done',
                style: TextStyle(
                    color: Color(0xFF24DC3D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBF9),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFE8F5E9)),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFE8F5E9),
                              child: Icon(Icons.camera_alt,
                                  color: Color(0xFF24DC3D)),
                            ),
                            SizedBox(height: 12),
                            Text('UPLOAD IMAGE/VIDEO',
                                style: TextStyle(
                                    color: Color(0xFF24DC3D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            Text('up to 20MB (.jpg .png .mp4)',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 10)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              const Text('RECIPE TITLE',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    hintText: 'e.g. Grandma\'s Spicy Pasta'),
                validator: (v) => v!.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('COOK TIME',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        Slider(
                          value: _cookTime,
                          min: 5,
                          max: 120,
                          divisions: 23,
                          activeColor: const Color(0xFF24DC3D),
                          onChanged: (v) => setState(() => _cookTime = v),
                        ),
                        Center(
                            child: Text('${_cookTime.toInt()} min',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SERVINGS',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        Slider(
                          value: _servings,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: const Color(0xFF24DC3D),
                          onChanged: (v) => setState(() => _servings = v),
                        ),
                        Center(
                            child: Text('${_servings.toInt()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...List.generate(
                  _ingredientsControllers.length,
                  (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                                    controller: _ingredientsControllers[index],
                                    decoration: const InputDecoration(
                                        hintText: 'e.g. 2 cups flour'))),
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () => setState(() =>
                                    _ingredientsControllers.removeAt(index))),
                          ],
                        ),
                      )),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, color: Color(0xFF24DC3D)),
                label: const Text('Add Ingredient',
                    style: TextStyle(
                        color: Color(0xFF24DC3D), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              const Text('Step-by-Step',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...List.generate(
                  _stepsControllers.length,
                  (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFF24DC3D),
                                child: Text('${index + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: _stepsControllers[index],
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                        hintText: 'Describe this step...'))),
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () => setState(
                                    () => _stepsControllers.removeAt(index))),
                          ],
                        ),
                      )),
              TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add, color: Color(0xFF24DC3D)),
                label: const Text('Add next step',
                    style: TextStyle(
                        color: Color(0xFF24DC3D), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Make Public',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Share this recipe with the community',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Switch(
                    value: _isPublic,
                    activeColor: const Color(0xFF24DC3D),
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              if (_isUploading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24DC3D)),
                  child: const Text('Create Recipe'),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
