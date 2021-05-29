class DisplaysController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def show
    @user = User.friendly.find(params[:user_id])
    @display = Display.find(params[:id])

    unless @display.should_show_for? current_user
      render status: :forbidden
      return
    end
  
    respond_to do |format|
      format.html { render @display }
      format.json { render json: @display.get_data.to_json }
    end
  end

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
      render status: :forbidden, body: "You don't own this display!"
      return
    end

    @display.destroy

    head :ok
  end
end
