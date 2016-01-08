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
      cookies.delete(:token_timestamp)
      redirect_to root_url
    else
      redirect_to :back, notice: "Invalid username, email, or password"
    end
  end
  
  def destroy
    if current_user
      current_user.update_token
      cookies.delete(:auth_token)
      cookies.delete(:token_timestamp)
    end
    redirect_to root_url
  end
end
