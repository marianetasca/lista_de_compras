import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Stream<QuerySnapshot> getTasksStream() {
    return tasksCollection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<DocumentSnapshot> getTask(String docId) {
    return tasksCollection.doc(docId).get();
  }

  Future<void> addTask(String title, String description) {
    return tasksCollection.add({
      'title': title,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateTask(String docId, String title, String description) {
    return tasksCollection.doc(docId).update({
      'title': title,
      'description': description,
    });
  }

  Future<void> deleteTaks(String docId) {
    return tasksCollection.doc(docId).delete();
  }
} 