xcodeproj 'DemoClient/DemoClient.xcodeproj'

platform :osx, '10.8'

target :DemoClientTests, :exclusive => true do
    xcodeproj 'DemoClient/DemoClient.xcodeproj'
    platform :osx, '10.8'
    link_with 'DemoClientTests'
    
    pod 'SenTestingKitAsync', :podspec => 'SenTestingKitAsync.podspec'
    pod 'OCMock', '~> 2.0'
end
