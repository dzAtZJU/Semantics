import Foundation
import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestAppDelegate") ?? AppDelegate.self
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass))
