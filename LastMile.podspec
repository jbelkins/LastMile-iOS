Pod::Spec.new do |spec|
  spec.name                  = "LastMile"
  spec.version               = "1.0.0"
  spec.summary               = "Decodes data encoded in JSON to Swift objects"
  spec.description           = <<-DESC
    Decodes JSON into objects, with simple, elegant syntax, flexible and resilient parsing, and insightful error reporting.
  DESC
  spec.homepage              = "https://github.com/jbelkins/LastMile-iOS"
  spec.license               = "MIT"
  spec.author                = "Josh Elkins"
  spec.ios.deployment_target = "9.0"
  spec.osx.deployment_target = "10.9"
  spec.swift_version         = "5.0"
  spec.source                = { git: "https://github.com/jbelkins/LastMile-iOS.git", tag: "v#{spec.version}" }
  spec.source_files          = "Sources/LastMile/**/*.swift"
  spec.framework             = "Foundation"
end
