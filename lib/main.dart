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

  homeNav.setBackgroundColor(0.0, 0.5, 1.0);

  homeNav.addLeftBarButton(
    "Menu",
    icon: "line.3.horizontal",
    onPressed: () {
      print("Menu pressed!");
    },
  );

  homeNav.addRightBarButton(
    "Search",
    icon: "magnifyingglass",
    onPressed: () {
      print("Search pressed!");
    },
  );

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
            homeNav.pushWithTitle(
              homeDetailPage,
              title: "Details",
              r: 1.0,
              g: 0.0,
              b: 0.0,
            );
          },
        ),
        ButtonWidget(
          "Show Modal",
          onPressed: () {
            print("Dart: Showing modal!");
            final modal = ModalWidget("Modal Title");
            final modalContent = ScrollViewWidget(
              child: ColumnWidget(
                children: [
                  TextWidget("This is a modal!"),
                  TextWidget(
                    "You can present forms, settings, or any content here.",
                  ),
                  ButtonWidget(
                    "Close",
                    onPressed: () {
                      print("Dart: Dismissing modal!");
                      modal.dismiss();
                    },
                  ),
                ],
              ),
            );
            modal.setContent(modalContent);
            modal.addDismissButton(
              "Done",
              onPressed: () {
                print("Dart: Done button pressed!");
                modal.dismiss();
              },
            );
            modal.present(homeNav);
          },
        ),
      ],
    ),
  );

  final settingsNav = NavigationWidget("Settings");

  settingsNav.addRightBarButton(
    "Add",
    icon: "plus",
    onPressed: () {
      print("Add settings pressed!");
    },
  );

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
            settingsNav.pushWithTitle(
              settingsDetailPage,
              title: "Account",
              r: 0.0,
              g: 0.7,
              b: 0.0,
            );
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
            profileNav.pushWithTitle(
              profileDetailPage,
              title: "Edit",
              r: 0.6,
              g: 0.3,
              b: 0.6,
            );
          },
        ),
      ],
    ),
  );

  homeNav.setRoot(homeContent);
  settingsNav.setRoot(settingsContent);
  profileNav.setRoot(profileContent);

  final listNav = NavigationWidget("List");

  final listViewPage = ListViewWidget.builder(
    itemCount: 30,
    itemBuilder: (index) {
      return ContainerWidget(
        child: RowWidget(
          children: [ImageWidget.asset("doc.text"), TextWidget("Item $index")],
        ),
      ).padding(10);
    },
  )..setItemHeight(80);

  final listContent = listViewPage;

  listNav.setRoot(listContent);

  tabBar.addTab("Home", "house", homeNav);
  tabBar.addTab("Settings", "gearshape", settingsNav);
  tabBar.addTab("List", "list.bullet", listNav);
  tabBar.addTab("Profile", "person", profileNav);

  tabBar.setBackgroundColor(0.95, 0.95, 0.97);
  tabBar.setTintColor(0.0, 0.5, 1.0);
  tabBar.setUnselectedItemColor(0.5, 0.5, 0.5);
  tabBar.setBadge(0, "3");
  tabBar.setBadge(2, "!");

  tabBar.setOnTabSelected(() {
    final index = tabBar.getSelectedIndex();
    print("Tab switched to index: $index");
    if (index == 0) {
      print("Home tab selected");
    } else if (index == 1) {
      print("Settings tab selected");
    } else if (index == 2) {
      print("List tab selected");
    } else if (index == 3) {
      print("Profile tab selected");
    }
  });

  final uiViewHandle = tabBar.getUIViewHandle();
  final address = uiViewHandle.address;
  print("Native UIView handle (address) ready: ${uiViewHandle.address}");
  print("Calling Swift FFI function with address: $address");
  displayWidgetInViewController(address);
}
