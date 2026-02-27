import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../domain/entities/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/datasources/cloudinary_service.dart';

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
  final _cuisineController = TextEditingController(text: 'International');
  final _caloriesController = TextEditingController(text: '350');
  final CloudinaryService _cloudinaryService = CloudinaryService();

  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isVideo = false;
  bool _isUploading = false;
  double _cookTime = 30;
  double _servings = 4;
  bool _isPublic = true;

  Future<void> _pickMedia() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isVideo = false; // Simplified for now
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isVideo = pickedFile.path.toLowerCase().endsWith('.mp4') ||
              pickedFile.path.toLowerCase().endsWith('.mov') ||
              pickedFile.path.toLowerCase().endsWith('.avi');
        });
      }
    }
  }

  void _addIngredient() =>
      setState(() => _ingredientsControllers.add(TextEditingController()));
  void _addStep() =>
      setState(() => _stepsControllers.add(TextEditingController()));

  Future<String?> _uploadImage() async {
    if (kIsWeb) {
      if (_imageBytes == null) return null;
      return await _cloudinaryService.uploadImage(_imageBytes);
    } else {
      if (_imageFile == null) return null;
      return await _cloudinaryService.uploadImage(_imageFile);
    }
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      final imageUrl = await _uploadImage();

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
        cuisine: _cuisineController.text.isNotEmpty
            ? _cuisineController.text
            : 'Various',
        caloriesPerServing: int.tryParse(_caloriesController.text) ?? 350,
        tags: ['User Created'],
        userId: user.uid,
        image: imageUrl ??
            (kIsWeb ? "" : _imageFile?.path) ??
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
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 80,
                leading: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                centerTitle: true,
                title: const Text('New Recipe',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                actions: [
                  TextButton(
                    onPressed: _saveRecipe,
                    child: const Text('Done',
                        style: TextStyle(
                            color: Color(0xFF24DC3D), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Area
                        GestureDetector(
                          onTap: _pickMedia,
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              image: (kIsWeb
                                          ? _imageBytes != null
                                          : _imageFile != null) &&
                                      !_isVideo
                                  ? DecorationImage(
                                      image: (kIsWeb
                                          ? MemoryImage(_imageBytes!)
                                          : FileImage(_imageFile!)) as ImageProvider,
                                      fit: BoxFit.cover)
                                  : null,
                            ),
                            child: (kIsWeb ? _imageBytes == null : _imageFile == null)
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
                                : _isVideo
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.videocam,
                                                color: Colors.white, size: 48),
                                            SizedBox(height: 8),
                                            Text('Video Selected',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('RECIPE TITLE',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'e.g. Grandma\'s Spicy Pasta',
                              hintStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1)),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Name required' : null,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CUISINE',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _cuisineController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        hintText: 'e.g. Italian',
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1)),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CALORIES',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _caloriesController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        hintText: 'e.g. 450',
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1)),
                                    validator: (v) =>
                                        (v == null || int.tryParse(v) == null)
                                            ? 'Invalid'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                                          color: Colors.white70)),
                                  Slider(
                                    value: _cookTime,
                                    min: 5,
                                    max: 120,
                                    divisions: 23,
                                    activeColor: const Color(0xFF24DC3D),
                                    inactiveColor: Colors.white24,
                                    onChanged: (v) => setState(() => _cookTime = v),
                                  ),
                                  Center(
                                      child: Text('${_cookTime.toInt()} min',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
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
                                          color: Colors.white70)),
                                  Slider(
                                    value: _servings,
                                    min: 1,
                                    max: 10,
                                    divisions: 9,
                                    activeColor: const Color(0xFF24DC3D),
                                    inactiveColor: Colors.white24,
                                    onChanged: (v) => setState(() => _servings = v),
                                  ),
                                  Center(
                                      child: Text('${_servings.toInt()}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text('Ingredients',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 16),
                        ...List.generate(
                            _ingredientsControllers.length,
                            (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                              controller:
                                                  _ingredientsControllers[index],
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Item required'
                                                      : null,
                                              decoration: InputDecoration(
                                                  hintText: 'e.g. 2 cups flour',
                                                  hintStyle: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.5)),
                                                  filled: true,
                                                  fillColor: Colors.white
                                                      .withOpacity(0.1)))),
                                      IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red),
                                          onPressed: () => setState(() =>
                                              _ingredientsControllers
                                                  .removeAt(index))),
                                    ],
                                  ),
                                )),
                        TextButton.icon(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add, color: Color(0xFF24DC3D)),
                          label: const Text('Add Ingredient',
                              style: TextStyle(
                                  color: Color(0xFF24DC3D),
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 32),
                        const Text('Step-by-Step',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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
                                                  color: Colors.white,
                                                  fontSize: 12))),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: TextFormField(
                                              controller: _stepsControllers[index],
                                              maxLines: 2,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              validator: (v) =>
                                                  (v == null || v.trim().isEmpty)
                                                      ? 'Step required'
                                                      : null,
                                              decoration: InputDecoration(
                                                  hintText: 'Describe this step...',
                                                  hintStyle: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.5)),
                                                  filled: true,
                                                  fillColor: Colors.white
                                                      .withOpacity(0.1)))),
                                      IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red),
                                          onPressed: () => setState(() =>
                                              _stepsControllers.removeAt(index))),
                                    ],
                                  ),
                                )),
                        TextButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add, color: Color(0xFF24DC3D)),
                          label: const Text('Add next step',
                              style: TextStyle(
                                  color: Color(0xFF24DC3D),
                                  fontWeight: FontWeight.bold)),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('Share this recipe with the community',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white70)),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
