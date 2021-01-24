# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'Todoey' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Todoey

 # pod 'ChameleonFramework/Swift','2.3.0', :git => 'https://github.com/ViccAlexander/Chameleon.git'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
end
