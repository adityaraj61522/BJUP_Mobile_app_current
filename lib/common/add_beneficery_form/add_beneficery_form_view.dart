import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/response_models/add_beneficery_request/add_beneficery_request.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Model provided in the prompt

class AddBeneficiaryScreen extends StatefulWidget {
  @override
  _AddBeneficiaryScreenState createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();

  final submitTriggered = false.obs;

  // Form controllers
  TextEditingController _villageController = TextEditingController();
  TextEditingController _houseHoldNameController = TextEditingController();
  String? _hhGender;
  TextEditingController _familyHeadController = TextEditingController();
  TextEditingController _beneficiaryNameController = TextEditingController();
  TextEditingController _guardianController = TextEditingController();
  String? _beneficiaryGender;
  TextEditingController _ageController = TextEditingController();
  bool? _disability;
  String? _socialGroup;
  String? _category;
  TextEditingController _idTypeController = TextEditingController();
  TextEditingController _idNameController = TextEditingController();
  String? _idType;

  // Dropdown options (replace with your actual data)
  List<String> _villageOptions = ['Village A', 'Village B', 'Village C'];
  List<String> _socialGroupOptions = [
    'SC',
    'ST',
    'BC / OBC',
    'General',
    'Other'
  ];
  List<String> _categoryOptions = [
    'Pregnant Women',
    'Lactating Women',
    'Widow / Single Women',
    'PWDs benefitted',
    'Women Headed Family',
    'Economically backward family (Rs 50000 or less annual income)',
    'A family where members are migrant workers',
    'Others'
  ];
  List<String> genderTypeList = ['Make', 'Female', 'Others'];
  List<String> disabilityTypeList = ['Yes', 'No'];

  Future<void> _submitForm() async {
    submitTriggered.value = true;
    if (_formKey.currentState!.validate()) {
      // Create the BeneficiaryRequest object
      BeneficiaryRequest request = BeneficiaryRequest(
        villagecode: _villageController.text,
        panchayat: '', // You might need a separate field for this
        blockcode: '', // You might need a separate field for this
        districtcode: '', // You might need a separate field for this
        statecode: '', // You might need a separate field for this
        hhname: _houseHoldNameController.text,
        hhgender: _hhGender!.isNotEmpty
            ? (genderTypeList.indexOf(_hhGender!) + 1).toString()
            : '',
        hof: _familyHeadController.text,
        guardian: _guardianController.text,
        sex: _beneficiaryGender!.isNotEmpty
            ? (genderTypeList.indexOf(_beneficiaryGender!) + 1).toString()
            : '',
        age: _ageController.text,
        socialgroup: _socialGroup!.isNotEmpty
            ? (_socialGroupOptions.indexOf(_socialGroup!) + 1).toString()
            : '',
        disability: _disability == true ? '1' : '2',
        category: _category!.isNotEmpty
            ? (_categoryOptions.indexOf(_category!) + 1).toString()
            : '',
        idname:
            _idNameController.text, // Assuming beneficiary name is the ID name
        idtype: _idTypeController.text,
        projectid: 'YOUR_PROJECT_ID', // Replace with your project ID
        partnerid: 'YOUR_PARTNER_ID', // Replace with your partner ID
      );

      // Convert the object to JSON
      String jsonData = request.toJsonString();
      print('Payload: $jsonData');

      // Replace with your API endpoint
      final String apiUrl = 'YOUR_API_ENDPOINT';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonData,
        );

        if (response.statusCode == 200) {
          // API call successful
          print('API Response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Beneficiary added successfully!')),
          );
          // Optionally clear the form
          _formKey.currentState!.reset();
          _villageController.clear();
          _houseHoldNameController.clear();
          _hhGender = null;
          _familyHeadController.clear();
          _beneficiaryNameController.clear();
          _guardianController.clear();
          _beneficiaryGender = null;
          _ageController.clear();
          _disability = null;
          _socialGroup = null;
          _category = null;
          _idNameController.clear();
          _idType = null;
        } else {
          // API call failed
          print('API Error: ${response.statusCode}, ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add beneficiary.')),
          );
        }
      } catch (error) {
        print('Error sending request: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Beneficiary',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.white,
            ),
            onPressed: () => {
              sessionManager.forceLogout(),
            },
          ),
        ],
        backgroundColor: AppColors.green,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
                  fit: BoxFit.fitWidth, // Covers the entire screen
                  opacity: 0.1,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Select Village
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Village',
                        border: OutlineInputBorder(),
                      ),
                      value: _villageController.text.isNotEmpty
                          ? _villageController.text
                          : null,
                      items: _villageOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _villageController.text = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a village';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // House hold name
                    TextFormField(
                      controller: _houseHoldNameController,
                      decoration: InputDecoration(
                        labelText: 'House hold name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter house hold name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Gender (Household)
                    Text('Gender (Household)'),
                    Row(
                      children: <Widget>[
                        Radio<String>(
                          value: 'Male',
                          groupValue: _hhGender,
                          onChanged: (String? value) {
                            setState(() {
                              _hhGender = value;
                            });
                          },
                        ),
                        Text('Male'),
                        SizedBox(width: 16.0),
                        Radio<String>(
                          value: 'Female',
                          groupValue: _hhGender,
                          onChanged: (String? value) {
                            setState(() {
                              _hhGender = value;
                            });
                          },
                        ),
                        Text('Female'),
                        SizedBox(width: 16.0),
                        Radio<String>(
                          value: 'Other',
                          groupValue: _hhGender,
                          onChanged: (String? value) {
                            setState(() {
                              _hhGender = value;
                            });
                          },
                        ),
                        Text('Other'),
                      ],
                    ),
                    if (submitTriggered.value && _hhGender == null)
                      Text(
                        'Please select household gender',
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 16.0),

                    // Family Head
                    TextFormField(
                      controller: _familyHeadController,
                      decoration: InputDecoration(
                        labelText: 'Family Head',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter family head name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Beneficiary Name
                    TextFormField(
                      controller: _beneficiaryNameController,
                      decoration: InputDecoration(
                        labelText: 'Beneficiary Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter beneficiary name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Guardian
                    TextFormField(
                      controller: _guardianController,
                      decoration: InputDecoration(
                        labelText: 'Guardian',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Gender (Beneficiary)
                    Text('Gender (Beneficiary)'),
                    Row(
                      children: <Widget>[
                        Radio<String>(
                          value: 'Male',
                          groupValue: _beneficiaryGender,
                          onChanged: (String? value) {
                            setState(() {
                              _beneficiaryGender = value;
                            });
                          },
                        ),
                        Text('Male'),
                        SizedBox(width: 16.0),
                        Radio<String>(
                          value: 'Female',
                          groupValue: _beneficiaryGender,
                          onChanged: (String? value) {
                            setState(() {
                              _beneficiaryGender = value;
                            });
                          },
                        ),
                        Text('Female'),
                        SizedBox(width: 16.0),
                        Radio<String>(
                          value: 'Other',
                          groupValue: _beneficiaryGender,
                          onChanged: (String? value) {
                            setState(() {
                              _beneficiaryGender = value;
                            });
                          },
                        ),
                        Text('Other'),
                      ],
                    ),
                    if (submitTriggered.value && _beneficiaryGender == null)
                      Text(
                        'Please select beneficiary gender',
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 16.0),

                    // Age
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Disability
                    Text('Disability'),
                    Row(
                      children: <Widget>[
                        Radio<bool>(
                          value: true,
                          groupValue: _disability,
                          onChanged: (bool? value) {
                            setState(() {
                              _disability = value;
                            });
                          },
                        ),
                        Text('Yes'),
                        SizedBox(width: 16.0),
                        Radio<bool>(
                          value: false,
                          groupValue: _disability,
                          onChanged: (bool? value) {
                            setState(() {
                              _disability = value;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    if (submitTriggered.value && _disability == null)
                      Text(
                        'Please select disability status',
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 16.0),

                    // Select Social Group
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Social Group',
                        border: OutlineInputBorder(),
                      ),
                      value: _socialGroup,
                      items: _socialGroupOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _socialGroup = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a social group';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Select Categories
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Categories',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true, // Add this line
                      value: _category,
                      items: _categoryOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Id type

                    TextFormField(
                      controller: _idTypeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ID Type',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ID Type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // ID Name
                    TextFormField(
                      controller: _idNameController,
                      decoration: InputDecoration(
                        labelText: 'ID Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ID name';
                        }
                        return null;
                      },
                    ),
                    // DropdownButtonFormField<String>(
                    //   decoration: InputDecoration(
                    //     labelText: 'Id type',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   value: _idType,
                    //   items: _idTypeOptions.map((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       _idType = newValue;
                    //     });
                    //   },
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please select an ID type';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    SizedBox(height: 24.0),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Add Beneficiary'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddBeneficiaryScreen(),
  ));
}
