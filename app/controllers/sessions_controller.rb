class SessionsController < ApplicationController
  def create
    user = User.find_or_create_by(account_id: auth_hash.uid)
    user.access_token = auth_hash.credentials.token
    user.save!
    session['user'] = user

    flash[:installed] = true
    redirect_to root_path
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
