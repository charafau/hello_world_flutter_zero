import 'dart:ffi';
import 'package:ffi/ffi.dart';

// On iOS, symbols from the app executable (Runner) are available via 'process()'.
final DynamicLibrary nativeLib = DynamicLibrary.process();

// --- Type Definitions ---
typedef WidgetRef = Pointer<Void>; // Common Widget Handle

// C Function Signatures (for lookup)
typedef CreateTextC = WidgetRef Function(Pointer<Utf8> text);
typedef CreateButtonC = WidgetRef Function(Pointer<Utf8> text);
typedef CreateImageC = WidgetRef Function(Pointer<Utf8> name);
typedef CreateImageFromUrlC = WidgetRef Function(Pointer<Utf8> url);
typedef CreateTextFieldC = WidgetRef Function(Pointer<Utf8> placeholder);
typedef CreateTextEditorC = WidgetRef Function(Pointer<Utf8> text);
typedef CreateActivityIndicatorC = WidgetRef Function(Pointer<Utf8> style);
typedef CreateProgressViewC = WidgetRef Function();
typedef ProgressSetProgressC = Void Function(WidgetRef widget, Float value);
typedef CreateSegmentedControlC = WidgetRef Function(Pointer<Utf8> segments);
typedef CreateSliderC = WidgetRef Function(Float min, Float max, Float value);
typedef CreateChipC = WidgetRef Function(Pointer<Utf8> text);
typedef CreateVoidC = WidgetRef Function();
typedef WidgetReleaseC = Void Function(WidgetRef widget);
typedef WidgetSetPaddingC = Void Function(WidgetRef widget, Float value);
typedef WidgetSetMarginC = Void Function(WidgetRef widget, Float value);
typedef WidgetSetSizeC = Void Function(WidgetRef widget, Float w, Float h);
typedef WidgetSetBgColorC =
    Void Function(WidgetRef widget, Float r, Float g, Float b, Float a);
typedef WidgetSetCornerRadiusC = Void Function(WidgetRef widget, Float radius);
typedef WidgetSetFlexGrowC = Void Function(WidgetRef widget, Float value);
typedef WidgetSetOnClickC =
    Void Function(
      WidgetRef widget,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef WidgetLogC = Void Function(Pointer<Utf8> message);
typedef CreateListViewC = WidgetRef Function();
typedef CreateScrollViewC = WidgetRef Function();
typedef CreateNavigationC = WidgetRef Function(Pointer<Utf8> title);
typedef NavigationPushC = Void Function(WidgetRef nav, WidgetRef widget);
typedef NavigationPushWithTitleC =
    Void Function(
      WidgetRef nav,
      WidgetRef widget,
      Pointer<Utf8> title,
      Float colorR,
      Float colorG,
      Float colorB,
    );
typedef NavigationPopC = Void Function(WidgetRef nav);
typedef NavigationSetRootC = Void Function(WidgetRef nav, WidgetRef widget);
typedef NavigationSetTitleC =
    Void Function(
      WidgetRef nav,
      Pointer<Utf8> title,
      Float r,
      Float g,
      Float b,
    );
typedef NavigationAddLeftBarButtonC =
    Void Function(
      WidgetRef nav,
      Pointer<Utf8> title,
      Pointer<Utf8> icon,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef NavigationAddRightBarButtonC =
    Void Function(
      WidgetRef nav,
      Pointer<Utf8> title,
      Pointer<Utf8> icon,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef NavigationSetBackgroundColorC =
    Void Function(WidgetRef nav, Float r, Float g, Float b);
typedef ListViewBuilderCallbackC = Void Function(WidgetRef list, Int64 index);
typedef ListViewUpdateItemC =
    Void Function(WidgetRef list, Int64 index, WidgetRef item);
typedef ListViewSetBuilderC =
    Void Function(
      WidgetRef list,
      Int64 count,
      Pointer<NativeFunction<ListViewBuilderCallbackC>> callback,
    );
typedef ListViewSetItemHeightC = Void Function(WidgetRef list, Float height);
typedef ListViewSetCountC = Void Function(WidgetRef list, Int64 count);
typedef ContainerSetChildC = Void Function(WidgetRef parent, WidgetRef child);
typedef LinearAddChildrenC =
    Void Function(WidgetRef parent, Pointer<WidgetRef> children, Int64 count);
typedef WidgetLayoutRootC =
    Void Function(WidgetRef root, Float width, Float height);
typedef GetUIViewFromWidgetC = Pointer<Void> Function(WidgetRef root);

// Dart Function Signatures (for execution)
typedef CreateTextDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateButtonDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateImageDart = WidgetRef Function(Pointer<Utf8> name);
typedef CreateImageFromUrlDart = WidgetRef Function(Pointer<Utf8> url);
typedef CreateTextFieldDart = WidgetRef Function(Pointer<Utf8> placeholder);
typedef CreateTextEditorDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateActivityIndicatorDart = WidgetRef Function(Pointer<Utf8> style);
typedef CreateProgressViewDart = WidgetRef Function();
typedef ProgressSetProgressDart = void Function(WidgetRef widget, double value);
typedef CreateSegmentedControlDart = WidgetRef Function(Pointer<Utf8> segments);
typedef CreateSliderDart =
    WidgetRef Function(double min, double max, double value);
typedef CreateChipDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateVoidDart = WidgetRef Function();
typedef WidgetReleaseDart = void Function(WidgetRef widget);
typedef WidgetSetPaddingDart = void Function(WidgetRef widget, double value);
typedef WidgetSetMarginDart = void Function(WidgetRef widget, double value);
typedef WidgetSetSizeDart = void Function(WidgetRef widget, double w, double h);
typedef WidgetSetBgColorDart =
    void Function(WidgetRef widget, double r, double g, double b, double a);
typedef WidgetSetCornerRadiusDart =
    void Function(WidgetRef widget, double radius);
typedef WidgetSetFlexGrowDart = void Function(WidgetRef widget, double value);
typedef WidgetSetOnClickDart =
    void Function(
      WidgetRef widget,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef WidgetLogDart = void Function(Pointer<Utf8> message);
typedef CreateListViewDart = WidgetRef Function();
typedef CreateScrollViewDart = WidgetRef Function();
typedef CreateNavigationDart = WidgetRef Function(Pointer<Utf8> title);
typedef NavigationPushDart = void Function(WidgetRef nav, WidgetRef widget);
typedef NavigationPushWithTitleDart =
    void Function(
      WidgetRef nav,
      WidgetRef widget,
      Pointer<Utf8> title,
      double colorR,
      double colorG,
      double colorB,
    );
typedef NavigationPopDart = void Function(WidgetRef nav);
typedef NavigationSetRootDart = void Function(WidgetRef nav, WidgetRef widget);
typedef NavigationSetTitleDart =
    void Function(
      WidgetRef nav,
      Pointer<Utf8> title,
      double r,
      double g,
      double b,
    );
typedef NavigationAddLeftBarButtonDart =
    void Function(
      WidgetRef nav,
      Pointer<Utf8> title,
      Pointer<Utf8> icon,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef NavigationAddRightBarButtonDart =
    void Function(
      WidgetRef nav,
      Pointer<Utf8> title,
      Pointer<Utf8> icon,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef NavigationSetBackgroundColorDart =
    void Function(WidgetRef nav, double r, double g, double b);
typedef ListViewUpdateItemDart =
    void Function(WidgetRef list, int index, WidgetRef item);
typedef ListViewSetBuilderDart =
    void Function(
      WidgetRef list,
      int count,
      Pointer<NativeFunction<ListViewBuilderCallbackC>> callback,
    );
typedef ListViewSetItemHeightDart =
    void Function(WidgetRef list, double height);
typedef ListViewSetCountDart = void Function(WidgetRef list, int count);
typedef ContainerSetChildDart =
    void Function(WidgetRef parent, WidgetRef child);
typedef LinearAddChildrenDart =
    void Function(WidgetRef parent, Pointer<WidgetRef> children, int count);
typedef WidgetLayoutRootDart =
    void Function(WidgetRef root, double width, double height);
typedef GetUIViewFromWidgetDart = Pointer<Void> Function(WidgetRef root);

// --- Function Lookups ---

final createText = nativeLib.lookupFunction<CreateTextC, CreateTextDart>(
  'create_text',
);
final createButton = nativeLib.lookupFunction<CreateButtonC, CreateButtonDart>(
  'create_button',
);
final createImage = nativeLib.lookupFunction<CreateImageC, CreateImageDart>(
  'create_image',
);
final createImageFromUrl = nativeLib
    .lookupFunction<CreateImageFromUrlC, CreateImageFromUrlDart>(
      'create_image_from_url',
    );
final createSwitch = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_switch',
);
final createContainer = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_container',
);
final createCard = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_card',
);
final createColumn = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_column',
);
final createRow = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_row',
);

final createTextField = nativeLib
    .lookupFunction<CreateTextFieldC, CreateTextFieldDart>('create_text_field');
final createTextEditor = nativeLib
    .lookupFunction<CreateTextEditorC, CreateTextEditorDart>(
      'create_text_editor',
    );
final createActivityIndicator = nativeLib
    .lookupFunction<CreateActivityIndicatorC, CreateActivityIndicatorDart>(
      'create_activity_indicator',
    );
final createProgressView = nativeLib
    .lookupFunction<CreateProgressViewC, CreateProgressViewDart>(
      'create_progress_view',
    );
final progressSetProgress = nativeLib
    .lookupFunction<ProgressSetProgressC, ProgressSetProgressDart>(
      'progress_set_progress',
    );
final createSegmentedControl = nativeLib
    .lookupFunction<CreateSegmentedControlC, CreateSegmentedControlDart>(
      'create_segmented_control',
    );
final createSlider = nativeLib.lookupFunction<CreateSliderC, CreateSliderDart>(
  'create_slider',
);
final createChip = nativeLib.lookupFunction<CreateChipC, CreateChipDart>(
  'create_chip',
);

final widgetSetPadding = nativeLib
    .lookupFunction<WidgetSetPaddingC, WidgetSetPaddingDart>(
      'widget_set_padding',
    );
final widgetSetMargin = nativeLib
    .lookupFunction<WidgetSetMarginC, WidgetSetMarginDart>('widget_set_margin');
final widgetSetSize = nativeLib
    .lookupFunction<WidgetSetSizeC, WidgetSetSizeDart>('widget_set_size');
final widgetSetBackgroundColor = nativeLib
    .lookupFunction<WidgetSetBgColorC, WidgetSetBgColorDart>(
      'widget_set_background_color',
    );
final widgetSetCornerRadius = nativeLib
    .lookupFunction<WidgetSetCornerRadiusC, WidgetSetCornerRadiusDart>(
      'widget_set_corner_radius',
    );
final widgetSetFlexGrow = nativeLib
    .lookupFunction<WidgetSetFlexGrowC, WidgetSetFlexGrowDart>(
      'widget_set_flex_grow',
    );
final widgetSetOnClick = nativeLib
    .lookupFunction<WidgetSetOnClickC, WidgetSetOnClickDart>(
      'widget_set_on_click',
    );
final widgetLog = nativeLib.lookupFunction<WidgetLogC, WidgetLogDart>(
  'widget_log',
);
final createListView = nativeLib
    .lookupFunction<CreateListViewC, CreateListViewDart>('create_list_view');
final createScrollView = nativeLib
    .lookupFunction<CreateScrollViewC, CreateScrollViewDart>(
      'create_scroll_view',
    );
final createNavigation = nativeLib
    .lookupFunction<CreateNavigationC, CreateNavigationDart>(
      'create_navigation',
    );
final navigationPush = nativeLib
    .lookupFunction<NavigationPushC, NavigationPushDart>('navigation_push');
final navigationPushWithTitle = nativeLib
    .lookupFunction<NavigationPushWithTitleC, NavigationPushWithTitleDart>(
      'navigation_push_with_title',
    );
final navigationPop = nativeLib
    .lookupFunction<NavigationPopC, NavigationPopDart>('navigation_pop');
final navigationSetRoot = nativeLib
    .lookupFunction<NavigationSetRootC, NavigationSetRootDart>(
      'navigation_set_root',
    );
final navigationSetTitle = nativeLib
    .lookupFunction<NavigationSetTitleC, NavigationSetTitleDart>(
      'navigation_set_title',
    );
final navigationAddLeftBarButton = nativeLib
    .lookupFunction<
      NavigationAddLeftBarButtonC,
      NavigationAddLeftBarButtonDart
    >('navigation_add_left_bar_button');
final navigationAddRightBarButton = nativeLib
    .lookupFunction<
      NavigationAddRightBarButtonC,
      NavigationAddRightBarButtonDart
    >('navigation_add_right_bar_button');
final navigationSetBackgroundColor = nativeLib
    .lookupFunction<
      NavigationSetBackgroundColorC,
      NavigationSetBackgroundColorDart
    >('navigation_set_background_color');
final listViewSetBuilder = nativeLib
    .lookupFunction<ListViewSetBuilderC, ListViewSetBuilderDart>(
      'list_view_set_builder',
    );
final listViewSetCount = nativeLib
    .lookupFunction<ListViewSetCountC, ListViewSetCountDart>(
      'list_view_set_count',
    );
final listViewUpdateItem = nativeLib
    .lookupFunction<ListViewUpdateItemC, ListViewUpdateItemDart>(
      'list_view_update_item',
    );
final listViewSetItemHeight = nativeLib
    .lookupFunction<ListViewSetItemHeightC, ListViewSetItemHeightDart>(
      'list_view_set_item_height',
    );
final createSafeArea = nativeLib
    .lookupFunction<CreateListViewC, CreateListViewDart>('create_safe_area');
final containerSetChild = nativeLib
    .lookupFunction<ContainerSetChildC, ContainerSetChildDart>(
      'container_set_child',
    );
final linearAddChildren = nativeLib
    .lookupFunction<LinearAddChildrenC, LinearAddChildrenDart>(
      'linear_add_children',
    );

final widgetLayoutRoot = nativeLib
    .lookupFunction<WidgetLayoutRootC, WidgetLayoutRootDart>(
      'widget_layout_root',
    );

// MARK: - FlashList Bindings
typedef CreateFlashListC = WidgetRef Function();
typedef CreateFlashListDart = WidgetRef Function();
typedef FlashListSetItemCountC = Void Function(WidgetRef list, Int64 count);
typedef FlashListSetItemCountDart = void Function(WidgetRef list, int count);
typedef FlashListSetItemHeightC = Void Function(WidgetRef list, Float height);
typedef FlashListSetItemHeightDart =
    void Function(WidgetRef list, double height);
typedef FlashListSetContentHeightC =
    Void Function(WidgetRef list, Float height);
typedef FlashListSetContentHeightDart =
    void Function(WidgetRef list, double height);
typedef FlashListUpdateItemC =
    Void Function(WidgetRef list, Int64 index, WidgetRef widget);
typedef FlashListUpdateItemDart =
    void Function(WidgetRef list, int index, WidgetRef widget);
typedef FlashListRemoveItemC = Void Function(WidgetRef list, Int64 index);
typedef FlashListRemoveItemDart = void Function(WidgetRef list, int index);
typedef FlashListClearC = Void Function(WidgetRef list);
typedef FlashListClearDart = void Function(WidgetRef list);
typedef FlashListGetScrollOffsetC = Float Function(WidgetRef list);
typedef FlashListGetScrollOffsetDart = double Function(WidgetRef list);

final createFlashList = nativeLib
    .lookupFunction<CreateFlashListC, CreateFlashListDart>('create_flash_list');
final flashListSetItemCount = nativeLib
    .lookupFunction<FlashListSetItemCountC, FlashListSetItemCountDart>(
      'flash_list_set_item_count',
    );
final flashListSetItemHeight = nativeLib
    .lookupFunction<FlashListSetItemHeightC, FlashListSetItemHeightDart>(
      'flash_list_set_item_height',
    );
final flashListSetContentHeight = nativeLib
    .lookupFunction<FlashListSetContentHeightC, FlashListSetContentHeightDart>(
      'flash_list_set_content_height',
    );
final flashListUpdateItem = nativeLib
    .lookupFunction<FlashListUpdateItemC, FlashListUpdateItemDart>(
      'flash_list_update_item',
    );
final flashListRemoveItem = nativeLib
    .lookupFunction<FlashListRemoveItemC, FlashListRemoveItemDart>(
      'flash_list_remove_item',
    );
final flashListClear = nativeLib
    .lookupFunction<FlashListClearC, FlashListClearDart>('flash_list_clear');
final flashListGetScrollOffset = nativeLib
    .lookupFunction<FlashListGetScrollOffsetC, FlashListGetScrollOffsetDart>(
      'flash_list_get_scroll_offset',
    );

final getUIViewFromWidget = nativeLib
    .lookupFunction<GetUIViewFromWidgetC, GetUIViewFromWidgetDart>(
      'get_ui_view_from_widget',
    );

final widgetRelease = nativeLib
    .lookupFunction<WidgetReleaseC, WidgetReleaseDart>('widget_release');

typedef DisplayWidgetC = Void Function(Int32 viewHandleAddress);

// Dart Function Signature
typedef DisplayWidgetDart = void Function(int viewHandleAddress);

// New Function Lookup
final displayWidgetInViewController = nativeLib
    .lookupFunction<DisplayWidgetC, DisplayWidgetDart>(
      'display_widget_in_view_controller',
    );

// MARK: - Tab Bar Bindings
typedef CreateTabBarC = WidgetRef Function();
typedef CreateTabBarDart = WidgetRef Function();
typedef TabBarAddTabC =
    Void Function(
      WidgetRef tabBar,
      Pointer<Utf8> title,
      Pointer<Utf8> icon,
      WidgetRef widget,
    );
typedef TabBarAddTabDart =
    void Function(
      WidgetRef tabBar,
      Pointer<Utf8> title,
      Pointer<Utf8> icon,
      WidgetRef widget,
    );
typedef TabBarSetSelectedIndexC = Void Function(WidgetRef tabBar, Int32 index);
typedef TabBarSetSelectedIndexDart = void Function(WidgetRef tabBar, int index);
typedef TabBarSetBackgroundColorC =
    Void Function(WidgetRef tabBar, Float r, Float g, Float b, Float a);
typedef TabBarSetBackgroundColorDart =
    void Function(WidgetRef tabBar, double r, double g, double b, double a);
typedef TabBarSetTintColorC =
    Void Function(WidgetRef tabBar, Float r, Float g, Float b);
typedef TabBarSetTintColorDart =
    void Function(WidgetRef tabBar, double r, double g, double b);
typedef TabBarSetUnselectedItemColorC =
    Void Function(WidgetRef tabBar, Float r, Float g, Float b);
typedef TabBarSetUnselectedItemColorDart =
    void Function(WidgetRef tabBar, double r, double g, double b);
typedef TabBarSetBadgeC =
    Void Function(WidgetRef tabBar, Int32 index, Pointer<Utf8> badge);
typedef TabBarSetBadgeDart =
    void Function(WidgetRef tabBar, int index, Pointer<Utf8> badge);
typedef TabBarHideC = Void Function(WidgetRef tabBar, Bool hidden);
typedef TabBarHideDart = void Function(WidgetRef tabBar, bool hidden);
typedef TabBarSetOnTabSelectedC =
    Void Function(
      WidgetRef tabBar,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef TabBarSetOnTabSelectedDart =
    void Function(
      WidgetRef tabBar,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef TabBarGetSelectedIndexC = Int32 Function(WidgetRef tabBar);
typedef TabBarGetSelectedIndexDart = int Function(WidgetRef tabBar);

final createTabBar = nativeLib.lookupFunction<CreateTabBarC, CreateTabBarDart>(
  'create_tab_bar',
);
final tabBarAddTab = nativeLib.lookupFunction<TabBarAddTabC, TabBarAddTabDart>(
  'tab_bar_add_tab',
);
final tabBarSetSelectedIndex = nativeLib
    .lookupFunction<TabBarSetSelectedIndexC, TabBarSetSelectedIndexDart>(
      'tab_bar_set_selected_index',
    );
final tabBarSetBackgroundColor = nativeLib
    .lookupFunction<TabBarSetBackgroundColorC, TabBarSetBackgroundColorDart>(
      'tab_bar_set_background_color',
    );
final tabBarSetTintColor = nativeLib
    .lookupFunction<TabBarSetTintColorC, TabBarSetTintColorDart>(
      'tab_bar_set_tint_color',
    );
final tabBarSetUnselectedItemColor = nativeLib
    .lookupFunction<
      TabBarSetUnselectedItemColorC,
      TabBarSetUnselectedItemColorDart
    >('tab_bar_set_unselected_item_color');
final tabBarSetBadge = nativeLib
    .lookupFunction<TabBarSetBadgeC, TabBarSetBadgeDart>('tab_bar_set_badge');
final tabBarHide = nativeLib.lookupFunction<TabBarHideC, TabBarHideDart>(
  'tab_bar_hide',
);
final tabBarSetOnTabSelected = nativeLib
    .lookupFunction<TabBarSetOnTabSelectedC, TabBarSetOnTabSelectedDart>(
      'tab_bar_set_on_tab_selected',
    );
final tabBarGetSelectedIndex = nativeLib
    .lookupFunction<TabBarGetSelectedIndexC, TabBarGetSelectedIndexDart>(
      'tab_bar_get_selected_index',
    );

// MARK: - Modal Bindings
typedef CreateModalC = WidgetRef Function(Pointer<Utf8> title);
typedef CreateModalDart = WidgetRef Function(Pointer<Utf8> title);
typedef ModalSetContentC = Void Function(WidgetRef modal, WidgetRef widget);
typedef ModalSetContentDart = void Function(WidgetRef modal, WidgetRef widget);
typedef ModalAddDismissButtonC =
    Void Function(
      WidgetRef modal,
      Pointer<Utf8> title,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef ModalAddDismissButtonDart =
    void Function(
      WidgetRef modal,
      Pointer<Utf8> title,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef ModalPresentC = Void Function(WidgetRef modal, WidgetRef from);
typedef ModalPresentDart = void Function(WidgetRef modal, WidgetRef from);
typedef ModalDismissC = Void Function(WidgetRef modal);
typedef ModalDismissDart = void Function(WidgetRef modal);

final createModal = nativeLib.lookupFunction<CreateModalC, CreateModalDart>(
  'create_modal',
);
final modalSetContent = nativeLib
    .lookupFunction<ModalSetContentC, ModalSetContentDart>('modal_set_content');
final modalAddDismissButton = nativeLib
    .lookupFunction<ModalAddDismissButtonC, ModalAddDismissButtonDart>(
      'modal_add_dismiss_button',
    );
final modalPresent = nativeLib.lookupFunction<ModalPresentC, ModalPresentDart>(
  'modal_present',
);
final modalDismiss = nativeLib.lookupFunction<ModalDismissC, ModalDismissDart>(
  'modal_dismiss',
);
