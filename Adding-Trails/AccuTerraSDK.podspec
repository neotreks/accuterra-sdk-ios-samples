Pod::Spec.new do |m|

  version = '0.1.15967'

  m.name    = 'AccuTerraSDK'
  m.version = version

  m.summary           = 'AccuTerra iOS SDK.'
  m.description       = 'AccuTerra iOS SDK with map and trails features.'
  m.homepage          = 'https://sdk.accuterra.com/'
  m.author            = { 'NeoTreks' => 'info@neotreks.com' }
  m.documentation_url = 'https://sdk.accuterra.com/'

  m.source = {
    :path => "SDK/AccuTerraSDK.framework",
    :flatten => true
  }

  m.platform              = :ios
  m.ios.deployment_target = '10.0'

  m.dependency 'Alamofire', '~> 4.9.0'
  m.dependency 'AlamofireObjectMapper', '~> 5.2.0'
  m.dependency 'ObjectMapper', '~> 3.4.2'
  m.dependency 'ReachabilitySwift', '~> 4.3.1'
  m.dependency 'GRDB.swift', '~> 4.7.0'
  m.dependency 'AccuTerra-Mapbox-iOS-SDK', '5.7.0.5'
  m.dependency 'GzipSwift', '~> 5.1.1'
  
  # AWS
  $awsVersion = '~> 2.12.3'
  m.dependency 'AWSMobileClient', $awsVersion
  m.dependency 'AWSCore', $awsVersion
  m.dependency 'AWSS3', $awsVersion
  
  m.requires_arc = true

  m.vendored_frameworks = 'SDK/AccuTerraSDK.framework'
  m.module_name = 'AccuTerraSDK'

  m.preserve_path = '**/*.bcsymbolmap'

end
