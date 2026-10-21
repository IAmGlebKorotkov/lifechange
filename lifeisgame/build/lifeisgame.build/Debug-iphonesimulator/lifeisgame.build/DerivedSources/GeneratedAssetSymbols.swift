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

    /// The "LightMainColor" asset catalog color resource.
    static let lightMain = DeveloperToolsSupport.ColorResource(name: "LightMainColor", bundle: resourceBundle)

    /// The "MainColor" asset catalog color resource.
    static let main = DeveloperToolsSupport.ColorResource(name: "MainColor", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Arrow - Left" asset catalog image resource.
    static let arrowLeft = DeveloperToolsSupport.ImageResource(name: "Arrow - Left", bundle: resourceBundle)

    /// The "Calendar" asset catalog image resource.
    static let calendar = DeveloperToolsSupport.ImageResource(name: "Calendar", bundle: resourceBundle)

    /// The "File_Document" asset catalog image resource.
    static let fileDocument = DeveloperToolsSupport.ImageResource(name: "File_Document", bundle: resourceBundle)

    /// The "Hide" asset catalog image resource.
    static let hide = DeveloperToolsSupport.ImageResource(name: "Hide", bundle: resourceBundle)

    /// The "Lol" asset catalog image resource.
    static let lol = DeveloperToolsSupport.ImageResource(name: "Lol", bundle: resourceBundle)

    /// The "Show" asset catalog image resource.
    static let show = DeveloperToolsSupport.ImageResource(name: "Show", bundle: resourceBundle)

    /// The "Time Circle" asset catalog image resource.
    static let timeCircle = DeveloperToolsSupport.ImageResource(name: "Time Circle", bundle: resourceBundle)

    /// The "Time_sleep" asset catalog image resource.
    static let timeSleep = DeveloperToolsSupport.ImageResource(name: "Time_sleep", bundle: resourceBundle)

    /// The "User" asset catalog image resource.
    static let user = DeveloperToolsSupport.ImageResource(name: "User", bundle: resourceBundle)

    /// The "Vector" asset catalog image resource.
    static let vector = DeveloperToolsSupport.ImageResource(name: "Vector", bundle: resourceBundle)

    /// The "notification" asset catalog image resource.
    static let notification = DeveloperToolsSupport.ImageResource(name: "notification", bundle: resourceBundle)

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

    /// The "LightMainColor" asset catalog color.
    static var lightMain: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lightMain)
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

    /// The "LightMainColor" asset catalog color.
    static var lightMain: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .lightMain)
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

    /// The "LightMainColor" asset catalog color.
    static var lightMain: SwiftUI.Color { .init(.lightMain) }

    /// The "MainColor" asset catalog color.
    static var main: SwiftUI.Color { .init(.main) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "BackgroundColor" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "LightMainColor" asset catalog color.
    static var lightMain: SwiftUI.Color { .init(.lightMain) }

    /// The "MainColor" asset catalog color.
    static var main: SwiftUI.Color { .init(.main) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Arrow - Left" asset catalog image.
    static var arrowLeft: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .arrowLeft)
#else
        .init()
#endif
    }

    /// The "Calendar" asset catalog image.
    static var calendar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calendar)
#else
        .init()
#endif
    }

    /// The "File_Document" asset catalog image.
    static var fileDocument: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fileDocument)
#else
        .init()
#endif
    }

    /// The "Hide" asset catalog image.
    static var hide: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .hide)
#else
        .init()
#endif
    }

    /// The "Lol" asset catalog image.
    static var lol: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lol)
#else
        .init()
#endif
    }

    /// The "Show" asset catalog image.
    static var show: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .show)
#else
        .init()
#endif
    }

    /// The "Time Circle" asset catalog image.
    static var timeCircle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .timeCircle)
#else
        .init()
#endif
    }

    /// The "Time_sleep" asset catalog image.
    static var timeSleep: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .timeSleep)
#else
        .init()
#endif
    }

    /// The "User" asset catalog image.
    static var user: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .user)
#else
        .init()
#endif
    }

    /// The "Vector" asset catalog image.
    static var vector: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .vector)
#else
        .init()
#endif
    }

    /// The "notification" asset catalog image.
    static var notification: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .notification)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Arrow - Left" asset catalog image.
    static var arrowLeft: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .arrowLeft)
#else
        .init()
#endif
    }

    /// The "Calendar" asset catalog image.
    static var calendar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .calendar)
#else
        .init()
#endif
    }

    /// The "File_Document" asset catalog image.
    static var fileDocument: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fileDocument)
#else
        .init()
#endif
    }

    /// The "Hide" asset catalog image.
    static var hide: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .hide)
#else
        .init()
#endif
    }

    /// The "Lol" asset catalog image.
    static var lol: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lol)
#else
        .init()
#endif
    }

    /// The "Show" asset catalog image.
    static var show: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .show)
#else
        .init()
#endif
    }

    /// The "Time Circle" asset catalog image.
    static var timeCircle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .timeCircle)
#else
        .init()
#endif
    }

    /// The "Time_sleep" asset catalog image.
    static var timeSleep: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .timeSleep)
#else
        .init()
#endif
    }

    /// The "User" asset catalog image.
    static var user: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .user)
#else
        .init()
#endif
    }

    /// The "Vector" asset catalog image.
    static var vector: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .vector)
#else
        .init()
#endif
    }

    /// The "notification" asset catalog image.
    static var notification: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .notification)
#else
        .init()
#endif
    }

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

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
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

