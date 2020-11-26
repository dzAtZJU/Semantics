# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Semantics' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Dosc: https://docs.mongodb.com/realm/
  # Practices: https://docs.realm.io/sync/additional-resources/how-to-build-an-app-with-realm-sync
  # Error: https://docs.realm.io/sync/using-synced-realms/errors
  # Reference: https://docs.mongodb.com/realm-sdks/objc/latest
  # Changelog: https://github.com/realm/realm-cocoa/blob/v10.0.0-beta.4/CHANGELOG.md
  
  # https://docs.mongodb.com/realm/mongodb
  # https://docs.mongodb.com/realm/tutorial/ios-swift/
  
  pod 'RealmSwift', '>= 10.0.0-rc.1'

  pod 'Presentr'
  
  pod 'TagListView', '~> 1.0'
  
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '6.0.0'
  
  pod 'ResearchKit', '>= 2.0.0'
  
#  pod 'Jelly', '~> 2.2.2'
  
#  pod 'Iconic', :git => 'https://github.com/home-assistant/Iconic.git'
  
  # https://www.highcharts.com/ios/demo
  # https://api.highcharts.com/ios/highcharts/
#  pod 'Highcharts', '~> 8.1.2'

  target 'SemanticsTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
