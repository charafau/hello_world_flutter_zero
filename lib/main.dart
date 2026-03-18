import 'dart:ffi';

import 'package:hello_world/bindings.dart';
import 'package:hello_world/native_widgets_ffi.dart';

void main() {
  print('Hello there...');
  addNumbers(2, 3);
  buildSampleLayout();
}

typedef AddNumbersC = Int32 Function(Int32 a, Int32 b);
typedef AddNumbersDart = int Function(int a, int b);
final DynamicLibrary nativeLib = DynamicLibrary.process();

final AddNumbersDart addNumbers = nativeLib
    .lookupFunction<AddNumbersC, AddNumbersDart>('add_numbers');

void buildSampleLayout() {
  final tabBar = TabBarWidget();

  final homeContent = ScrollViewWidget(
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
        TextWidget("Home Tab Content"),
      ],
    ),
  );

  final settingsContent = ScrollViewWidget(
    child: ColumnWidget(
      children: [
        TextWidget("Settings"),
        TextFieldWidget("Search settings..."),
        SwitchWidget(),
        ButtonWidget(
          "Logout",
          onPressed: () {
            print("Logout pressed");
          },
        ),
      ],
    ),
  );

  final profileContent = ScrollViewWidget(
    child: ColumnWidget(
      children: [
        ImageWidget.asset("person.crop.circle.fill"),
        TextWidget("Profile"),
        TextWidget("Member since 2024"),
        ButtonWidget(
          "Edit Profile",
          onPressed: () {
            print("Edit profile pressed");
          },
        ),
      ],
    ),
  );

  final homePage = ContainerWidget(child: homeContent).padding(10);
  final settingsPage = ContainerWidget(child: settingsContent).padding(10);
  final profilePage = ContainerWidget(child: profileContent).padding(10);

  tabBar.addTab("Home", "house", homePage);
  tabBar.addTab("Settings", "gearshape", settingsPage);
  tabBar.addTab("Profile", "person", profilePage);

  final uiViewHandle = tabBar.getUIViewHandle();
  final address = uiViewHandle.address;
  print("Native UIView handle (address) ready: ${uiViewHandle.address}");
  print("Calling Swift FFI function with address: $address");
  displayWidgetInViewController(address);
}
