class JsController < ApplicationController
  protect_from_forgery except: :show

  def show
    file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'disable-right-click.js')
    @js = Uglifier.new.compile(File.read(file))

    respond_to do |format|
      format.js
    end
  end
end
