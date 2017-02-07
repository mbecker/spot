# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Spot' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Spot
  pod 'AsyncDisplayKit', :git => 'https://github.com/facebook/AsyncDisplayKit'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'Kingfisher', '~> 3.0'
  pod 'NVActivityIndicatorView'
  pod 'ImageSlideshow', '~> 1.0.0-beta.1'
  pod 'MapboxStatic.swift', :git => 'https://github.com/mapbox/MapboxStatic.swift.git', :branch => 'swift-3'
  pod 'SMSegmentView', :git => 'https://github.com/sima-11/SMSegmentView.git'
  pod 'EZAlertController', '3.2'
  pod 'ImagePicker'
  pod 'TOCropViewController', '~> 2.0'
  pod 'PMAlertController'
  pod 'Down'
  pod 'SwiftMessages'
  pod 'EasyAnimation'

  target 'SpotTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SpotUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
