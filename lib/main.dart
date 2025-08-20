import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const BloodGroupPredictorApp());
}

class BloodGroupPredictorApp extends StatelessWidget {
  const BloodGroupPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Group Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8F6FF),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const PredictorScreen(),
    );
  }
}

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  String? motherGroup;
  String? fatherGroup;
  Map<String, double> results = {};

  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];

  /// Prediction logic (unchanged)
  Map<String, double> predict(String m, String f) {
    Map<String, List<String>> aboMap = {
      "A": ["A", "O"],
      "B": ["B", "O"],
      "AB": ["A", "B"],
      "O": ["O", "O"],
    };

    String extractABO(String bg) =>
        bg.contains("AB") ? "AB" : bg.substring(0, 1);
    String extractRh(String bg) => bg.endsWith("+") ? "+" : "-";

    String mABO = extractABO(m);
    String fABO = extractABO(f);
    String mRh = extractRh(m);
    String fRh = extractRh(f);

    List<String> mAlleles = aboMap[mABO]!;
    List<String> fAlleles = aboMap[fABO]!;

    List<String> aboChildren = [];
    for (var a in mAlleles) {
      for (var b in fAlleles) {
        if (a == "A" && b == "A") aboChildren.add("A");
        else if (a == "B" && b == "B") aboChildren.add("B");
        else if ((a == "A" && b == "O") || (a == "O" && b == "A")) aboChildren.add("A");
        else if ((a == "B" && b == "O") || (a == "O" && b == "B")) aboChildren.add("B");
        else if ((a == "A" && b == "B") || (a == "B" && b == "A")) aboChildren.add("AB");
        else aboChildren.add("O");
      }
    }

    List<String> rhChildren = [];
    for (var r1 in [mRh, mRh == "+" ? "-" : "+"]) {
      for (var r2 in [fRh, fRh == "+" ? "-" : "+"]) {
        if (r1 == "+" || r2 == "+") {
          rhChildren.add("+");
        } else {
          rhChildren.add("-");
        }
      }
    }

    Map<String, int> countMap = {};
    for (var abo in aboChildren) {
      for (var rh in rhChildren) {
        String bg = abo + rh;
        countMap[bg] = (countMap[bg] ?? 0) + 1;
      }
    }

    int total = countMap.values.fold(0, (a, b) => a + b);
    return countMap.map((k, v) => MapEntry(k, (v / total * 100)));
  }

  void onPredict() {
    if (motherGroup != null && fatherGroup != null) {
      setState(() {
        results = predict(motherGroup!, fatherGroup!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Group Predictor"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.pinkAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDropdown(
              label: "Mother's Blood Group",
              value: motherGroup,
              onChanged: (val) => setState(() => motherGroup = val),
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: "Father's Blood Group",
              value: fatherGroup,
              onChanged: (val) => setState(() => fatherGroup = val),
            ),
            const SizedBox(height: 30),

            // Predict Button
            GestureDetector(
              onTap: onPredict,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Predict",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Results
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        "👆 Select blood groups and tap Predict",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : AnimatedList(
                      key: GlobalKey<AnimatedListState>(),
                      initialItemCount: results.length,
                      itemBuilder: (context, index, animation) {
                        final entry = results.entries.elementAt(index);
                        return ScaleTransition(
                          scale: animation,
                          child: _buildResultCard(entry.key, entry.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.bloodtype, color: Colors.redAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: bloodGroups
          .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultCard(String group, double percent) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${percent.toStringAsFixed(1)}%",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.redAccent.shade200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
