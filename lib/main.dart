import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/json.dart' as highlight_json;


void main() {
  runApp(ProviderScope(child: MyApp()));
}

final jsonEditorProvider = StateProvider<String>((ref) => const JsonEncoder.withIndent('  ').convert([
  { "field_name": "f1", "widget": "dropdown", "valid_values": ["A", "B"] },
  { "field_name": "f2", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f3", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f4", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f5", "widget": "textfield", "visible": "f1=='B'" },
  { "field_name": "f6", "widget": "textfield", "visible": "f1=='B'" }
]));
final userDataProvider = StateNotifierProvider<UserDataNotifier, Map<String, dynamic>>((ref) => UserDataNotifier());
class UserDataNotifier extends StateNotifier<Map<String, dynamic>> {
  UserDataNotifier() : super({});

  void updateField(String key, dynamic value, List<dynamic> fields) {
    state = {
      ...state,
      key: value,
    };

    resetUserData(fields);
  }

  void resetUserData(List<dynamic> fields) {
    final newState = <String, dynamic>{};

    for (var field in fields) {
      if (field.containsKey('visible')) {
        if (evaluateVisibility(field['visible'], state)) {
          newState[field['field_name']] = state[field['field_name']] ?? "";
        }
      } else {
        newState[field['field_name']] = state[field['field_name']] ?? "";
      }
    }

    state = newState;
  }

  bool evaluateVisibility(String condition, Map<String, dynamic> userData) {
    try {
      final keyValuePair = condition.split("==");
      final key = keyValuePair[0].trim();
      final value = keyValuePair[1].trim().replaceAll("'", "").replaceAll("\"", "");
      return userData[key] == value;
    } catch (e) {
      return true;
    }
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Dynamic Form Builder')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: JsonEditor()),
              SizedBox(width: 16),
              Expanded(child: UserDataEditor()),
              SizedBox(width: 16),
              Expanded(child: FormRenderer()),
            ],
          ),
        ),
      ),
    );
  }
}
class JsonEditor extends ConsumerStatefulWidget {
  const JsonEditor({super.key});

  @override
  JsonEditorState createState() => JsonEditorState();
}

class JsonEditorState extends ConsumerState<JsonEditor> {
  late CodeController _codeController;
  String? _error;
  @override
  void initState() {
    super.initState();
    final initialJson = ref.read(jsonEditorProvider);
    _codeController = CodeController(
      text: initialJson,
      language: highlight_json.json,
    );

    _codeController.addListener(() {
      _validateJson(_codeController.text,ref);
    });
  }

  void _validateJson(String text, WidgetRef ref) {
    try {
      final parsedJson = jsonDecode(text);

      if (ref.read(jsonEditorProvider) != text.trim()) {
        ref.read(jsonEditorProvider.notifier).state = text.trim();
        ref.read(userDataProvider.notifier).resetUserData(parsedJson);
      }

      ref.read(jsonErrorProvider.notifier).state = null;

    } catch (e) {
      ref.read(jsonErrorProvider.notifier).state = "❌ Invalid JSON format";
    }
  }

  void resetUserDataBasedOnJson(List<dynamic> fields) {
    Map<String, dynamic> newState = {};

    for (var field in fields) {
      if (field.containsKey("field_name")) {
        String fieldName = field["field_name"];
        newState[fieldName] = null;
      }
    }

    ref.read(userDataProvider.notifier).state = newState;
  }







  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "🔧 JSON Editor",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis, // prevents overflow
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  tooltip: "Copy JSON",
                  onPressed: () => Clipboard.setData(
                    ClipboardData(text: _codeController.text),
                  ),
                ),
              ],
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text("🔧 JSON Editor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            //     Row(
            //       children: [
            //
            //         IconButton(
            //           icon: Icon(Icons.content_copy),
            //           tooltip: "Copy JSON",
            //           onPressed: () => Clipboard.setData(ClipboardData(text: _codeController.text)),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            Divider(),
            Expanded(
              child: ListView(
                shrinkWrap: true, // ✅ Prevent overflow
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ White background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(8),
                    child: CodeTheme(
                      data: CodeThemeData(styles: {
                        "string": TextStyle(color: Colors.green),
                        "keyword": TextStyle(color: Colors.blue),
                        "number": TextStyle(color: Colors.orange),
                        "punctuation": TextStyle(color: Colors.black),
                      }),
                      child: CodeField(
                        controller: _codeController,
                        textStyle: TextStyle(fontFamily: 'monospace', fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: TextStyle(color: Colors.red, fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }
}
class UserDataEditor extends ConsumerStatefulWidget {
  const UserDataEditor({super.key});

  @override
  UserDataEditorState createState() => UserDataEditorState();
}
class UserDataEditorState extends ConsumerState<UserDataEditor> {
  String? errorMessage;
  late TextEditingController userDataController;
  bool isUserEditing = false;
  bool isValidJson = true;
  bool isApplyingChanges = false;
  String lastAppliedJson = "{}";

  @override
  void initState() {
    super.initState();

    final initialData = jsonEncode(ref.read(userDataProvider));
    userDataController = TextEditingController(text: initialData);
    lastAppliedJson = initialData;

    userDataController.addListener(() {
      if (!isApplyingChanges) {
        setState(() => isUserEditing = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final userDataJson = jsonEncode(userData);


    if (!isUserEditing && userDataController.text != userDataJson) {
      isApplyingChanges = true;
      userDataController.text = userDataJson;
      lastAppliedJson = userDataJson;
      isApplyingChanges = false;
    }

    final jsonError = ref.watch(jsonErrorProvider);

    if (jsonError != null) {
      return Center(
        child: Card(
          color: Colors.red[100],
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              jsonError,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📝 User Data:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            TextField(
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'User Data Editor',
                errorText: errorMessage,
              ),
              controller: userDataController,
              style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              onChanged: (value) {
                setState(() {
                  errorMessage = null;
                  isValidJson = true;
                });

                try {
                  jsonDecode(value);
                } catch (e) {
                  setState(() {
                    isValidJson = false;
                    errorMessage = "⚠ Invalid JSON format!";
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isValidJson ? () {
                      try {
                        final validJson = jsonDecode(userDataController.text);
                        ref.read(userDataProvider.notifier).state = validJson;

                        setState(() {
                          isUserEditing = false;
                          lastAppliedJson = jsonEncode(validJson);
                        });
                      } catch (e) {
                        setState(() {
                          isValidJson = false;
                          errorMessage = "⚠ Invalid JSON format!";
                        });
                      }
                    } : null,

                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: isValidJson ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      "Apply",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0,),



                  SizedBox(width: 12),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final jsonErrorProvider = StateProvider<String?>((ref) => null);



class FormRenderer extends ConsumerWidget {
  const FormRenderer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jsonText = ref.watch(jsonEditorProvider);
    final userData = ref.watch(userDataProvider);
    final jsonError = ref.watch(jsonErrorProvider);

    List<dynamic> fields;
    if (jsonError != null) {
      return _buildErrorCard(jsonError);
    }

    try {
      fields = jsonDecode(jsonText);
    } catch (e) {
      return _buildErrorCard('❌ Invalid JSON format');
    }

    return _buildFormCard(fields, ref, userData, context);
  }

  Widget _buildErrorCard(String errorMessage) {
    return Center(
      child: Card(
        color: Colors.red[100],
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(List<dynamic> fields, WidgetRef ref, Map<String, dynamic> userData, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📄 Generated Form:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Divider(),
            Expanded(
              child: ListView(
                children: fields.map((field) {
                  if (!_evaluateVisibility(field['visible'], userData)) {
                    return SizedBox.shrink();
                  }
                  return _buildField(field, ref, userData, fields, context);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _evaluateVisibility(String? condition, Map<String, dynamic> userData) {
    if (condition == null) return true;
    try {
      final keyValuePair = condition.split("==");
      final key = keyValuePair[0].trim();
      final value = keyValuePair[1].trim().replaceAll("'", "").replaceAll("\"", "");
      return userData[key] == value;
    } catch (e) {
      return true;
    }
  }

  Widget _buildField(Map<String, dynamic> field, WidgetRef ref, Map<String, dynamic> userData, List<dynamic> fields, BuildContext context) {
    switch (field['widget']) {
      case 'textfield':
        return _buildTextField(field, ref, userData, fields);
      case 'dropdown':
        return _buildDropdown(field, ref, userData, fields, context);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildTextField(Map<String, dynamic> field, WidgetRef ref, Map<String, dynamic> userData, List<dynamic> fields) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        showCursor: false,
        decoration: InputDecoration(
          labelText: field['field_name'],
          border: OutlineInputBorder(),
        ),
        controller: TextEditingController(text: userData[field['field_name']] ?? ""),
        onChanged: (value) {
          ref.read(userDataProvider.notifier).updateField(field['field_name'], value, fields);
        },
      ),
    );
  }

  Widget _buildDropdown(Map<String, dynamic> field, WidgetRef ref, Map<String, dynamic> userData, List<dynamic> fields, BuildContext context) {
    final List<String> validValues = List<String>.from(field['valid_values'] ?? []);
    String dropdownValue = userData[field['field_name']] ?? validValues.first;

    if (!validValues.contains(dropdownValue)) {
      dropdownValue = validValues.first;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: field['field_name'],
          border: OutlineInputBorder(),
        ),
        items: validValues.map<DropdownMenuItem<String>>((option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        value: dropdownValue,
        onChanged: validValues.isNotEmpty
            ? (value) {
          ref.read(userDataProvider.notifier).updateField(field['field_name'], value, fields);
          ref.read(userDataProvider.notifier).resetUserData(fields);
          FocusNode focusNode = FocusNode();
          FocusScope.of(context).requestFocus(focusNode);
        }
            : null,
      ),
    );
  }
}








