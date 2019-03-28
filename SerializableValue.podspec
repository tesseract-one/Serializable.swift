Pod::Spec.new do |s|
  s.name             = 'SerializableValue'
  s.version          = '0.0.1'
  s.summary          = 'Dynamic Serializable Value for Swift Codable'

  s.description      = <<-DESC
Dynamic Serializable Value for Swift Codable. Allows encoding and decoding with Dictionary types.
                       DESC

  s.homepage         = 'https://github.com/tesseract.1/swift-serializable'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract.1/swift-serializable.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_io'

  s.ios.deployment_target = '8.0'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.module_name = 'Serializable'

  s.source_files = 'Sources/Serializable/**/*.swift'
end
