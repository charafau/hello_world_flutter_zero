import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'bindings.dart'; // FFI bindings from Section 1

/// Logs a message to the native iOS console.
void nativeLog(String message) {
  final cStr = message.toNativeUtf8();
  widgetLog(cStr);
  calloc.free(cStr);
}

// MARK: - Base Widget Class (Manages the native pointer)

/// Represents a FlexWidget handle created on the native side.
abstract class NativeWidget {
  /// The opaque pointer to the native Swift/UIView object.
  final WidgetRef handle;

  // Finalizer to automatically release the native widget when the Dart object is GC'd
  static final _finalizer = Finalizer<WidgetRef>((ptr) {
    widgetRelease(ptr);
  });

  NativeWidget(this.handle) {
    _finalizer.attach(this, handle, detach: this);
  }

  /// Retrieves the handle to the underlying UIKit UIView.
  Pointer<Void> getUIViewHandle() {
    return getUIViewFromWidget(handle);
  }

  // --- Builder / Modifiers ---

  /// Sets the padding (inner spacing)
  T padding<T extends NativeWidget>(double value) {
    widgetSetPadding(handle, value);
    return this as T;
  }

  /// Sets the margin (outer spacing)
  T margin<T extends NativeWidget>(double value) {
    widgetSetMargin(handle, value);
    return this as T;
  }

  /// Sets the frame size. Pass 0 or null for auto/flex.
  T frame<T extends NativeWidget>({double? width, double? height}) {
    widgetSetSize(handle, width ?? 0, height ?? 0);
    return this as T;
  }

  /// Sets the background color.
  // T background<T extends NativeWidget>(Color color) {
  //   widgetSetBackgroundColor(
  //     handle,
  //     color.red / 255.0,
  //     color.green / 255.0,
  //     color.blue / 255.0,
  //     color.opacity,
  //   );
  //   return this as T;
  // }

  /// Sets the corner radius.
  T cornerRadius<T extends NativeWidget>(double value) {
    widgetSetCornerRadius(handle, value);
    return this as T;
  }

  /// Sets flex grow property (equivalent to Expanded).
  /// [flex] defaults to 1.0.
  T expanded<T extends NativeWidget>({double flex = 1.0}) {
    widgetSetFlexGrow(handle, flex);
    return this as T;
  }
}

// MARK: - Leaf Widgets

class TextWidget extends NativeWidget {
  TextWidget(String text) : super(_create(text));

  static WidgetRef _create(String text) {
    final cStr = text.toNativeUtf8();
    final ptr = createText(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ButtonWidget extends NativeWidget {
  // Keep a reference to the NativeCallable to prevent it from being GC'd
  NativeCallable<Void Function()>? _callback;

  ButtonWidget(String text, {Function? onPressed}) : super(_create(text)) {
    if (onPressed != null) {
      _callback = NativeCallable<Void Function()>.listener(() {
        onPressed();
      });
      widgetSetOnClick(handle, _callback!.nativeFunction);
    }
  }

  static WidgetRef _create(String text) {
    final cStr = text.toNativeUtf8();
    final ptr = createButton(cStr);
    calloc.free(cStr);
    return ptr;
  }

  // Override internal dispose if needed, but NativeCallable.listener usually
  // needs to be explicitly closed if we want to clean up early.
  // However, since it's attached to the object, when the object dies,
  // we might want a finalizer for it too, or just let it live attached.
  // Actually, NativeCallable.listener memory is managed by Dart VM mostly,
  // but we should close it when the widget is destroyed.
  // For simplicity here, we rely on the fact that if the Dart object dies,
  // we don't need the callback anymore.
  // Ideal production: Add a close() method called by Finalizer.
}

class ImageWidget extends NativeWidget {
  ImageWidget.asset(String name) : super(_createAsset(name));
  ImageWidget.network(String url) : super(_createNetwork(url));

  static WidgetRef _createAsset(String name) {
    final cStr = name.toNativeUtf8();
    final ptr = createImage(cStr);
    calloc.free(cStr);
    return ptr;
  }

  static WidgetRef _createNetwork(String url) {
    final cStr = url.toNativeUtf8();
    final ptr = createImageFromUrl(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class SwitchWidget extends NativeWidget {
  SwitchWidget() : super(createSwitch());
}

class TextFieldWidget extends NativeWidget {
  TextFieldWidget(String placeholder) : super(_create(placeholder));

  static WidgetRef _create(String placeholder) {
    final cStr = placeholder.toNativeUtf8();
    final ptr = createTextField(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class TextEditorWidget extends NativeWidget {
  TextEditorWidget(String text) : super(_create(text));

  static WidgetRef _create(String text) {
    final cStr = text.toNativeUtf8();
    final ptr = createTextEditor(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ActivityIndicatorWidget extends NativeWidget {
  ActivityIndicatorWidget({String style = 'medium'}) : super(_create(style));

  static WidgetRef _create(String style) {
    final cStr = style.toNativeUtf8();
    final ptr = createActivityIndicator(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ProgressWidget extends NativeWidget {
  ProgressWidget() : super(createProgressView());

  void setProgress(double value) {
    progressSetProgress(handle, value);
  }
}

class SegmentedControlWidget extends NativeWidget {
  SegmentedControlWidget(List<String> segments) : super(_create(segments));

  static WidgetRef _create(List<String> segments) {
    final cStr = segments.join('|').toNativeUtf8();
    final ptr = createSegmentedControl(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class SliderWidget extends NativeWidget {
  SliderWidget({double min = 0, double max = 1, double value = 0.5})
    : super(_create(min, max, value));

  static WidgetRef _create(double min, double max, double value) {
    return createSlider(min, max, value);
  }
}

class ChipWidget extends NativeWidget {
  ChipWidget(String text, {double? width, double? height})
    : super(_create(text, width, height));

  static WidgetRef _create(String text, double? width, double? height) {
    final cStr = text.toNativeUtf8();
    final ptr = createChip(cStr);
    calloc.free(cStr);
    if (width != null || height != null) {
      widgetSetSize(ptr, width ?? 0, height ?? 0);
    }
    return ptr;
  }
}

class ScrollViewWidget extends ContainerWidget {
  ScrollViewWidget({required NativeWidget child})
    : super._fromHandle(createScrollView(), child: child);
}

class NavigationWidget extends NativeWidget {
  final List<NativeWidget> _pages = [];
  NativeCallable<Void Function()>? _leftCallback;
  NativeCallable<Void Function()>? _rightCallback;

  NavigationWidget(String title) : super(_create(title));

  static WidgetRef _create(String title) {
    final cStr = title.toNativeUtf8();
    final ptr = createNavigation(cStr);
    calloc.free(cStr);
    return ptr;
  }

  void setRoot(NativeWidget page) {
    navigationSetRoot(handle, page.handle);
  }

  void push(NativeWidget page) {
    _pages.add(page);
    navigationPush(handle, page.handle);
  }

  void pushWithTitle(
    NativeWidget page, {
    required String title,
    double? r,
    double? g,
    double? b,
  }) {
    _pages.add(page);
    final titleStr = title.toNativeUtf8();
    navigationPushWithTitle(
      handle,
      page.handle,
      titleStr,
      r ?? 0,
      g ?? 0,
      b ?? 0,
    );
    calloc.free(titleStr);
  }

  void pop() {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    navigationPop(handle);
  }

  void setTitle(String title, {double? r, double? g, double? b}) {
    final cStr = title.toNativeUtf8();
    navigationSetTitle(handle, cStr, r ?? 0, g ?? 0, b ?? 0);
    calloc.free(cStr);
  }

  void addLeftBarButton(String title, {String? icon, Function? onPressed}) {
    final titleStr = title.toNativeUtf8();
    final iconStr = (icon ?? '').toNativeUtf8();
    if (onPressed != null) {
      _leftCallback = NativeCallable<Void Function()>.listener(() {
        onPressed();
      });
      navigationAddLeftBarButton(
        handle,
        titleStr,
        iconStr,
        _leftCallback!.nativeFunction,
      );
    }
    calloc.free(titleStr);
    calloc.free(iconStr);
  }

  void addRightBarButton(String title, {String? icon, Function? onPressed}) {
    final titleStr = title.toNativeUtf8();
    final iconStr = (icon ?? '').toNativeUtf8();
    if (onPressed != null) {
      _rightCallback = NativeCallable<Void Function()>.listener(() {
        onPressed();
      });
      navigationAddRightBarButton(
        handle,
        titleStr,
        iconStr,
        _rightCallback!.nativeFunction,
      );
    }
    calloc.free(titleStr);
    calloc.free(iconStr);
  }

  void setBackgroundColor(double r, double g, double b) {
    navigationSetBackgroundColor(handle, r, g, b);
  }
}

class TabBarWidget extends NativeWidget {
  TabBarWidget() : super(_create());

  static WidgetRef _create() {
    return createTabBar();
  }

  void addTab(String title, String icon, NativeWidget page) {
    final titleStr = title.toNativeUtf8();
    final iconStr = icon.toNativeUtf8();
    tabBarAddTab(handle, titleStr, iconStr, page.handle);
    calloc.free(titleStr);
    calloc.free(iconStr);
  }

  void setSelectedIndex(int index) {
    tabBarSetSelectedIndex(handle, index);
  }

  void setBackgroundColor(double r, double g, double b, {double a = 1.0}) {
    tabBarSetBackgroundColor(handle, r, g, b, a);
  }

  void setTintColor(double r, double g, double b) {
    tabBarSetTintColor(handle, r, g, b);
  }

  void setUnselectedItemColor(double r, double g, double b) {
    tabBarSetUnselectedItemColor(handle, r, g, b);
  }

  void setBadge(int index, String? badge) {
    if (badge == null) {
      final empty = ''.toNativeUtf8();
      tabBarSetBadge(handle, index, empty);
      calloc.free(empty);
    } else {
      final badgeStr = badge.toNativeUtf8();
      tabBarSetBadge(handle, index, badgeStr);
      calloc.free(badgeStr);
    }
  }

  void hideTabBar(bool hidden) {
    tabBarHide(handle, hidden);
  }

  NativeCallable<Void Function()>? _tabCallback;

  void setOnTabSelected(Function? onTabSelected) {
    if (onTabSelected != null) {
      _tabCallback = NativeCallable<Void Function()>.listener(() {
        onTabSelected();
      });
      tabBarSetOnTabSelected(handle, _tabCallback!.nativeFunction);
    }
  }

  int getSelectedIndex() {
    return tabBarGetSelectedIndex(handle);
  }
}

class ModalWidget extends NativeWidget {
  NativeCallable<Void Function()>? _dismissCallback;

  ModalWidget(String title) : super(_create(title));

  static WidgetRef _create(String title) {
    final cStr = title.toNativeUtf8();
    final ptr = createModal(cStr);
    calloc.free(cStr);
    return ptr;
  }

  void setContent(NativeWidget page) {
    modalSetContent(handle, page.handle);
  }

  void addDismissButton(String title, {Function? onPressed}) {
    final titleStr = title.toNativeUtf8();
    if (onPressed != null) {
      _dismissCallback = NativeCallable<Void Function()>.listener(() {
        onPressed();
      });
      modalAddDismissButton(handle, titleStr, _dismissCallback!.nativeFunction);
    }
    calloc.free(titleStr);
  }

  void present(NativeWidget from) {
    modalPresent(handle, from.handle);
  }

  void dismiss() {
    modalDismiss(handle);
  }
}

// MARK: - Container Widgets

class ContainerWidget extends NativeWidget {
  // Hold a strong reference to child to prevent GC
  final NativeWidget? _child;

  // Now simpler: acts mainly as a wrapper.
  ContainerWidget({NativeWidget? child, bool isCard = false})
    : _child = child,
      super(isCard ? createCard() : createContainer()) {
    if (child != null) {
      containerSetChild(handle, child.handle);
    }
  }

  // Protected constructor for subclasses
  ContainerWidget._fromHandle(Pointer<Void> handle, {NativeWidget? child})
    : _child = child,
      super(handle) {
    if (child != null) {
      containerSetChild(handle, child.handle);
    }
  }

  // Factory for Card
  factory ContainerWidget.card({required NativeWidget child}) {
    return ContainerWidget(isCard: true, child: child).padding(16);
    // .background(Colors.white);
  }
}

class SafeAreaWidget extends ContainerWidget {
  SafeAreaWidget({required NativeWidget child})
    : super._fromHandle(createSafeArea(), child: child);
}

// MARK: - Linear Widgets (Column/Row)

class ColumnWidget extends NativeWidget {
  // Hold strong references to children
  final List<NativeWidget> _children;

  ColumnWidget({List<NativeWidget> children = const []})
    : _children = children,
      super(createColumn()) {
    _addChildren(children);
  }

  void _addChildren(List<NativeWidget> children) {
    if (children.isEmpty) return;

    final pointerList = calloc<WidgetRef>(children.length);
    try {
      for (var i = 0; i < children.length; i++) {
        pointerList[i] = children[i].handle;
      }
      linearAddChildren(handle, pointerList, children.length);
    } finally {
      calloc.free(pointerList);
    }
  }
}

class RowWidget extends NativeWidget {
  // Hold strong references to children
  final List<NativeWidget> _children;

  RowWidget({List<NativeWidget> children = const []})
    : _children = children,
      super(createRow()) {
    _addChildren(children);
  }

  void _addChildren(List<NativeWidget> children) {
    if (children.isEmpty) return;

    final pointerList = calloc<WidgetRef>(children.length);
    try {
      for (var i = 0; i < children.length; i++) {
        pointerList[i] = children[i].handle;
      }
      linearAddChildren(handle, pointerList, children.length);
    } finally {
      calloc.free(pointerList);
    }
  }
}

// MARK: - List View Widget

class ListViewWidget extends NativeWidget {
  static final Map<int, Map<int, NativeWidget>> _allItems = {};
  static final Map<int, int> _allCounts = {};
  final int _widgetId;
  Map<int, NativeWidget> _items = {};

  ListViewWidget.builder({
    required int itemCount,
    required NativeWidget Function(int index) itemBuilder,
  }) : _widgetId = _allItems.length,
       super(createListView()) {
    // Build all items synchronously upfront
    for (int i = 0; i < itemCount; i++) {
      _items[i] = itemBuilder(i);
    }
    _allItems[_widgetId] = _items;
    _allCounts[_widgetId] = itemCount;

    // Initialize list view with count
    listViewSetCount(handle, itemCount);

    // Immediately update all items
    for (int i = 0; i < itemCount; i++) {
      listViewUpdateItem(handle, i, _items[i]!.handle);
    }
  }

  void setItemHeight(double height) {
    listViewSetItemHeight(handle, height);
  }
}

// MARK: - FlashList Widget (Dart handles windowing/recycling, Swift is just a scroll container)

class FlashListWidget extends NativeWidget {
  static final Map<int, List<NativeWidget>> _allItems = {};
  static final Map<int, int> _allCounts = {};
  final int _widgetId;
  Map<int, NativeWidget> _items = {};

  FlashListWidget.builder({
    required int itemCount,
    required NativeWidget Function(int index) itemBuilder,
  }) : _widgetId = _allItems.length,
       super(createFlashList()) {
    _items = {};
    _allItems[_widgetId] = [];
    _allCounts[_widgetId] = itemCount;

    // Build all items
    for (int i = 0; i < itemCount; i++) {
      _items[i] = itemBuilder(i);
    }

    flashListSetItemCount(handle, itemCount);

    // Update all items
    for (int i = 0; i < itemCount; i++) {
      if (_items[i] != null) {
        flashListUpdateItem(handle, i, _items[i]!.handle);
      }
    }
  }

  void setItemHeight(double height) {
    flashListSetItemHeight(handle, height);
  }

  void setContentHeight(double height) {
    flashListSetContentHeight(handle, height);
  }

  void removeItem(int index) {
    flashListRemoveItem(handle, index);
  }

  void clear() {
    flashListClear(handle);
  }

  double getScrollOffset() {
    return flashListGetScrollOffset(handle);
  }
}
