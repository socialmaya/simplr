class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.authenticate(params[:login], params[:password])
    if @user
      @user.update_token if @user.auth_token.nil?
      if params[:remember_me]
        cookies.permanent[:auth_token] = @user.auth_token
      else
        cookies[:auth_token] = @user.auth_token
      end
      cookies.permanent[:logged_in_before] = true
      redirect_to root_url
    else
      flash[:error] = "Invalid email or password"
      redirect_to :back
    end
  end
  
  def destroy
    current_user.update_token
    cookies.delete(:auth_token)
    flash[:notice] = "Log out successful."
    redirect_to root_url
  end
end
