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

  final homeNav = NavigationWidget("Home");

  final homeDetailPage = ScrollViewWidget(
    child: ColumnWidget(
      children: [
        TextWidget("Home Detail"),
        TextWidget("This is a detail page within Home tab!"),
        ButtonWidget(
          "Go Back",
          onPressed: () {
            print("Dart: Popping from Home detail!");
            homeNav.pop();
          },
        ),
      ],
    ),
  );

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
        ButtonWidget(
          "View Details",
          onPressed: () {
            print("Dart: Pushing Home detail!");
            homeNav.push(homeDetailPage);
          },
        ),
      ],
    ),
  );

  final settingsNav = NavigationWidget("Settings");

  final settingsDetailPage = ScrollViewWidget(
    child: ColumnWidget(
      children: [
        TextWidget("Account Settings"),
        SwitchWidget(),
        TextWidget("Enable notifications"),
        ButtonWidget(
          "Go Back",
          onPressed: () {
            print("Dart: Popping from Settings detail!");
            settingsNav.pop();
          },
        ),
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
          "Account Settings",
          onPressed: () {
            print("Dart: Pushing Settings detail!");
            settingsNav.push(settingsDetailPage);
          },
        ),
        ButtonWidget(
          "Logout",
          onPressed: () {
            print("Logout pressed");
          },
        ),
      ],
    ),
  );

  final profileNav = NavigationWidget("Profile");

  final profileDetailPage = ScrollViewWidget(
    child: ColumnWidget(
      children: [
        TextWidget("Edit Profile"),
        TextFieldWidget("Name"),
        TextFieldWidget("Email"),
        ButtonWidget(
          "Save",
          onPressed: () {
            print("Dart: Popping from Profile detail!");
            profileNav.pop();
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
            print("Dart: Pushing Profile detail!");
            profileNav.push(profileDetailPage);
          },
        ),
      ],
    ),
  );

  homeNav.setRoot(homeContent);
  settingsNav.setRoot(settingsContent);
  profileNav.setRoot(profileContent);

  tabBar.addTab("Home", "house", homeNav);
  tabBar.addTab("Settings", "gearshape", settingsNav);
  tabBar.addTab("Profile", "person", profileNav);

  final uiViewHandle = tabBar.getUIViewHandle();
  final address = uiViewHandle.address;
  print("Native UIView handle (address) ready: ${uiViewHandle.address}");
  print("Calling Swift FFI function with address: $address");
  displayWidgetInViewController(address);
}
