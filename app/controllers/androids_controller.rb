class AndroidsController < ApplicationController
 def create
  system('cordova create hello')
  
  render nothing: true
 end
end
