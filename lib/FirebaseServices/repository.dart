import 'package:firebase_auth/firebase_auth.dart';
import 'package:note/FirebaseServices/services.dart';
import 'package:note/View/Notes/notes_model.dart';

class Repository {
  final FirebaseServices _services = FirebaseServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _notesCollection = 'notes';

  // ========== AUTHENTICATION METHODS ==========

  /// Sign In with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign Up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await userCredential.user?.reload();
      }

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  // ========== NOTES CRUD METHODS ==========

  /// Get all notes (tanpa filter user)
  Future<List<NotesModel>> getNotes() async {
    try {
      final notesData = await _services.get(path: _notesCollection);

      // Return semua notes tanpa filter userId
      return notesData.map((data) => NotesModel.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add new note (tanpa userId)
  Future<String> addNote({required NotesModel note}) async {
    try {
      final noteData = note.toMap();
      // Tidak perlu tambahkan userId

      final docId = await _services.add(path: _notesCollection, data: noteData);

      return docId;
    } catch (e) {
      return '';
    }
  }

  /// Update existing note
  Future<bool> updateNote({required NotesModel note}) async {
    try {
      if (note.id == null || note.id!.isEmpty) return false;

      final noteData = note.toMap();
      // Remove id from data since it's used as docId
      noteData.remove('id');

      return await _services.update(
        path: _notesCollection,
        data: noteData,
        docId: note.id!,
      );
    } catch (e) {
      return false;
    }
  }

  /// Delete note
  Future<bool> deleteNote({required String docId}) async {
    try {
      return await _services.delete(path: _notesCollection, docId: docId);
    } catch (e) {
      return false;
    }
  }
}
