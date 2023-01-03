Pod::Spec.new do |spec|
  spec.name = 'StringTemplate'
  spec.version = '2.2.0'
  spec.license = 'Apache License, Version 2.0'
  spec.homepage = 'https://github.com/square/StringTemplate'
  spec.authors = 'Square'
  spec.summary = 'String templating for Swift made easy.'
  spec.source = { :git => 'https://github.com/square/StringTemplate.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Sources/*.swift'
  spec.swift_versions = ['4.0', '5.0']

  spec.requires_arc = true
  spec.compiler_flags = '-whole-module-optimization'

  spec.ios.deployment_target = '11.0'
  spec.osx.deployment_target = '10.13'
  spec.watchos.deployment_target = '4.0'
  spec.tvos.deployment_target = '11.0'

  spec.pod_target_xcconfig = {
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
  }
end
