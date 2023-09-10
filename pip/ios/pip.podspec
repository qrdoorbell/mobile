#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pip.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name                = 'pip'
  s.version             = '0.0.0'
  s.summary             = 'QR Doorbell iOS PiP integration plugin.'
  s.description         = 'QR Doorbell iOS PiP integration plugin.'
  s.homepage            = 'https://qrdoorbell.io'
  s.license             = { :file => '../LICENSE' }
  s.author              = { 'QR Doorbell' => 'info@qrdoorbell.io' }
  s.source              = { :path => '.' }
  s.source_files        = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.platform            = :ios, '16.0'
  s.static_framework    = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version       = '5.0'

  s.dependency 'Flutter'
  s.dependency 'flutter_webrtc', '0.9.36'
end
