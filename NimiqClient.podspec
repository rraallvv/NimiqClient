Pod::Spec.new do |s|
  s.name         = "NimiqClient"
  s.version      = "0.0.1"
  s.summary      = "Nimiq JSONRPC Client."
  s.homepage     = "https://github.com/rraallvv/NimiqClientSwift"
  s.license      = "MIT"
  s.author       = { "Nimiq Comunity" => "info@nimiq.com" }
  s.swift_version = "5.2.4"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.6"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/rraallvv/NimiqClientSwift.git", :tag => s.version }
  s.source_files = "Sources/*.swift"
end
