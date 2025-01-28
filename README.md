# **FormBuilder**

A Flutter web project that dynamically generates forms based on a JSON input structure.

## **Getting Started**

This project is a starting point for a Flutter web application that allows users to create forms dynamically. The app supports multiple field types such as dropdowns and text fields, and it dynamically handles field visibility based on the provided JSON conditions.

### **Resources to Get You Started**

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

---

## **How to Use the App**

### **Editing the Form Structure (JSON Editor)**:
1. In the **JSON Editor** section, modify the form's JSON structure.
2. Changes in the JSON will update the form dynamically.
3. The form will adapt based on visibility conditions (`visible` attribute), updating the fields shown as you modify values.

### **Editing User Data (User Data Editor)**:
1. The **User Data Editor** section allows you to modify the values for each field in the form.
2. Changes made here will be reflected immediately in the form, based on the field's visibility and validity.

### **Applying Changes**:
1. After editing user data, click **Apply** to confirm changes.
2. The app will validate the entered JSON and user data, applying the updates if everything is valid.

### **Form Rendering**:
- The **Form Renderer** will display the form based on the current JSON structure and user data.
- It supports real-time updates, showing only the fields that match the visibility conditions.

---

## **JSON Input Structure**

The JSON input defines the form structure, including field names, field types (e.g., dropdown, textfield), and visibility conditions. Below is an example of a JSON input:

```json
[
  { "field_name": "f1", "widget": "dropdown", "valid_values": ["A", "B"] },
  { "field_name": "f2", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f3", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f4", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f5", "widget": "textfield", "visible": "f1=='B'" },
  { "field_name": "f6", "widget": "textfield", "visible": "f1=='B'" }
]
Test Scenario 2:
[
  { "field_name": "f1", "widget": "dropdown", "valid_values": ["A", "B"] },
  { "field_name": "f2", "widget": "textfield", "visible": "f1=='A'" },
  { "field_name": "f3", "widget": "textfield", "visible": "f1=='B'" }
]
Test Scenario 3: Invalid JSON Format
[
  { "field_name": "f1", "widget": "dropdown", "valid_values": ["A", "B"] }
  { "field_name": "f2", "widget": "textfield" }
]

