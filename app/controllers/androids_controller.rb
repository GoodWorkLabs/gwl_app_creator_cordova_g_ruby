class AndroidsController < ApplicationController
  def create
    www_zip_file_data = params[:filedata].path
    icons_zip_file_data = params[:icondata].path
    app_name = params[:appname]
    folder_name = Digest::MD5.hexdigest(Time.now.to_s)
    system("cd /home/devops/appcreator_apps && cordova create #{folder_name} com.goodappz.#{app_name} #{app_name}")
    system("cd /home/devops/appcreator_apps/#{folder_name} && cordova platform add android && cordova plugin add org.apache.cordova.device && cordova plugin add org.apache.cordova.console && cordova plugin add https://github.com/phonegap-build/PushPlugin.git && cordova plugin add org.apache.cordova.network-information")
    system("chmod 777 /home/devops/appcreator_apps/#{folder_name}")
    
    system("cd /home/devops/appcreator_apps/#{folder_name}")
    # copy www content to android assets
    Zip::ZipFile.open(www_zip_file_data) { |zip_file|
      zip_file.each { |f|
        f_path=File.join("/home/devops/appcreator_apps/#{folder_name}", f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) {true}
      }
    }
    
    system("cd /home/devops/appcreator_apps/#{folder_name}")
    # Copy icons to correct folders
    Zip::ZipFile.open(icons_zip_file_data) { |zip_file|
      zip_file.each { |f|
        f_path=File.join("/home/devops/appcreator_apps/#{folder_name}/platforms/android/res", f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) {true}
      }
    }
 
    logger.info(system("ls /home/devops/appcreator_apps/#{folder_name}"))
    logger.info(system("cat /home/devops/appcreator_apps/#{folder_name}/config.xml"))
    # Change config.xml stuffs for call button support
    file_name = "/home/devops/appcreator_apps/#{folder_name}/config.xml"
    xml_val = File.read(file_name)
    new_contents = xml_val.gsub('</widget>', '<access origin="tel:*" launch-external="yes" /><access origin="mailto:*" launch-external="yes" /></widget>')
    # To write changes to the file, use:
    File.open(file_name, "w") {|file| file.puts new_contents }
    
    system("cd /home/devops/appcreator_apps/#{folder_name} && cordova build android")
  
    # render json: {apk_path: "/home/devops/appcreator_apps/#{folder_name}/platforms/android/ant-build/MainActivity-debug.apk"}
    render json: {apk_path: "http://apks.goodappz.com/#{folder_name}/platforms/android/ant-build/MainActivity-debug.apk"}
  end
end
