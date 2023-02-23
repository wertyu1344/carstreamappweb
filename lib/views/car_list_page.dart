import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_looknowstream_web/views/widgets/add_car_dialog.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../firestore_services/firestore_services.dart';

class CarListPage extends StatelessWidget {
  CarListPage({Key? key}) : super(key: key);
  final Stream<QuerySnapshot> _carsStream = FirebaseFirestore.instance
      .collection('cars')
      .orderBy("groupNumber")
      .snapshots();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SimpleUIController simpleUIController = Get.put(SimpleUIController());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (_) {
                return AddCarDialog();
              });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              const Text(
                "Vehicles",
                style: TextStyle(fontSize: 32, color: Colors.black),
              ),
              Row(
                children: [
                  Obx(
                    () => Container(
                      width: 200,
                      child: TextFormField(
                        style: kTextFormFieldStyle(),
                        controller: passwordController,
                        obscureText: simpleUIController.isObscure.value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_open),
                          suffixIcon: IconButton(
                            icon: Icon(
                              simpleUIController.isObscure.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              simpleUIController.isObscureActive();
                            },
                          ),
                          hintText: 'Password',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      if (passwordController.text != "") {
                        await MyFirestoreServices()
                            .updatePassword(passwordController.text);
                        passwordController.clear();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _carsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40,
                        width: 400,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "The license plate number was: " +
                                        data["carPlate"],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Vehicle group number: " +
                                        data["groupNumber"].toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.white, // Background Color
                                  ),
                                  onPressed: () async {
                                    if (data["isSelected"]) {
                                      Get.snackbar("Hata",
                                          "Araç şu an bir tablette seçili olduğu için silinemez",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.black,
                                          colorText: Colors.white);
                                    } else {
                                      await MyFirestoreServices()
                                          .deleteCar(data["id"]);
                                    }
                                  },
                                  child: const Text(
                                    "Delete Vehicle",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
