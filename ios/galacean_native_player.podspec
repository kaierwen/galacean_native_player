#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint galacean_native_player.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'galacean_native_player'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Galacean Effects Native Player.'
  s.description      = <<-DESC
A Flutter plugin for playing Galacean Effects animations on iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/kaierwen/galacean_native_player'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kaierwen' => 'kaierwen@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SSZipArchive', '~> 2.4'
  s.platform = :ios, '12.0'

  # Galacean Effects SDK framework
  s.vendored_frameworks = 'GalaceanEffects.framework'
  
  # System frameworks required by GalaceanEffects
  s.frameworks = 'AVFoundation', 'CoreMedia', 'CoreVideo', 'OpenGLES', 'GLKit', 'Metal', 'MetalKit', 'QuartzCore', 'UIKit', 'Foundation'
  
  # System libraries required for ZIP decompression
  s.libraries = 'z', 'c++'
  
  # Framework search paths
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/../.symlinks/plugins/galacean_native_player/ios"'
  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'galacean_native_player_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
