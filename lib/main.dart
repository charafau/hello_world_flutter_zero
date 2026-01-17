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
  NativeWidget? _nativeRootColumn;

  final column = ColumnWidget(
    children: [
      RowWidget(
        children: [
          ImageWidget("person.crop.circle.fill"),
          TextWidget(" John Doe"),
        ],
      ),
      SwitchWidget(),
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
  // .background(const Color(0xFFF2F2F2)); // Light Gray

  _nativeRoot = SafeAreaWidget(child: child);
  // _nativeRoot = ContainerWidget(child: TextWidget("Hello World")).padding(10);

  final uiViewHandle = _nativeRoot.getUIViewHandle();
  final address = uiViewHandle.address;
  print("Native UIView handle (address) ready: ${uiViewHandle.address}");
  print("Calling Swift FFI function with address: $address");
  // In a real app, you would now use a MethodChannel to send uiViewHandle.address
  // to Swift/Objective-C to display the UIView via a UIViewController or Platform View.
  displayWidgetInViewController(address);
}
