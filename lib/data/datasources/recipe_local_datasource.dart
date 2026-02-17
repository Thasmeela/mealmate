import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe.dart';
import '../../core/constants/app_constants.dart';

class RecipeLocalDataSource {
  final FirebaseFirestore firestore;

  RecipeLocalDataSource({required this.firestore});

  // User-generated recipes
  Future<void> addUserRecipe(Recipe recipe) async {
    await firestore
        .collection(AppConstants.recipesCollection)
        .add(recipe.toJson());
  }

  Future<List<Recipe>> getUserRecipes(String userId) async {
    final snapshot = await firestore
        .collection(AppConstants.recipesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id_str'] = doc.id;
      return Recipe.fromJson(data);
    }).toList();
  }

  Future<List<Recipe>> getAllUserRecipes() async {
    final snapshot = await firestore
        .collection(AppConstants.recipesCollection)
        .where('isUserGenerated', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id_str'] = doc.id;
      return Recipe.fromJson(data);
    }).toList();
  }

  Future<void> updateRecipe(String docId, Recipe recipe) async {
    await firestore
        .collection(AppConstants.recipesCollection)
        .doc(docId)
        .update(recipe.toJson());
  }

  Future<void> deleteRecipe(String docId) async {
    await firestore
        .collection(AppConstants.recipesCollection)
        .doc(docId)
        .delete();
  }

  // Favorites
  Future<void> toggleFavorite(String userId, Recipe recipe) async {
    final ref = firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesCollection)
        .doc(recipe.id.toString());

    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set(recipe.toJson());
    }
  }

  Stream<List<Recipe>> getFavorites(String userId) {
    return firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
  }
}
