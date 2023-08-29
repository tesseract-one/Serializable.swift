Pod::Spec.new do |s|
  s.name             = 'Serializable.swift'
  s.version          = '999.99.9'
  s.summary          = 'Dynamic Serializable Value for Swift Codable'

  s.description      = <<-DESC
Dynamic Serializable Value for Swift Codable. Allows encoding and decoding with Dictionary/Array types.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/Serializable.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/Serializable.swift.git', :tag => s.version.to_s }

  s.swift_version    = '5.4'

  base_platforms     = { :ios => '11.0', :osx => '10.13', :tvos => '11.0' }
  s.platforms        = base_platforms.merge({ :watchos => '6.0' })
  
  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.module_name = 'Serializable'

  s.source_files = 'Sources/Serializable/**/*.swift'
  
  s.test_spec 'Tests' do |ts|
    ts.platforms = base_platforms
    ts.source_files = 'Tests/SerializableTests/**/*.swift'
  end
end
