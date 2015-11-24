require 'open-uri'
class VisitorsController < ApplicationController
  include Magick
  def index
    if session[:user_id]
      image = Magick::ImageList.new
      url_image = open(session[:user_info]['info']['image']) # Image Remote URL

      image.from_blob(url_image.read)
      url_image_width =  image.columns
      url_image_height = image.rows

      overlay_path = Rails.root.join("app/assets/images/check.png")
      overlay = Magick::Image.read(overlay_path).first
      test = overlay.resize_to_fit(url_image_width , url_image_height )
      image.composite!(test, Magick::CenterGravity, Magick::OverCompositeOp)
      image_name = session[:user_id]
      image.change_geometry!("800X800") { |cols, rows| image.thumbnail! cols, rows }
      image.write("public/image/#{image_name}.png")


      name = session[:user_info]['info']['name']
      # name = "sus"

      user_name = name.strip.split(/\s+/)[0]

      overlay_path = Rails.root.join("public/image/#{image_name}.png")
      overlay = Magick::Image.read(overlay_path).first
      title = Magick::Draw.new
      if user_name.length <= 7
        title.annotate(overlay, 0,0,0,-320, user_name) {
          self.font_family = 'Helvetica'
          self.fill = 'white'
          self.pointsize = 100
          self.gravity = CenterGravity
        }
      else
        title.annotate(overlay, 0,0,0,-320, user_name) {
        self.font_family = 'Helvetica'
        self.fill = 'white'
        self.pointsize = 100
        self.gravity = CenterGravity
      }
      end
      img = overlay.write("public/image/#{image_name}.png")
    end
  end

  def store
    @access_token = session[:user_info]['credentials']['token']
    @graph_api = Koala::Facebook::API.new(@access_token)
    begin
      sus = @graph_api.put_picture("#{Rails.root}/public/image/#{session[:user_id]}.png", '', {:message => "Vote for @Maggie Doyne Everyday @ www.heroes.cnn.com \n Visit http://fuitter.com to show your support"}, "me")
    rescue => e
      return redirect_to root_url, :alert => "Sorry, something went wrong. Make sure You have accepted our every permission"
    end
    link_to_facebook = "https://www.facebook.com/photo.php?fbid=#{sus["id"]}&makeprofile=1"

    redirect_to link_to_facebook
  end
end
