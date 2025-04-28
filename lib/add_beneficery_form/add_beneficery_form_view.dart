import 'package:bjup_application/common/api_service/api_service.dart';
import 'package:bjup_application/common/color_pallet/color_pallet.dart';
import 'package:bjup_application/common/hive_storage_controllers/village_list_storage.dart';
import 'package:bjup_application/common/response_models/get_village_details_response/get_village_details_response.dart';
import 'package:bjup_application/common/response_models/get_village_list_response/get_village_list_response.dart';
import 'package:bjup_application/common/response_models/user_response/user_response.dart';
import 'package:bjup_application/common/response_models/add_beneficery_request/add_beneficery_request.dart';
import 'package:bjup_application/common/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'dart:convert';

// Define model classes for village details response

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  _AddBeneficiaryScreenState createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();

  final submitTriggered = false.obs;
  final SessionManager _sessionManager = SessionManager();
  final ApiService apiService = ApiService();
  final errorText = ''.obs;
  final isLoading = false.obs;

  final selectedProject = ''.obs;
  final selectedAnamitorId = ''.obs;
  final selectedOfficeId = ''.obs;
  String projectId = '';
  String projectTitle = '';
  String officeName = '';
  UserLoginResponse? userData;

  // Form controllers
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _houseHoldNameController =
      TextEditingController();
  String? _hhGender;
  final TextEditingController _familyHeadController = TextEditingController();
  final TextEditingController _beneficiaryNameController =
      TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  String? _beneficiaryGender;
  final TextEditingController _ageController = TextEditingController();
  bool? _disability;
  String? _socialGroup;
  String? _category;
  final TextEditingController _idTypeController = TextEditingController();
  final TextEditingController _idNameController = TextEditingController();

  // Village details variables
  final panchayat = ''.obs;
  final blockCode = ''.obs;
  final districtCode = ''.obs;
  final stateCode = ''.obs;

  // Dropdown options (replace with your actual data)
  final List<String> _socialGroupOptions = [
    'SC',
    'ST',
    'BC / OBC',
    'General',
    'Other'
  ];
  final List<String> _categoryOptions = [
    'Pregnant Women',
    'Lactating Women',
    'Widow / Single Women',
    'PWDs benefitted',
    'Women Headed Family',
    'Economically backward family (Rs 50000 or less annual income)',
    'A family where members are migrant workers',
    'Others'
  ];
  List<String> genderTypeList = ['Male', 'Female', 'Others'];
  List<String> disabilityTypeList = ['Yes', 'No'];

  final VillageStorageService villageStorageService = VillageStorageService();
  final villageList = <VillagesList>[].obs;

  Future<void> getVillageList() async {
    try {
      final villageListData =
          await villageStorageService.getAllVillagesForProject(
        projectId: selectedProject.value,
      );
      final seenIds = <String>{};
      villageList.clear(); // Clear before adding
      villageList.addAll(villageListData.where((item) {
        return seenIds.add(item.villageId);
      }));
    } catch (e) {
      _handleError('Failed to load village list: $e');
    }
  }

  // New function to fetch village details
  Future<void> getVillageDetails(String villageCode) async {
    try {
      isLoading.value = true;

      var formData = FormData.fromMap({
        "village_code": villageCode,
      });

      var response = await apiService.post(
        "/getVillageDetail.php",
        formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': '*/*',
          },
        ),
      );

      if (response != null) {
        var data = response.data;

        if (data['response_code'] == 200) {
          VillageDetailResponse villageDetailResponse =
              VillageDetailResponse.fromJson(data);
          VillageInfo villageInfo = villageDetailResponse.data.villageInfo;

          // Update the village details variables
          panchayat.value = villageInfo.panchayat;
          blockCode.value = villageInfo.blockCode;
          districtCode.value = villageInfo.districtCode;
          stateCode.value = villageInfo.stateCode;

          print('Village details fetched successfully');
          print('Panchayat: ${panchayat.value}');
          print('Block Code: ${blockCode.value}');
          print('District Code: ${districtCode.value}');
          print('State Code: ${stateCode.value}');
        } else {
          _handleError('Failed to fetch village details: ${data['message']}');
        }
      } else {
        _handleError('Failed to fetch village details: No response');
      }
    } catch (e) {
      _handleError('Error fetching village details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = Get.arguments;
      print(args);
      selectedProject.value = args['projectId'];
      projectTitle = args['projectTitle'];
      userData = await _sessionManager.getUserData();
      await getVillageList();
      officeName = userData!.office.officeTitle;
      selectedOfficeId.value = userData!.office.id;
      selectedAnamitorId.value = userData!.userId;
    });
  }

  Future<void> _handleError(String message) async {
    errorText.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
    );
  }

  Future<void> _submitForm() async {
    submitTriggered.value = true;
    if (_formKey.currentState!.validate()) {
      // Create the BeneficiaryRequest object
      BeneficiaryRequest request = BeneficiaryRequest(
        villagecode: _villageController.text,
        panchayat: panchayat.value, // Use the value from API
        blockcode: blockCode.value, // Use the value from API
        districtcode: districtCode.value, // Use the value from API
        statecode: stateCode.value, // Use the value from API
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
        idname: _idNameController.text,
        idtype: _idTypeController.text,
        projectid: selectedProject.value,
        partnerid: selectedOfficeId.value,
        beneficeryName: _beneficiaryNameController.text,
      );
      try {
        await submitBeneficery(request: request);
      } on DioException catch (e) {
        print('Dio error submitting form: $e');
        if (e.response != null) {
          print('Status code: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
          if (e.response?.statusCode == 500) {
            Get.snackbar(
              "Server Error",
              'An internal server error occurred. Please try again later.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.orange,
              colorText: AppColors.white,
            );
          } else {
            Get.snackbar(
              "Error",
              'something_went_wrong'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.red,
              colorText: AppColors.white,
            );
          }
        } else {
          Get.snackbar(
            "Network Error",
            'Failed to connect to the server. Please check your internet connection.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.red,
            colorText: AppColors.white,
          );
        }
      } catch (e) {
        print('Other error submitting form: $e');
        Get.snackbar(
          "Error",
          'something_went_wrong'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
      }
    } else {
      // Show validation errors
      Get.snackbar(
        "Error",
        'Please fill all required fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> submitBeneficery({required BeneficiaryRequest request}) async {
    try {
      // isLoading.value = true;
      errorText.value = '';

      var formData = FormData.fromMap({
        "villagecode": request.villagecode.toString(),
        "panchayat": request.panchayat.toString(),
        "blockcode": request.blockcode.toString(),
        "districtcode": request.districtcode.toString(),
        "statecode": request.statecode.toString(),
        "hhname": request.hhname.toString(),
        "hhgender": request.hhgender.toString(),
        "hof": request.hof.toString(),
        "guardian": request.guardian.toString(),
        "sex": request.sex.toString(),
        "age": request.age.toString(),
        "socialgroup": request.socialgroup.toString(),
        "disability": request.disability.toString(),
        "category": request.category.toString(),
        "idname": request.idname.toString(),
        "idtype": request.idtype.toString(),
        "projectid": request.projectid.toString(),
        "partnerid": request.partnerid.toString(),
        "beneficeryName": request.beneficeryName.toString(),
      });

      var response = await apiService.post(
        "/addNewBenificiary.php",
        formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': '*/*',
          },
        ),
      );

      if (response != null) {
        var data = response.data;
        data = jsonDecode(response.data.toString());

        if (data['response_code'] == 200) {
          errorText.value = '';
          // Get.offAllNamed('/moduleSelection');
          Get.snackbar(
            "Success!!",
            'Beneficery Added Successfully!!'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary1,
            colorText: AppColors.white,
          );
        } else if (data['response_code'] == 100) {
          handleErrorReported(error: "something_went_wrong".tr);
          await _sessionManager.logout();
        } else if (data['response_code'] == 300) {
          await _sessionManager.checkSession();
        } else {
          errorText.value = data['message'] ?? "something_went_wrong".tr;
          handleErrorReported(error: errorText.value);
          await _sessionManager.logout();
        }
      } else {
        handleErrorReported(error: "something_went_wrong".tr);
        await _sessionManager.logout();
      }
    } on DioException catch (e) {
      isLoading.value = false;
      print('Dio error in submitBeneficery: $e');
      errorText.value = 'something_went_wrong'.tr;
      handleErrorReported(error: 'something_went_wrong'.tr);
      await _sessionManager.logout();
      throw e; // Re-throw the exception so the _submitForm catch block can also handle it
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleErrorReported({required String error}) async {
    Get.snackbar(
      error,
      'something_went_wrong'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
    );
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
        backgroundColor: AppColors.primary1,
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
            // Container(
            //   padding: EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage(
            //           "lib/assets/images/bjup_logo_zoom.png"), // Your logo as background
            //       fit: BoxFit.fitWidth, // Covers the entire screen
            //       opacity: 0.1,
            //     ),
            //   ),
            // ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Obx(
                () {
                  if (isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary1,
                      ),
                    );
                  } else {
                    return Form(
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
                            items: villageList.map((VillagesList value) {
                              return DropdownMenuItem<String>(
                                value: value.villageId,
                                child: Text(value.villageName),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  _villageController.text = newValue;
                                });
                                // Call API to get village details
                                await getVillageDetails(newValue);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a village';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),

                          // Village details information
                          // Obx(() {
                          //   if (panchayat.value.isNotEmpty) {
                          //     return Card(
                          //       margin: EdgeInsets.only(bottom: 16.0),
                          //       elevation: 2,
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(12.0),
                          //         child: Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             Text(
                          //               'Village Details',
                          //               style: TextStyle(
                          //                 fontWeight: FontWeight.bold,
                          //                 fontSize: 16,
                          //               ),
                          //             ),
                          //             SizedBox(height: 8),
                          //             Text('Panchayat: ${panchayat.value}'),
                          //             Text('Block Code: ${blockCode.value}'),
                          //             Text(
                          //                 'District Code: ${districtCode.value}'),
                          //             Text('State Code: ${stateCode.value}'),
                          //           ],
                          //         ),
                          //       ),
                          //     );
                          //   } else {
                          //     return SizedBox();
                          //   }
                          // }),

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

                          // Rest of the form remains the same...
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
                                return 'Please enter Beneficiary Name';
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Guardian name';
                              }
                              return null;
                            },
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
                          if (submitTriggered.value &&
                              _beneficiaryGender == null)
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
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
                            isExpanded: true,
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

                          // ID Name// ID Name
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
                          SizedBox(height: 24.0),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary1,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Add Beneficiary',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
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
