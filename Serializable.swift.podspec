Pod::Spec.new do |s|
  s.name             = 'Serializable.swift'
  s.version          = '0.1.0'
  s.summary          = 'Dynamic Serializable Value for Swift Codable'

  s.description      = <<-DESC
Dynamic Serializable Value for Swift Codable. Allows encoding and decoding with Dictionary/Array types.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/Serializable.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/Serializable.swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  
  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.module_name = 'Serializable'

  s.source_files = 'Sources/Serializable/**/*.swift'
end
