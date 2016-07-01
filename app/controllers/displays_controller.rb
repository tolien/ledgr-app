class DisplaysController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def edit
    @user = User.friendly.find(params[:user_id])
  end

  def create
    @user = User.friendly.find(params[:user_id])
  end

  def update
    @user = User.friendly.find(params[:user_id])
  end

  def destroy
    @user = User.friendly.find(params[:user_id])
    @display = Display.find(params[:id])
    
    unless current_user.id == @display.page.user_id
      render status: :forbidden, body: "You don't own this entries!"
      return
    end
    
    @display.destroy
    
    head :ok
  end
end
