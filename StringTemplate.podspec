Pod::Spec.new do |spec|
  spec.name = 'StringTemplate'
  spec.version = '2.0.0'
  spec.license = 'Apache License, Version 2.0'
  spec.homepage = 'https://github.com/square/StringTemplate'
  spec.authors = 'Square'
  spec.summary = 'String templating for Swift made easy.'
  spec.source = { :git => 'https://github.com/square/StringTemplate.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Sources/*.swift'
  spec.swift_version = '4.0'

  spec.requires_arc = true
  spec.compiler_flags = '-whole-module-optimization'
  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = '9.0'
end
