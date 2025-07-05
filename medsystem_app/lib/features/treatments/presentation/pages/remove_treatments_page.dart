import 'package:flutter/material.dart';

class RemoveTreatmentsPage extends StatefulWidget {
  const RemoveTreatmentsPage({super.key});

  @override
  State<RemoveTreatmentsPage> createState() => _RemoveTreatmentsPageState();
}

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class _RemoveTreatmentsPageState extends State<RemoveTreatmentsPage> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen y opacidad
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/fondo.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.transparent),
                  onPressed: () {
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.9,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Treatment List',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color.fromRGBO(46, 63, 110, 1),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Select the treatment you want to remove:',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 20),
                              Form(
                                child: Column(
                                  children: <Widget>[
                                    DropdownButtonFormField<String>(
                                      value: dropdownValue,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 16.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue!;
                                        });
                                      },
                                      items: list.map<DropdownMenuItem<String>>(
                                        (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Acción para eliminar el tratamiento seleccionado
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Treatment '$dropdownValue' removed"),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14.0, horizontal: 24.0),
                                      ),
                                      child: const Text(
                                        "Remove",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
