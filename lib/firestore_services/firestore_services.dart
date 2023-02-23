import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MyFirestoreServices {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');
  CollectionReference passwordCollection =
      FirebaseFirestore.instance.collection('password');

  Future<void> addCar(String plate, groupNumber) {
    var id = const Uuid().v4();
    print("güncel id $id");
    return cars
        .doc(id)
        .set({
          "deviceId": "",
          'id': id,
          'carPlate': plate,
          'isSelected': false,
          "groupNumber": int.parse(groupNumber)
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updateCar(String id, bool isSelected) {
    return cars
        .doc(id)
        .set({'id': id, 'isSelected': isSelected}, SetOptions(merge: true))
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updatePassword(String password) {
    return passwordCollection
        .doc("password")
        .set({
          'password': password,
        }, SetOptions(merge: true))
        .then((value) => print("Şifre değişti"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> deleteCar(String id) {
    return cars.doc(id).delete();
  }

  Future<bool> checkPassword(String password) async {
    bool isTrue = false;
    await FirebaseFirestore.instance
        .collection('password')
        .doc("password")
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> value) {
      var data = value.data();
      if (password == data!["password"]) {
        print("true dönecem");
        isTrue = true;
      } else {
        isTrue = false;
      }
    });
    return isTrue;
  }
}
