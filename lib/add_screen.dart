import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {

  DateTime selectedDate = DateTime.now();

  String selectedType = "expense";
  List<String> types = ["expense", "income"];

  List<String> expenseCategories = ["Food", "Travel", "Shopping", "Other"];
  List<String> incomeCategories = ["Salary", "Freelance", "Bonus"];

  String selectedCategory = "Food";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void submit() {
    final amount = double.tryParse(amountController.text);
    if (nameController.text.isEmpty || amount == null) return;

    Navigator.pop(context, {
      "name": nameController.text,
      "amount": amount,
      "type": selectedType,
      "category": selectedCategory,
      "date":
      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
    });
  }

  @override
  Widget build(BuildContext context) {

    List<String> categories = selectedType == "expense"
        ? expenseCategories
        : incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                  selectedCategory = selectedType == "expense"
                      ? expenseCategories[0]
                      : incomeCategories[0];
                });
              },
              decoration: const InputDecoration(
                labelText: "Transaction Type",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                TextButton(
                  onPressed: pickDate,
                  child: const Text("Select Date"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                submit();
              },
              child: Text(
                selectedType == "expense"
                    ? "Add Expense"
                    : "Add Income",
              ),
            ),
          ],
        ),
      ),
    );
  }
}