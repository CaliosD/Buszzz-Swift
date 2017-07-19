platform:ios, '8.0'
use_frameworks!

target 'Buszzz' do

#pod 'TextFieldEffects'
pod 'RealmSwift', '~>2.4.4'
pod 'SVProgressHUD', '~>2.1.2'
pod 'DZNEmptyDataSet', '~>1.8.1'
pod 'TGPControls', '~>3.0.0'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
