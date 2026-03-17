//
//  Scatter.swift
//  AddToAppIos
//
//  Created by Rafal Wachol on 2025/12/12.
//


import UIKit
import FlexLayout
//import PinLayout

// In a Flutter-like system, everything is a Widget. Here, every Widget wraps a UIView.
public class FlexWidget: NSObject {
    public let view: UIView
    
    init(view: UIView) {
        self.view = view
    }
    
    // Default layout implementation does nothing.
    // Subclasses can override this if they need custom layout logic (like ScrollWidget).
    @MainActor open func layout() {
    }
}


// Custom UIView that triggers FlexLayout updates on resize
public class FlexView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Determine layout mode? Default to fitContainer for root?
        // Actually, just calling layout() uses the defined properties.
        self.flex.layout()
    }
}

// Handles Padding, Size, Color, and a single Child
public class ContainerWidget: FlexWidget {
    public override init(view: UIView = FlexView()) {
        super.init(view: view)
    }
    
    // Builder methods for configuration
    @MainActor public func setPadding(_ value: CGFloat) -> ContainerWidget {
        view.flex.padding(value)
        return self
    }
    
    @MainActor public func setSize(width: CGFloat?, height: CGFloat?) -> ContainerWidget {
        if let w = width { view.flex.width(w) }
        if let h = height { view.flex.height(h) }
        return self
    }
    
    public func setColor(r: CGFloat, g: CGFloat, b: CGFloat) -> ContainerWidget {
        view.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        return self
    }
    
    // Composition: Accepts a single child
    @MainActor public func setChild(_ child: FlexWidget) -> ContainerWidget {
        // FlexLayout requires adding the subview, then defining the item
        view.addSubview(child.view)
        child.view.flex.markDirty() // Ensure layout update
        
        // Define the layout for this container
        view.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(child.view)
        }
        return self
    }
}

public class SafeAreaView: FlexView {
    var onInsetsChanged: (() -> Void)?
    
    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        onInsetsChanged?()
    }
}

public class SafeAreaWidget: ContainerWidget {
    public init() {
        let view = SafeAreaView()
        super.init(view: view)
        view.onInsetsChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.layout()
            }
        }
    }
    
    @MainActor public override func layout() {
        // Apply safe area insets as padding
        view.flex.padding(view.safeAreaInsets)
        view.flex.layout()
    }
    
    @MainActor public override func setChild(_ child: FlexWidget) -> ContainerWidget {
        view.addSubview(child.view)
        child.view.flex.markDirty()
        
        // SafeArea should fill the screen and stretch its child
        view.flex.direction(.column).alignItems(.stretch).define { flex in
            flex.addItem(child.view).grow(1)
        }
        return self
    }
}

@_cdecl("create_safe_area")
public func create_safe_area() -> UnsafeMutableRawPointer {
    let widget = SafeAreaWidget()
    return Unmanaged.passRetained(widget).toOpaque()
}

// Handles Multi-child layouts (Column/Row)
public class LinearWidget: FlexWidget {
    private let direction: Flex.Direction
    
    public init(direction: Flex.Direction) {
        self.direction = direction
        super.init(view: UIView())
    }
    
    // Composition: Accepts multiple children
    @MainActor public func addChildren(_ children: [FlexWidget]) {
        children.forEach { view.addSubview($0.view) }
        
        view.flex.direction(direction).padding(10).define { flex in
            for child in children {
                // Add item with some default spacing between elements
                flex.addItem(child.view).marginBottom(10)
            }
        }
    }
}

// Special "Card" Widget (Composition of Container + Styling)
public class CardWidget: ContainerWidget {
    public  init() {
        super.init()
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.backgroundColor = .white
    }
}

// MARK: - 3. Leaf Widgets (Content)

public class TextWidget: FlexWidget {
    public init(_ text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        super.init(view: label)
    }
}

public class ButtonWidget: FlexWidget {
    private var onClick: (() -> Void)?
    
    @MainActor public init(text: String) {
        let btn = UIButton(type: .system)
        btn.setTitle(text, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        // intrinsic content size handles dimensions
        super.init(view: btn)
        // Give button specific sizing constraints in flex
        self.view.flex.height(44).paddingHorizontal(20)
        
        btn.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc func handleTap() {
        onClick?()
    }
    
    func setOnClick(_ callback: @escaping () -> Void) {
        self.onClick = callback
    }
}

public class ImageWidget: FlexWidget {
    @MainActor public init(systemName: String) {
        let imgView = UIImageView(image: UIImage(systemName: systemName))
        imgView.contentMode = .scaleAspectFit
        super.init(view: imgView)
        self.view.flex.size(50)
    }
    
    @MainActor public init(url: String) {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        super.init(view: imgView)
        self.view.flex.size(200)
        
        guard let imageUrl = URL(string: url) else { return }
        
        let viewRef = self.view
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imgView.image = image
                viewRef.flex.layout()
            }
        }.resume()
    }
}

public class SwitchWidget: FlexWidget {
    public init() {
        let toggle = UISwitch()
        super.init(view: toggle)
    }
}

// MARK: - TextField Widget

public class TextFieldWidget: FlexWidget, UITextFieldDelegate {
    private var onChanged: ((String) -> Void)?
    
    @MainActor public init(placeholder: String) {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        super.init(view: textField)
        textField.delegate = self
        self.view.flex.height(44).paddingHorizontal(10)
    }
    
    func setOnChanged(_ callback: @escaping (String) -> Void) {
        self.onChanged = callback
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        onChanged?(textField.text ?? "")
    }
}

// MARK: - TextEditor Widget

public class TextEditorWidget: FlexWidget {
    @MainActor public init(text: String) {
        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        super.init(view: textView)
        self.view.flex.height(100).padding(8)
    }
}

// MARK: - ActivityIndicator Widget

public class ActivityIndicatorWidget: FlexWidget {
    @MainActor public init(style: String) {
        let indicator = UIActivityIndicatorView(style: style == "large" ? .large : .medium)
        indicator.startAnimating()
        super.init(view: indicator)
    }
    
    public func stopAnimating() {
        (view as? UIActivityIndicatorView)?.stopAnimating()
    }
}

// MARK: - ProgressView Widget

public class ProgressWidget: FlexWidget {
    @MainActor public init() {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0.5
        super.init(view: progress)
        self.view.flex.height(4)
    }
    
    public func setProgress(_ value: Float) {
        (view as? UIProgressView)?.setProgress(value, animated: true)
    }
}

// MARK: - Slider Widget

public class SliderWidget: FlexWidget {
    private var onChanged: ((Float) -> Void)?
    
    @MainActor public init(min: Float = 0, max: Float = 1, value: Float = 0.5) {
        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        super.init(view: slider)
        
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        onChanged?(sender.value)
    }
    
    public func setOnChanged(_ callback: @escaping (Float) -> Void) {
        self.onChanged = callback
    }
}

// MARK: - Chip Widget

public class ChipWidget: FlexWidget {
    @MainActor public init(text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.textAlignment = .center
        
        // Calculate size needed for text
        label.sizeToFit()
        
        // Add padding: 20px horizontal, 14px vertical (total 40px height)
        let width = label.frame.width + 40
        let height: CGFloat = 40
        
        // Set frame
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Apply corner radius after setting frame
        label.layer.cornerRadius = height / 2
        label.layer.masksToBounds = true
        
        super.init(view: label)
    }
}

// MARK: - SegmentedControl Widget

public class SegmentedControlWidget: FlexWidget {
    private var segments: [String]
    private var onChanged: ((Int) -> Void)?
    
    @MainActor public init(segments: [String]) {
        let control = UISegmentedControl(items: segments)
        control.selectedSegmentIndex = 0
        self.segments = segments
        super.init(view: control)
        
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        onChanged?(sender.selectedSegmentIndex)
    }
    
    func setOnChanged(_ callback: @escaping (Int) -> Void) {
        self.onChanged = callback
    }
}

// MARK: - 4. C-Bindings
// We expose these classes via opaque pointers (void*)

// --- Constructors ---

@_cdecl("create_text")
public func create_text(_ text: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: text)
    return Unmanaged.passRetained(TextWidget(str)).toOpaque()
}

@_cdecl("create_button")
public func create_button(_ text: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    MainActor.assumeIsolated {
        let str = String(cString: text)
        return Unmanaged.passRetained(ButtonWidget(text: str)).toOpaque()
    }
}

@_cdecl("create_image")
public func create_image(_ name: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    MainActor.assumeIsolated {
        let str = String(cString: name)
        return Unmanaged.passRetained(ImageWidget(systemName: str)).toOpaque()
    }
}

@_cdecl("create_image_from_url")
public func create_image_from_url(_ url: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: url)
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(ImageWidget(url: str)).toOpaque()
    }
}

@_cdecl("create_switch")
public func create_switch() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(SwitchWidget()).toOpaque()
}

@_cdecl("create_slider")
public func create_slider(_ min: Float, _ max: Float, _ value: Float) -> UnsafeMutableRawPointer {
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(SliderWidget(min: min, max: max, value: value)).toOpaque()
    }
}

@_cdecl("create_chip")
public func create_chip(_ text: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: text)
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(ChipWidget(text: str)).toOpaque()
    }
}

@_cdecl("create_text_field")
public func create_text_field(_ placeholder: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: placeholder)
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(TextFieldWidget(placeholder: str)).toOpaque()
    }
}

@_cdecl("create_text_editor")
public func create_text_editor(_ text: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: text)
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(TextEditorWidget(text: str)).toOpaque()
    }
}

@_cdecl("create_activity_indicator")
public func create_activity_indicator(_ style: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: style)
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(ActivityIndicatorWidget(style: str)).toOpaque()
    }
}

@_cdecl("create_progress_view")
public func create_progress_view() -> UnsafeMutableRawPointer {
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(ProgressWidget()).toOpaque()
    }
}

@_cdecl("create_segmented_control")
public func create_segmented_control(_ segmentsJson: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let jsonStr = String(cString: segmentsJson)
    let segments = jsonStr.components(separatedBy: "|")
    return MainActor.assumeIsolated {
        Unmanaged.passRetained(SegmentedControlWidget(segments: segments)).toOpaque()
    }
}

@_cdecl("progress_set_progress")
public func progress_set_progress(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    if let progress = widget as? ProgressWidget {
        progress.setProgress(value)
    }
}

@_cdecl("create_container")
public func create_container() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(ContainerWidget()).toOpaque()
}

@_cdecl("create_card")
public func create_card() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(CardWidget()).toOpaque()
}

// MARK: - NavigationController Widget

public class NavigationWidget: FlexWidget {
    let navigationController: UINavigationController
    var rootViewController: UIViewController?
    
    @MainActor public init(title: String) {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = title
        
        rootViewController = vc
        navigationController = UINavigationController(rootViewController: vc)
        
        super.init(view: navigationController.view)
    }
    
    @MainActor public func setRoot(_ widget: FlexWidget) {
        guard let rootVC = rootViewController else { return }
        
        // Clear existing subviews and add new one
        rootVC.view.subviews.forEach { $0.removeFromSuperview() }
        rootVC.view.addSubview(widget.view)
        
        widget.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widget.view.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
            widget.view.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor),
            widget.view.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
            widget.view.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor)
        ])
    }
    
    @MainActor public func push(_ widget: FlexWidget) {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.view.addSubview(widget.view)
        
        widget.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widget.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            widget.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            widget.view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            widget.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    @MainActor public func pop() {
        navigationController.popViewController(animated: true)
    }
    
    @MainActor public func setTitle(_ title: String) {
        navigationController.topViewController?.title = title
    }
}

@_cdecl("create_column")
public func create_column() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(LinearWidget(direction: .column)).toOpaque()
}

@_cdecl("create_row")
public func create_row() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(LinearWidget(direction: .row)).toOpaque()
}

// --- Modifiers / Composition ---

@_cdecl("widget_set_padding")
public func widget_set_padding(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    MainActor.assumeIsolated {
        let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
        widget.view.flex.padding(CGFloat(value))
    }
}

@_cdecl("widget_set_margin")
public func widget_set_margin(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    MainActor.assumeIsolated {
        let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
        widget.view.flex.margin(CGFloat(value))
    }
}

@_cdecl("widget_set_size")
public func widget_set_size(_ ptr: UnsafeMutableRawPointer, width: Float, height: Float) {
    MainActor.assumeIsolated {
        let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
        if width > 0 { widget.view.flex.width(CGFloat(width)) }
        if height > 0 { widget.view.flex.height(CGFloat(height)) }
    }
}

@_cdecl("widget_set_background_color")
public func widget_set_background_color(_ ptr: UnsafeMutableRawPointer, r: Float, g: Float, b: Float, a: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.backgroundColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
}

@_cdecl("widget_set_corner_radius")
public func widget_set_corner_radius(_ ptr: UnsafeMutableRawPointer, radius: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.layer.cornerRadius = CGFloat(radius)
    widget.view.clipsToBounds = true
}

@_cdecl("widget_set_flex_grow")
public func widget_set_flex_grow(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    MainActor.assumeIsolated {
        let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
        widget.view.flex.grow(CGFloat(value))
    }
}

@_cdecl("widget_set_on_click")
public func widget_set_on_click(_ ptr: UnsafeMutableRawPointer, _ callback: @convention(c) @escaping () -> Void) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    if let btn = widget as? ButtonWidget {
        btn.setOnClick {
            callback()
        }
    }
}

@_cdecl("widget_log")
public func widget_log(_ message: UnsafePointer<CChar>) {
    NSLog("NATIVE_LOG: \(String(cString: message))")
}


@_cdecl("container_set_child")
public func container_set_child(_ containerPtr: UnsafeMutableRawPointer, _ childPtr: UnsafeMutableRawPointer) {
    MainActor.assumeIsolated {
        let container = Unmanaged<FlexWidget>.fromOpaque(containerPtr).takeUnretainedValue()
        let child = Unmanaged<FlexWidget>.fromOpaque(childPtr).takeUnretainedValue()
        
        // Support ScrollWidget specifically
        if let scrollWidget = container as? ScrollWidget {
            scrollWidget.setChild(child.view)
        } else if let containerWidget = container as? ContainerWidget {
            _ = containerWidget.setChild(child)
        }
    }
}

@_cdecl("linear_add_children")
public func linear_add_children(
    _ containerPtr: UnsafeMutableRawPointer,
    _ childrenRawPtr: UnsafePointer<UnsafeMutableRawPointer>,
    _ count: Int
) {
    MainActor.assumeIsolated {
        let container = Unmanaged<LinearWidget>.fromOpaque(containerPtr).takeUnretainedValue()
        
        var children: [FlexWidget] = []
        
        // Convert C array of pointers to Swift Array of FlexWidgets
        let buffer = UnsafeBufferPointer(start: childrenRawPtr, count: count)
        for ptr in buffer {
            let child = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
            children.append(child)
        }
        
        container.addChildren(children)
    }
}

// MARK: - ScrollWidget
// MARK: - ScrollWidget

// Custom UIScrollView to handle internal layout automatically
class FlexScrollView: UIScrollView {
    weak var contentContainer: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let contentContainer = contentContainer else { return }
        
        // Only proceed if we have a valid width
        guard bounds.width > 0 else { return }
        
        // Set width first, then layout to calculate height
        contentContainer.flex.width(bounds.width).layout(mode: .adjustHeight)
        
        // Get the calculated height from frame
        let calculatedHeight = contentContainer.frame.height
        
        // Set the frame with calculated height
        contentContainer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: calculatedHeight)
        
        // Sets contentSize
        self.contentSize = CGSize(width: bounds.width, height: max(calculatedHeight, bounds.height))
        
        print("DEBUG: FlexScrollView layout. Frame: \(self.frame), ContentFrame: \(contentContainer.frame), ContentSize: \(self.contentSize)")
    }
}

public class ScrollWidget: FlexWidget {
    let scrollView: FlexScrollView = FlexScrollView()
    public let contentContainer = UIView()
    
    @MainActor init() {
        scrollView.contentContainer = contentContainer
        scrollView.backgroundColor = .systemBackground
        
        super.init(view: scrollView)
        
        // Configure the content container
        contentContainer.flex.direction(.column).padding(10)
        
        scrollView.addSubview(contentContainer)
    }
    
    @MainActor public override func layout() {
        // Ensure scrollView fills its container via FlexLayout
        scrollView.flex.layout(mode: .fitContainer)
    }
    
    @MainActor public func setChild(_ childView: UIView) {
        // Add the child to contentContainer
        contentContainer.flex.addItem(childView)
    }
    
    // No longer need manual layout override since FlexScrollView handles it
}

@_cdecl("create_scroll_view")
public func create_scroll_view() -> UnsafeMutableRawPointer {
    MainActor.assumeIsolated {
        let widget = ScrollWidget()
        return Unmanaged.passRetained(widget).toOpaque()
    }
}

@_cdecl("create_navigation")
public func create_navigation(_ title: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let titleStr = String(cString: title)
    return MainActor.assumeIsolated {
        let widget = NavigationWidget(title: titleStr)
        return Unmanaged.passRetained(widget).toOpaque()
    }
}

@_cdecl("navigation_push")
public func navigation_push(_ navPtr: UnsafeMutableRawPointer, _ widgetPtr: UnsafeMutableRawPointer) {
    MainActor.assumeIsolated {
        let nav = Unmanaged<FlexWidget>.fromOpaque(navPtr).takeUnretainedValue()
        let widget = Unmanaged<FlexWidget>.fromOpaque(widgetPtr).takeUnretainedValue()
        
        if let navWidget = nav as? NavigationWidget {
            navWidget.push(widget)
        }
    }
}

@_cdecl("navigation_pop")
public func navigation_pop(_ navPtr: UnsafeMutableRawPointer) {
    MainActor.assumeIsolated {
        let nav = Unmanaged<FlexWidget>.fromOpaque(navPtr).takeUnretainedValue()
        
        if let navWidget = nav as? NavigationWidget {
            navWidget.pop()
        }
    }
}

@_cdecl("navigation_set_root")
public func navigation_set_root(_ navPtr: UnsafeMutableRawPointer, _ widgetPtr: UnsafeMutableRawPointer) {
    MainActor.assumeIsolated {
        let nav = Unmanaged<FlexWidget>.fromOpaque(navPtr).takeUnretainedValue()
        let widget = Unmanaged<FlexWidget>.fromOpaque(widgetPtr).takeUnretainedValue()
        
        if let navWidget = nav as? NavigationWidget {
            navWidget.setRoot(widget)
        }
    }
}

// MARK: - NativeListView (UICollectionView)

class FlexCollectionCell: UICollectionViewCell {
    static let id = "FlexCollectionCell"
    var hostedView: UIView? {
        didSet {
            // Remove old view if any
            oldValue?.removeFromSuperview()
            
            if let v = hostedView {
                contentView.addSubview(v)
                // We use flex layout inside the cell too
                v.flex.markDirty()
                setNeedsLayout()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let hostedView = hostedView else { return }
        
        // Layout logic:
        // We want the hosted view to fill the cell's CONTENT VIEW
//        hostedView.pin.all()
        hostedView.flex.layout() 
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let hostedView = hostedView else { return .zero }
        // Calculate size based on width
        hostedView.flex.width(size.width).layout(mode: .adjustHeight)
        return hostedView.frame.size
    }
    
    // UICollectionViewCell preferredAttributes uses systemLayoutSizeFitting by default
}

    
public class NativeListView: FlexWidget, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var itemCount: Int = 0
    // Async builder: Requests index, returns nothing immediately.
    var builder: ((Int) -> Void)?
    var cachedItems: [Int: UIView] = [:]
    let collectionView: UICollectionView
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        // Debugging: Start with fixed size to rule out auto-sizing issues
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 60)
        // layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize 
        
        // Initialize Collection View
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear // .blue for debugging?
        
        super.init(view: collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FlexCollectionCell.self, forCellWithReuseIdentifier: FlexCollectionCell.id)
    }
    
    public func setBuilder(count: Int, callback: @escaping (Int) -> Void) {
        print("DEBUG: NativeListView setBuilder count: \(count)")
        self.itemCount = count
        self.builder = callback
        self.cachedItems.removeAll() // Clear cache on new builder
        collectionView.reloadData()
    }
    
    public func updateItem(index: Int, view: UIView) {
        // print("DEBUG: NativeListView updateItem at \(index)")
        cachedItems[index] = view
        
        // Find if this cell is visible and update it immediately
        // (Avoiding full reloadData for performance)
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell), indexPath.item == index {
                (cell as? FlexCollectionCell)?.hostedView = view
            }
        }
    }
    
    // MARK: - DataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlexCollectionCell.id, for: indexPath) as! FlexCollectionCell
        
        if let view = cachedItems[indexPath.item] {
            cell.hostedView = view
        } else {
            // Cache miss
            cell.hostedView = nil // Or a placeholder/loading view
            
            if let builder = builder {
                // print("DEBUG: request builder for \(indexPath.item)")
                builder(indexPath.item)
            }
        }
        
        return cell
    }
    
    // ensure cleanup?
    
    // MARK: - FlowLayout Delegate (Optional customization)
    /*
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // If we didn't use automaticSize, we would calculate it here:
        let item = items[indexPath.item]
        // Calculate height for full width
        let width = collectionView.bounds.width
        item.flex.width(width).layout(mode: .adjustHeight)
        return item.frame.size
    }
    */
    
    // Ensure the list itself lays out correctly
    public override func layout() {
        // print("DEBUG: NativeListView layout frame: \(view.frame)")
        super.layout()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

@_cdecl("list_view_set_builder")
public func list_view_set_builder(
    _ listPtr: UnsafeMutableRawPointer,
    _ count: Int,
    _ callback: @convention(c) @escaping (UnsafeMutableRawPointer, Int) -> Void
) {
    let listView = Unmanaged<FlexWidget>.fromOpaque(listPtr).takeUnretainedValue() as! NativeListView
    
    listView.setBuilder(count: count) { index in
        // Call C callback to request item (Async)
        callback(listPtr, index)
    }
}

@_cdecl("list_view_update_item")
public func list_view_update_item(
    _ listPtr: UnsafeMutableRawPointer,
    _ index: Int,
    _ childPtr: UnsafeMutableRawPointer
) {
    let listView = Unmanaged<FlexWidget>.fromOpaque(listPtr).takeUnretainedValue() as! NativeListView
    let child = Unmanaged<FlexWidget>.fromOpaque(childPtr).takeUnretainedValue()
    
    listView.updateItem(index: index, view: child.view)
}

@_cdecl("create_list_view")
public func create_list_view() -> UnsafeMutableRawPointer {
    let widget = NativeListView()
    return Unmanaged.passRetained(widget).toOpaque()
}

// --- Layout Helper ---
// Since FlexLayout needs a manual layout call on the root
@_cdecl("widget_layout_root")
public func widget_layout_root(_ ptr: UnsafeMutableRawPointer, width: Float, height: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
//    widget.view.pin.width(CGFloat(width)).height(CGFloat(height))
//    widget.view.flex.layout(mode: .adjustHeight)
}

// MARK: - 5. View Retrieval Binding

@_cdecl("get_ui_view_from_widget")
// Returns the raw pointer to the underlying UIView of the widget.
// The returned view is RETAINED, meaning the caller (C/Dart) MUST call
// release_object_handle() on it later if it's not added to a managed UI hierarchy.
public func get_ui_view_from_widget(_ ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
    // 1. Get the FlexWidget object
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    
    // 2. Get the underlying UIView
    let uiView = widget.view
    
    // 3. Increment the reference count and return the opaque pointer to the UIView
    // This passes ownership of the UIView reference to the C/Dart layer.
    return Unmanaged.passRetained(uiView).toOpaque()
}

@_cdecl("widget_release")
public func widget_release(_ ptr: UnsafeMutableRawPointer) {
    // Take ownership back from C/Dart and let it fall out of scope to deallocate
    Unmanaged<FlexWidget>.fromOpaque(ptr).release()
}
