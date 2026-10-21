import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "BackgroundColor" asset catalog color resource.
    static let background = DeveloperToolsSupport.ColorResource(name: "BackgroundColor", bundle: resourceBundle)

    /// The "FocusPrimaryTextColor" asset catalog color resource.
    static let focusPrimaryText = DeveloperToolsSupport.ColorResource(name: "FocusPrimaryTextColor", bundle: resourceBundle)

    /// The "FocusSecondaryTextColor" asset catalog color resource.
    static let focusSecondaryText = DeveloperToolsSupport.ColorResource(name: "FocusSecondaryTextColor", bundle: resourceBundle)

    /// The "MainColor" asset catalog color resource.
    static let main = DeveloperToolsSupport.ColorResource(name: "MainColor", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "BackgroundColor" asset catalog color.
    static var background: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "FocusPrimaryTextColor" asset catalog color.
    static var focusPrimaryText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .focusPrimaryText)
#else
        .init()
#endif
    }

    /// The "FocusSecondaryTextColor" asset catalog color.
    static var focusSecondaryText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .focusSecondaryText)
#else
        .init()
#endif
    }

    /// The "MainColor" asset catalog color.
    static var main: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .main)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "BackgroundColor" asset catalog color.
    static var background: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "FocusPrimaryTextColor" asset catalog color.
    static var focusPrimaryText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .focusPrimaryText)
#else
        .init()
#endif
    }

    /// The "FocusSecondaryTextColor" asset catalog color.
    static var focusSecondaryText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .focusSecondaryText)
#else
        .init()
#endif
    }

    /// The "MainColor" asset catalog color.
    static var main: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .main)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "BackgroundColor" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "FocusPrimaryTextColor" asset catalog color.
    static var focusPrimaryText: SwiftUI.Color { .init(.focusPrimaryText) }

    /// The "FocusSecondaryTextColor" asset catalog color.
    static var focusSecondaryText: SwiftUI.Color { .init(.focusSecondaryText) }

    /// The "MainColor" asset catalog color.
    static var main: SwiftUI.Color { .init(.main) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "BackgroundColor" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "FocusPrimaryTextColor" asset catalog color.
    static var focusPrimaryText: SwiftUI.Color { .init(.focusPrimaryText) }

    /// The "FocusSecondaryTextColor" asset catalog color.
    static var focusSecondaryText: SwiftUI.Color { .init(.focusSecondaryText) }

    /// The "MainColor" asset catalog color.
    static var main: SwiftUI.Color { .init(.main) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

