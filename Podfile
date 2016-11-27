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
  pod 'Kingfisher', '~> 3.0'
  pod 'MXParallaxHeader'

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
