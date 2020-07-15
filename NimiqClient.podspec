Pod::Spec.new do |s|
  s.name         = "NimiqClient"
  s.version      = "0.0.1"
  s.summary      = "Nimiq JSONRPC Client."
  s.homepage     = "https://github.com/rraallvv/NimiqClient"
  s.license      = "MIT"
  s.author       = { "Rhody Lugo" => "rhodylugo@gmail.com" }
  s.swift_version = "5.2.4"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/rraallvv/NimiqClient.git", :tag => s.version }
  s.source_files = "Sources/*.swift"
end
