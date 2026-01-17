import 'package:note/FirebaseServices/helper.dart';
import 'package:note/FirebaseServices/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../View/Notes/notes_model.dart';

class AuthResult {
  final bool success;
  final String? message;
  const AuthResult({required this.success, this.message});
}

class Repository extends FirebaseHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseServices _services = FirebaseServices();

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential usr = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (usr.user != null) {
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: "User not found");
      }
    } on FirebaseException catch (e) {
      final message = getErrorMessage(e);
      return AuthResult(success: false, message: message);
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential usr = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (usr.user != null) {
        await usr.user?.updateDisplayName(fullName);
        await usr.user?.reload();
        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, message: "Failed to create user");
      }
    } on FirebaseException catch (e) {
      final message = getErrorMessage(e);
      return AuthResult(success: false, message: message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  //Notes --------------------------------
  Future<List<NotesModel>> getNotes() async {
    try {
      final notes = await _services.get(path: 'notes');
      return notes.map((e) => NotesModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addNote({required NotesModel note}) async {
    try {
      return await _services.add(path: 'notes', data: note.toMap());
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> updateNote({required NotesModel note}) async {
    try {
      final isUpdated = await _services.update(
        path: 'notes',
        data: note.toMap(),
        docId: note.id!,
      );
      if (isUpdated) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNote({required String docId}) async {
    try {
      final bool isDelete = await _services.delete(path: 'notes', docId: docId);
      if (isDelete) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
