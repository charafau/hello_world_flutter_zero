import 'dart:ffi';

import 'package:hello_world/bindings.dart';
import 'package:hello_world/native_widgets_ffi.dart';

void main() {
  print('Hello there...');
  addNumbers(2, 3);
  buildSampleLayout();
}

// C function signature (Pointer<Int32> Function(Int32, Int32))
typedef AddNumbersC = Int32 Function(Int32 a, Int32 b);

// Dart function signature (int Function(int, int))
typedef AddNumbersDart = int Function(int a, int b);
final DynamicLibrary nativeLib = DynamicLibrary.process();

// Look up the symbol and cast it
final AddNumbersDart addNumbers = nativeLib
    .lookupFunction<AddNumbersC, AddNumbersDart>('add_numbers');

void buildSampleLayout() {
  NativeWidget? _nativeRoot;

  final column = ColumnWidget(
    children: [
      RowWidget(
        children: [
          ImageWidget.asset("person.crop.circle.fill"),
          ImageWidget.network(
            "https://flutter.dev/assets/shadow-dash.d59d0e8266b087a7a7f8a61c50ad4f6e.png",
          ),
          TextWidget(" John Doe"),
        ],
      ),
      SwitchWidget(),
      SegmentedControlWidget(["Option 1", "Option 2", "Option 3"]),
      TextFieldWidget("Enter your name"),
      TextEditorWidget("Enter description..."),
      ProgressWidget()..setProgress(0.6),
      ActivityIndicatorWidget(style: "large"),
      ButtonWidget(
        "Execute Action",
        onPressed: () {
          print("Dart: Button pressed!");
          nativeLog(
            "Button pressed callback received in Dart and sent back to Native!",
          );
        },
      ),
      TextWidget("Hello World 1"),
      TextWidget("Hello World 2"),
      TextWidget("Hello World 3"),
      TextWidget("Hello World 4"),
      TextWidget("Hello World 5"),
      TextWidget("Hello World 6"),
    ],
  ).expanded();

  final child = ContainerWidget(child: column).padding(10);

  _nativeRoot = SafeAreaWidget(child: child);

  final uiViewHandle = _nativeRoot.getUIViewHandle();
  final address = uiViewHandle.address;
  print("Native UIView handle (address) ready: ${uiViewHandle.address}");
  print("Calling Swift FFI function with address: $address");
  displayWidgetInViewController(address);
}
