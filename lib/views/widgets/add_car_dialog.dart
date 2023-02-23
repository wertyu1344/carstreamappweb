import 'package:flutter/material.dart';

import '../../firestore_services/firestore_services.dart';

var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

class AddCarDialog extends StatefulWidget {
  AddCarDialog({Key? key}) : super(key: key);

  @override
  State<AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  TextEditingController textEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String selectedGroupValue = list.first.toString();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: 200,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              myTextFormField(),
              const SizedBox(height: 10),
              dropdown(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "İptal",
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () async {
                        await MyFirestoreServices().addCar(
                            textEditingController.text, selectedGroupValue);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Ekle",
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  SizedBox myTextFormField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a license plate';
          }
          return null;
        },
        controller: textEditingController,
        decoration: InputDecoration(
            hintText: "The license plate number was",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  Widget dropdown() {
    return DropdownButton(
        value: selectedGroupValue,
        items: list.map<DropdownMenuItem<String>>((int value) {
          return DropdownMenuItem<String>(
            value: value.toString(),
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          selectedGroupValue = value ?? "";
          setState(() {});
        });
  }

  SizedBox myTextFormField2() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen bir grup deçin';
          }
          return null;
        },
        controller: textEditingController,
        decoration: InputDecoration(
            hintText: "Araç grup no",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }
}
