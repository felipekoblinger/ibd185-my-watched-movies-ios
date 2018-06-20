# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'MyWatchedMovies' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  post_install do |installer|
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end

  # Pods for MyWatchedMovies
  pod 'CoreStore'
  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'Moya', '~> 11.0'
  pod 'Moya-Argo'
  pod 'PromiseKit', '~> 6.0'
  # Extracting Models
  pod 'Argo'
  pod 'Curry'
  pod 'Runes'
  # Forms
  pod 'Cosmos', '~> 16.0'
  # Images
  pod 'Kingfisher', '~> 4.0'
  # Keychain
  pod 'KeychainAccess'
  # JWT
  pod 'JWTDecode', '~> 2.1'
  # Validation
  pod 'SwiftValidator', git: 'https://github.com/jpotts18/SwiftValidator.git', branch: 'master'
  # UI
  pod 'CFNotify'
  pod 'TransitionButton'
  pod 'StatusAlert', git: "https://github.com/LowKostKustomz/StatusAlert"
  pod 'HGPlaceholders'
  pod 'UIEmptyState'
  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'Charts'
  pod 'PopupDialog', '~> 0.7'
  pod 'SkeletonView'
end
