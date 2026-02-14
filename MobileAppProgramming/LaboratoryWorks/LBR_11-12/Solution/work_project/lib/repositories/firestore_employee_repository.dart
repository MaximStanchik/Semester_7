import 'package:cloud_firestore/cloud_firestore.dart';

import '../entity/Employee.dart';

class FirestoreEmployeeRepository {
  final FirebaseFirestore _firestore;

  FirestoreEmployeeRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _firestore.collection('employees');

  Future<List<Employee>> fetchAll() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList(growable: false);
  }

  Stream<List<Employee>> watchAll() {
    return _col.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Employee.fromFirestore(doc))
              .toList(growable: false),
        );
  }

  Future<void> upsert(Employee employee) async {
    final docId = employee.firestoreId;
    if (docId == null || docId.isEmpty) {
      final doc = await _col.add(employee.toFirestore());
      await doc.update({'firestoreId': doc.id});
      return;
    }

    await _col.doc(docId).set(employee.toFirestore(), SetOptions(merge: true));
  }

  Future<void> delete(Employee employee) async {
    final docId = employee.firestoreId;
    if (docId != null && docId.isNotEmpty) {
      await _col.doc(docId).delete();
      return;
    }

    final email = employee.email.trim();
    if (email.isEmpty) {
      throw StateError('Cannot delete employee: firestoreId is missing and email is empty');
    }

    final snap = await _col.where('email', isEqualTo: email).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
