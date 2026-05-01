import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  Map<String, double> getExpenseData(List<QueryDocumentSnapshot> docs) {
    Map<String, double> data = {};
    for (var doc in docs) {
      var item = doc.data() as Map<String, dynamic>;
      if (item["type"] == "expense") {
        String category = item["category"];
        double amount = (item["amount"] as num).toDouble();
        data[category] = (data[category] ?? 0) + amount;
      }
    }
    return data;
  }

  Map<String, double> getIncomeData(List<QueryDocumentSnapshot> docs) {
    Map<String, double> data = {};
    for (var doc in docs) {
      var item = doc.data() as Map<String, dynamic>;
      if (item["type"] == "income") {
        String category = item["category"];
        double amount = (item["amount"] as num).toDouble();
        data[category] = (data[category] ?? 0) + amount;
      }
    }
    return data;
  }

  Map<String, double> getIncomeVsExpense(List<QueryDocumentSnapshot> docs) {
    double income = 0;
    double expense = 0;

    for (var doc in docs) {
      var item = doc.data() as Map<String, dynamic>;
      if (item["type"] == "income") {
        income += (item["amount"] as num).toDouble();
      } else {
        expense += (item["amount"] as num).toDouble();
      }
    }

    return {
      "Income": income,
      "Expense": expense,
    };
  }

  List<PieChartSectionData> buildSections(Map<String, double> data) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.yellow,
    ];

    int i = 0;

    return data.entries.map((entry) {
      final section = PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 60,
        color: colors[i % colors.length],
      );
      i++;
      return section;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          final expenseData = getExpenseData(docs);
          final incomeData = getIncomeData(docs);
          final overviewData = getIncomeVsExpense(docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const Text(
                  "Income vs Expense",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                overviewData.values.every((v) => v == 0)
                    ? const Text("No data")
                    : SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: buildSections(overviewData),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Expense Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                expenseData.isEmpty
                    ? const Text("No expense data")
                    : SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: buildSections(expenseData),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Income Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                incomeData.isEmpty
                    ? const Text("No income data")
                    : SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: buildSections(incomeData),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}