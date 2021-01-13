use_frameworks!

workspace 'Semantics'

project 'Semantics/Semantics'

project 'GDAL-Demo/GDAL-Demo'

target 'Semantics' do
    project 'Semantics/Semantics'
    # support https://docs.mapbox.com/help/troubleshooting/implementation-support/#ask-the-mapbox-community-on-stack-overflow
    # style https://docs.mapbox.com/mapbox-gl-js/style-spec/
    # tilejson https://github.com/mapbox/tilejson-spec/tree/master/2.2.0
    # tiled web map https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    # geojson https://tools.ietf.org/html/rfc7946#section-4
    # geotiff https://rasterio.readthedocs.io/en/latest/intro.html
    # vector tile source https://docs.mapbox.com/vector-tiles/reference/mapbox-streets-v8
    # studio https://docs.mapbox.com/studio-manual/reference/
    # design in studio https://studio.mapbox.com/
    # ios https://docs.mapbox.com/ios/maps/guides/
    # api https://docs.mapbox.com/ios/maps/api/6.2.1/working-with-geojson-data.html
    # predicate https://docs.mapbox.com/ios/maps/api/6.2.1/predicates-and-expressions.html
    # glossary: https://docs.mapbox.com/help/glossary/
    # https://docs.mapbox.com/help/how-mapbox-works/
    # https://geojson.org/
    # landscape http://www.geopackage.org/implementations.html
    pod 'Mapbox-iOS-SDK', '~> 6.3.0'
    
    # Doc: https://docs.mongodb.com/realm/
    #       https://realm.io/docs/swift/latest
    
    # Practices: https://docs.realm.io/sync/additional-resources/how-to-build-an-app-with-realm-sync
    # Error: https://docs.realm.io/sync/using-synced-realms/errors
    
    # Reference: https://docs.mongodb.com/realm-sdks/objc/latest
    #            https://realm.io/docs/swift/latest/api/
    
    # Changelog: https://github.com/realm/realm-cocoa/blob/v10.0.0-beta.4/CHANGELOG.md
    
    # https://docs.mongodb.com/realm/mongodb
    # https://docs.mongodb.com/realm/tutorial/ios-swift/
    pod 'SemRealm', :path => '/Users/zhouweiran/SemRealm'
    
    pod 'Presentr'
    
    pod 'TagListView', '~> 1.0'
    
    # Doc https://docs.sentry.io/platforms/apple/guides/ios
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '6.0.0'
    
    pod 'ResearchKit', :git => 'https://github.com/ResearchKit/ResearchKit', :branch => 'master'
    
    #  pod 'Jelly', '~> 2.2.2'
    
    #  pod 'Iconic', :git => 'https://github.com/home-assistant/Iconic.git'
    
    # http://reactivex.io/documentation/operators.html
    pod 'libpng', '~> 1.6'    
    pod 'R.swift'
    
    # Integration: https://docs.amplify.aws/lib/project-setup/create-application/q/platform/ios
    pod 'Amplify'
    # Integration: https://docs.amplify.aws/lib/storage/getting-started/q/platform/ios
    pod 'AmplifyPlugins/AWSS3StoragePlugin'
    pod 'AmplifyPlugins/AWSCognitoAuthPlugin'
end

target 'SemanticsTests' do
    project 'Semantics/Semantics'
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
    pod 'AmplifyPlugins/AWSS3StoragePlugin'
    pod 'AmplifyPlugins/AWSCognitoAuthPlugin'
end



target 'GDAL' do
    project 'GDAL-Demo/GDAL-Demo'
    pod 'libpng', '~> 1.6'
end

target 'Demo-GDAL' do
    project 'GDAL-Demo/GDAL-Demo'
    pod 'libpng', '~> 1.6'
end
