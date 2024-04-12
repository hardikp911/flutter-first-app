import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collection of data
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('flatdata');

  Future<void> addflat(
      String name, String phoneNumber, String flatNumber, String job) {
    return notes.add({
      'name': name,
      'phoneNumber': phoneNumber,
      'flatNumber': flatNumber,
      'job': job,
      'timestamp': Timestamp.now(),
    });
  }

  //read : get notes
  Stream<QuerySnapshot> getFlatesStream() {
    final flateStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return flateStream;
  }

  //update : update notes given a doc_id
  Future<void> updateflat(String docID, String name, String phoneNumber,
      String flatNumber, String job) {
    return notes.doc(docID).update({
      'name': name,
      'phoneNumber': phoneNumber,
      'flatNumber': flatNumber,
      'job': job,
      'timestamp': Timestamp.now(),
    });
  }

// delete

  Future<void> deleteeflat(String docID) {
    return notes.doc(docID).delete();
  }

  //  to check if already presenmt or not
  Future<bool> checkExistingPhoneNumberAndFlatNumber(
      String phoneNumber, String flatNumber) async {
    QuerySnapshot phoneNumberQuery = await FirebaseFirestore.instance
        .collection('flatdata')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    QuerySnapshot flatNumberQuery = await FirebaseFirestore.instance
        .collection('flatdata')
        .where('flatNumber', isEqualTo: flatNumber)
        .get();

    // Check if any documents exist with the provided phone number or flat number
    if (phoneNumberQuery.docs.isNotEmpty || flatNumberQuery.docs.isNotEmpty) {
      return true; // Phone number or flat number already exists
    } else {
      return false; // Phone number and flat number do not exist
    }
  }
}
