//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.color` struct is generated, and contains static references to 4 colors.
  struct color {
    /// Color `p0`.
    static let p0 = Rswift.ColorResource(bundle: R.hostingBundle, name: "p0")
    /// Color `p1`.
    static let p1 = Rswift.ColorResource(bundle: R.hostingBundle, name: "p1")
    /// Color `p2`.
    static let p2 = Rswift.ColorResource(bundle: R.hostingBundle, name: "p2")
    /// Color `p3`.
    static let p3 = Rswift.ColorResource(bundle: R.hostingBundle, name: "p3")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "p0", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func p0(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.p0, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "p1", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func p1(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.p1, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "p2", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func p2(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.p2, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "p3", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func p3(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.p3, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "p0", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func p0(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.p0.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "p1", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func p1(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.p1.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "p2", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func p2(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.p2.name)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "p3", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func p3(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.p3.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.entitlements` struct is generated, and contains static references to 5 properties.
  struct entitlements {
    static let apsEnvironment = infoPlistString(path: [], key: "aps-environment") ?? "development"

    struct comAppleDeveloperApplesignin {
      static let `default` = infoPlistString(path: ["com.apple.developer.applesignin"], key: "Default") ?? "Default"

      fileprivate init() {}
    }

    struct comAppleDeveloperAssociatedDomains {
      static let applinksSemanticsDevWvrwgUclmiMongodbstitchCom = infoPlistString(path: ["com.apple.developer.associated-domains"], key: "applinks:semantics-dev-wvrwg-uclmi.mongodbstitch.com") ?? "applinks:semantics-dev-wvrwg-uclmi.mongodbstitch.com"

      fileprivate init() {}
    }

    struct comAppleDeveloperIcloudContainerIdentifiers {
      static let iCloudIndPaperSemanticsV3 = infoPlistString(path: ["com.apple.developer.icloud-container-identifiers"], key: "iCloud.ind.paper.semantics.v3") ?? "iCloud.ind.paper.semantics.v3"

      fileprivate init() {}
    }

    struct comAppleDeveloperIcloudServices {
      static let cloudKit = infoPlistString(path: ["com.apple.developer.icloud-services"], key: "CloudKit") ?? "CloudKit"

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  /// This `R.file` struct is generated, and contains static references to 5 files.
  struct file {
    /// Resource file `Poly.geojson`.
    static let polyGeojson = Rswift.FileResource(bundle: R.hostingBundle, name: "Poly", pathExtension: "geojson")
    /// Resource file `amplifyconfiguration.json`.
    static let amplifyconfigurationJson = Rswift.FileResource(bundle: R.hostingBundle, name: "amplifyconfiguration", pathExtension: "json")
    /// Resource file `apple-app-site-association`.
    static let appleAppSiteAssociation = Rswift.FileResource(bundle: R.hostingBundle, name: "apple-app-site-association", pathExtension: "")
    /// Resource file `awsconfiguration.json`.
    static let awsconfigurationJson = Rswift.FileResource(bundle: R.hostingBundle, name: "awsconfiguration", pathExtension: "json")
    /// Resource file `underwear.tiff`.
    static let underwearTiff = Rswift.FileResource(bundle: R.hostingBundle, name: "underwear", pathExtension: "tiff")

    /// `bundle.url(forResource: "Poly", withExtension: "geojson")`
    static func polyGeojson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.polyGeojson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "amplifyconfiguration", withExtension: "json")`
    static func amplifyconfigurationJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.amplifyconfigurationJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "apple-app-site-association", withExtension: "")`
    static func appleAppSiteAssociation(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.appleAppSiteAssociation
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "awsconfiguration", withExtension: "json")`
    static func awsconfigurationJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.awsconfigurationJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "underwear", withExtension: "tiff")`
    static func underwearTiff(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.underwearTiff
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 9 images.
  struct image {
    /// Image `LaunchImage`.
    static let launchImage = Rswift.ImageResource(bundle: R.hostingBundle, name: "LaunchImage")
    /// Image `bubble`.
    static let bubble = Rswift.ImageResource(bundle: R.hostingBundle, name: "bubble")
    /// Image `eileen`.
    static let eileen = Rswift.ImageResource(bundle: R.hostingBundle, name: "eileen")
    /// Image `graph`.
    static let graph = Rswift.ImageResource(bundle: R.hostingBundle, name: "graph")
    /// Image `mila`.
    static let mila = Rswift.ImageResource(bundle: R.hostingBundle, name: "mila")
    /// Image `mimosa_pudica`.
    static let mimosa_pudica = Rswift.ImageResource(bundle: R.hostingBundle, name: "mimosa_pudica")
    /// Image `rainbow`.
    static let rainbow = Rswift.ImageResource(bundle: R.hostingBundle, name: "rainbow")
    /// Image `underwear.tiff`.
    static let underwearTiff = Rswift.ImageResource(bundle: R.hostingBundle, name: "underwear.tiff")
    /// Image `underwear`.
    static let underwear = Rswift.ImageResource(bundle: R.hostingBundle, name: "underwear")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "LaunchImage", bundle: ..., traitCollection: ...)`
    static func launchImage(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.launchImage, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "bubble", bundle: ..., traitCollection: ...)`
    static func bubble(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bubble, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "eileen", bundle: ..., traitCollection: ...)`
    static func eileen(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.eileen, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "graph", bundle: ..., traitCollection: ...)`
    static func graph(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.graph, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "mila", bundle: ..., traitCollection: ...)`
    static func mila(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mila, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "mimosa_pudica", bundle: ..., traitCollection: ...)`
    static func mimosa_pudica(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mimosa_pudica, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "rainbow", bundle: ..., traitCollection: ...)`
    static func rainbow(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.rainbow, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "underwear", bundle: ..., traitCollection: ...)`
    static func underwear(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.underwear, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "underwear.tiff", bundle: ..., traitCollection: ...)`
    static func underwearTiff(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.underwearTiff, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.info` struct is generated, and contains static references to 1 properties.
  struct info {
    struct uiApplicationSceneManifest {
      static let _key = "UIApplicationSceneManifest"
      static let uiApplicationSupportsMultipleScenes = false

      struct uiSceneConfigurations {
        static let _key = "UISceneConfigurations"

        struct uiWindowSceneSessionRoleApplication {
          struct defaultConfiguration {
            static let _key = "Default Configuration"
            static let uiSceneConfigurationName = infoPlistString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication", "Default Configuration"], key: "UISceneConfigurationName") ?? "Default Configuration"
            static let uiSceneDelegateClassName = infoPlistString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication", "Default Configuration"], key: "UISceneDelegateClassName") ?? "$(PRODUCT_MODULE_NAME).SceneDelegate"

            fileprivate init() {}
          }

          fileprivate init() {}
        }

        fileprivate init() {}
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
