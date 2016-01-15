class DisplaysController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]

  def edit
    @user = User.find(params[:user_id])
  end

  def create
    @user = User.find(params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])
  end

  def destroy
    @user = User.find(params[:user_id])
    @display = Display.find(params[:id])
    
    unless current_user.id == @display.page.user_id
      render status: :forbidden, text: "You don't own this entries!"
      return
    end
    
    @display.destroy
    
    render nothing: true
  end
end
