import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceApi {
  final CollectionReference expenditure =
      FirebaseFirestore.instance.collection('expenditure');
  Future<void> addexpenditureitem({
    required String name,
    required int amount,
    required Timestamp date,
  }) async {
    return await expenditure
        .doc()
        .set({'name': name, 'amount': amount, 'date': date});
  }

  Future getdocumentid() async {
    List idlist = [];

    try {
      final messages = await expenditure.get();
      for (var message in messages.docs) {
        idlist.add(message.id);
        log(message.id);
      }
      return idlist;
    } catch (e) {
      return null;
    }
  }

  Future updateexpenditureitem({
    required String name,
    required int amount,
    required Timestamp date,
    required String id,
  }) async {
    return await expenditure.doc(id).update(
      {'name': name, 'amount': amount, 'date': date},
    );
  }

  Future deleteexpenditureitem({
    required String id,
  }) async {
    return await expenditure.doc(id).delete();
  }
}
