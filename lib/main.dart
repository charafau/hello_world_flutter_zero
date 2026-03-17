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
  final nav = NavigationWidget("Home");

  final detailPage = ScrollViewWidget(
    child: ColumnWidget(
      children: [
        TextWidget("Detail Page"),
        TextWidget("This is a new page!"),
        ButtonWidget(
          "Go Back",
          onPressed: () {
            print("Dart: Button pressed, popping!");
            nav.pop();
          },
        ),
      ],
    ),
  );

  final homePage = ScrollViewWidget(
    child: ColumnWidget(
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
        SliderWidget(min: 0, max: 100, value: 50),
        RowWidget(
          children: [
            ChipWidget("Dart", width: 80, height: 40),
            ChipWidget("Flutter", width: 90, height: 40),
            ChipWidget("iOS", width: 60, height: 40),
          ],
        ),
        SegmentedControlWidget(["Option 1", "Option 2", "Option 3"]),
        TextFieldWidget("Enter your name"),
        TextEditorWidget("Enter description..."),
        ProgressWidget()..setProgress(0.6),
        ActivityIndicatorWidget(style: "large"),
        ButtonWidget(
          "Go to Details",
          onPressed: () {
            print("Dart: Button pressed, pushing new page!");
            nav.push(detailPage);
          },
        ),
        TextWidget("Hello World 1"),
        TextWidget("Hello World 2"),
        TextWidget("Hello World 3"),
        TextWidget("Hello World 4"),
        TextWidget("Hello World 5"),
        TextWidget("Hello World 6"),
      ],
    ),
  );

  final child = ContainerWidget(child: homePage).padding(10);

  nav.setRoot(child);

  final uiViewHandle = nav.getUIViewHandle();
  final address = uiViewHandle.address;
  print("Native UIView handle (address) ready: ${uiViewHandle.address}");
  print("Calling Swift FFI function with address: $address");
  displayWidgetInViewController(address);
}
