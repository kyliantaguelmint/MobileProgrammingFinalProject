import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final CollectionReference _profiles =
      FirebaseFirestore.instance.collection('profile');

  /// Créer un profil uniquement s'il n'existe pas déjà (via email)
  Future<void> createProfile({
    required String email,
    required String first,
    required String lastname,
  }) async {
    final existing = await _profiles.where('email', isEqualTo: email).limit(1).get();
    if (existing.docs.isEmpty) {
      await _profiles.add({
        'email': email,
        'first': first,
        'lastname': lastname,
      });
    } else {
      // Optionally, update instead
      final id = existing.docs.first.id;
      await updateProfile(id, first: first, lastname: lastname);
    }
  }

  /// Mettre à jour un profil (via ID)
  Future<void> updateProfile(String id, {
    String? email,
    String? first,
    String? lastname,
  }) async {
    final data = <String, dynamic>{};
    if (email != null) data['email'] = email;
    if (first != null) data['first'] = first;
    if (lastname != null) data['lastname'] = lastname;

    await _profiles.doc(id).update(data);
  }

  /// Supprimer un profil
  Future<void> deleteProfile(String id) async {
    await _profiles.doc(id).delete();
  }

  /// Obtenir tous les profils (stream)
  Stream<QuerySnapshot> getProfiles() {
    return _profiles.snapshots();
  }

  /// Obtenir un profil via son ID
  Future<DocumentSnapshot> getProfile(String id) {
    return _profiles.doc(id).get();
  }

  /// Obtenir un seul profil via l'email
  Future<DocumentSnapshot?> getProfileByEmail(String email) async {
    final snapshot = await _profiles.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  /// Obtenir l'ID du document d'un profil via l'email
  Future<String?> getProfileIdByEmail(String email) async {
    final snapshot = await _profiles.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }
}
