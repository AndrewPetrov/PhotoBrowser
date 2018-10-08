// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
internal typealias AssetType = ImageAsset

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let _1 = ImageAsset(name: "1")
  internal static let _10 = ImageAsset(name: "10")
  internal static let _11 = ImageAsset(name: "11")
  internal static let _2 = ImageAsset(name: "2")
  internal static let _3 = ImageAsset(name: "3")
  internal static let _4 = ImageAsset(name: "4")
  internal static let _5 = ImageAsset(name: "5")
  internal static let _6 = ImageAsset(name: "6")
  internal static let _7 = ImageAsset(name: "7")
  internal static let _8 = ImageAsset(name: "8")
  internal static let _9 = ImageAsset(name: "9")
  internal static let iosPhotoBrowserDocPicture = ImageAsset(name: "iOSPhotoBrowser_docPicture")
  internal static let iosPhotoBrowserDocText = ImageAsset(name: "iOSPhotoBrowser_docText")
  internal static let iosPhotoBrowserDocUnknown = ImageAsset(name: "iOSPhotoBrowser_docUnknown")
  internal static let iosPhotoBrowserDoubleTick = ImageAsset(name: "iOSPhotoBrowser_doubleTick")
  internal static let iosPhotoBrowserLikeNo = ImageAsset(name: "iOSPhotoBrowser_likeNo")
  internal static let iosPhotoBrowserLikedYes = ImageAsset(name: "iOSPhotoBrowser_likedYes")
  internal static let iosPhotoBrowserNonSelected = ImageAsset(name: "iOSPhotoBrowser_nonSelected")
  internal static let iosPhotoBrowserPlay = ImageAsset(name: "iOSPhotoBrowser_play")
  internal static let iosPhotoBrowserSelected = ImageAsset(name: "iOSPhotoBrowser_selected")
  internal static let iosPhotoBrowserStar = ImageAsset(name: "iOSPhotoBrowser_star")
  internal static let iosPhotoBrowserTick = ImageAsset(name: "iOSPhotoBrowser_tick")
  internal static let iosPhotoBrowserVideoIcon = ImageAsset(name: "iOSPhotoBrowser_videoIcon")
  internal static let linkAppDev = ImageAsset(name: "linkAppDev")
  internal static let linkGoogle = ImageAsset(name: "linkGoogle")

  // swiftlint:disable trailing_comma
  internal static let allColors: [ColorAsset] = [
  ]
  internal static let allImages: [ImageAsset] = [
    _1,
    _10,
    _11,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _8,
    _9,
    iosPhotoBrowserDocPicture,
    iosPhotoBrowserDocText,
    iosPhotoBrowserDocUnknown,
    iosPhotoBrowserDoubleTick,
    iosPhotoBrowserLikeNo,
    iosPhotoBrowserLikedYes,
    iosPhotoBrowserNonSelected,
    iosPhotoBrowserPlay,
    iosPhotoBrowserSelected,
    iosPhotoBrowserStar,
    iosPhotoBrowserTick,
    iosPhotoBrowserVideoIcon,
    linkAppDev,
    linkGoogle,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  internal static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

internal extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
