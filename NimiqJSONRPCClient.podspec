Pod::Spec.new do |s|
  s.name         = "NimiqJSONRPCClient"
  s.version      = "0.0.1"
  s.summary      = "Nimiq JSONRPC Client."
  s.homepage     = "https://github.com/rraallvv/NimiqJSONRPCClient"
  s.license      = "MIT"
  s.author       = { "Rhody Lugo" => "rhodylugo@gmail.com" }
  s.swift_version = "5.2.4"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/rraallvv/NimiqJSONRPCClient.git", :tag => s.version }
  s.source_files = "Sources/*.swift"
end
