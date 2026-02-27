import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe.dart';
import '../../data/datasources/recipe_remote_datasource.dart';
import '../../data/datasources/recipe_local_datasource.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRemoteDataSource _remoteDataSource =
      RecipeRemoteDataSource(client: http.Client());
  final RecipeLocalDataSource _localDataSource =
      RecipeLocalDataSource(firestore: FirebaseFirestore.instance);

  List<Recipe> _publicRecipes = [];
  List<Recipe> _userRecipes = [];
  List<Recipe> _allUserRecipes = [];
  List<Recipe> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get publicRecipes => _publicRecipes;
  List<Recipe> get userRecipes => _userRecipes;
  List<Recipe> get allUserRecipes => _allUserRecipes;
  List<Recipe> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPublicRecipes() async {
    _setLoading(true);
    _error = null;
    try {
      _publicRecipes = await _remoteDataSource.getAllRecipes();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> searchRecipes(String query) async {
    _setLoading(true);
    _error = null;
    try {
      if (query.isEmpty) {
        await fetchPublicRecipes();
      } else {
        _publicRecipes = await _remoteDataSource.searchRecipes(query);
      }
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> filterRecipesByTag(String tag) async {
    _setLoading(true);
    _error = null;
    try {
      if (tag == 'All Recipes') {
        await fetchPublicRecipes();
      } else {
        final recipes = await _remoteDataSource.getRecipesByTag(tag.toLowerCase());
        if (recipes.isEmpty) {
          // Fallback to search if tag returns nothing (Common for specific foods like 'Burgers')
          _publicRecipes = await _remoteDataSource.searchRecipes(tag);
        } else {
          _publicRecipes = recipes;
        }
      }
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchUserRecipes(String userId) async {
    try {
      _userRecipes = await _localDataSource.getUserRecipes(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> fetchAllUserRecipes() async {
    _setLoading(true);
    try {
      _allUserRecipes = await _localDataSource.getAllUserRecipes();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> addUserRecipe(Recipe recipe) async {
    await _localDataSource.addUserRecipe(recipe);
    await fetchUserRecipes(recipe.userId);
    await fetchAllUserRecipes();
  }

  Future<void> toggleFavorite(String userId, Recipe recipe) async {
    await _localDataSource.toggleFavorite(userId, recipe);
    // Refresh favorites list is missing here, usually handled via stream or manual refresh
  }

  void listenToFavorites(String userId) {
    _localDataSource.getFavorites(userId).listen((favs) {
      _favorites = favs;
      notifyListeners();
    });
  }

  bool isFavorite(int id) {
    return _favorites.any((r) => r.id == id);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
