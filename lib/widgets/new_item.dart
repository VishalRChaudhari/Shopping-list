import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglistapp/data/categories.dart';
import 'package:shoppinglistapp/models/Grocery_Item.dart';
import 'package:shoppinglistapp/models/category.dart';

import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedcategory = categories[Categories.vegetables];

  void _onsave() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      final url = Uri.https(
          'shopping-list-7e9e1-default-rtdb.asia-southeast1.firebasedatabase.app',
          'shopping-list.json');

      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: json.encode(
          {
            'name': _enteredName,
            'Quantity': _enteredQuantity,
            'Category': _selectedcategory!.title,
          },
        ),
      );
      final Map<String, dynamic> resdata = json.decode(response.body);

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
        id: resdata['name'],
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _selectedcategory!,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 0) {
                          return 'Must be a valid positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _enteredQuantity.toString(),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedcategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 14,
                                  width: 14,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedcategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formkey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: _onsave,
                    child: const Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
