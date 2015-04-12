class AndroidsController < ApplicationController
 def create
  www_zip_file_data = params[:filedata].path
  folder_name = Digest::MD5.hexdigest(Time.now.to_s)
  system("cd ~/appcreator_apps && cordova create #{folder_name}")
  # system("cd ~/appcreator_apps/#{folder_name} && cordova platform add android && cordova plugin add org.apache.cordova.device && cordova plugin add org.apache.cordova.console")
  
  #system("rm -rf ~/appcreator_apps/#{folder_name}/www")
  system("cd ~/appcreator_apps/#{folder_name}")
Zip::ZipFile.open(www_zip_file_data) { |zip_file|
   zip_file.each { |f|
   f_path=File.join("/home/devops/appcreator_apps/#{folder_name}", f.name)
   logger.info f_path
   logger.info '-----------------------------------'
   logger.info f
   logger.info '-----------------------------------'
   FileUtils.mkdir_p(File.dirname(f_path))
   zip_file.extract(f, f_path) true
 }
}
  # system("cd ~/appcreator_apps/#{folder_name} && cordova build android")
  
  render json: {apk_path: "~/appcreator_apps/#{folder_name}/platforms/android/ant-build/MainActivity-debug.apk"}
 end
end
