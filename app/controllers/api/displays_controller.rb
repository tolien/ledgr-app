class Api::DisplaysController < ApplicationController
  before_action :doorkeeper_authorize!

  def show
    @user = User.friendly.find(params[:user_id])
    @display = Display.find(params[:id])

    unless @display.should_show_for? current_resource_owner
      render status: :forbidden
      return
    end

    respond_to do |format|
      format.json { render json: @display.get_data.to_json }
    end
  end

  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
