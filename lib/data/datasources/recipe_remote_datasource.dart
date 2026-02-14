import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/recipe.dart';
import '../../core/constants/app_constants.dart';

class RecipeRemoteDataSource {
  final http.Client client;

  RecipeRemoteDataSource({required this.client});

  Future<List<Recipe>> getAllRecipes() async {
    final response = await client.get(
      Uri.parse('${AppConstants.dummyJsonBaseUrl}/recipes'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await client.get(
      Uri.parse('${AppConstants.dummyJsonBaseUrl}/recipes/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }

  Future<List<Recipe>> getRecipesByTag(String tag) async {
    final response = await client.get(
      Uri.parse('${AppConstants.dummyJsonBaseUrl}/recipes/tag/$tag'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes by tag');
    }
  }
}
