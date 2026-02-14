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
  final _cuisineController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

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
        ingredients: _ingredientsController.text
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        instructions: _stepsController.text
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        prepTimeMinutes: 20,
        cookTimeMinutes: 30,
        servings: 2,
        difficulty: 'Medium',
        cuisine: _cuisineController.text,
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
      appBar: AppBar(title: const Text('Share Your Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ? const Icon(Icons.add_a_photo,
                          size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (v) => v!.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cuisineController,
                decoration:
                    const InputDecoration(labelText: 'Cuisine (e.g. Italian)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    labelText: 'Ingredients (one per line)'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                    labelText: 'Instructions (one per line)'),
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              if (_isUploading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _saveRecipe,
                  child: const Text('PUBLISH RECIPE'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
