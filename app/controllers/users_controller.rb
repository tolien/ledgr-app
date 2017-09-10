class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  # GET /1
  # GET /1.json
  def show
    @user = User.friendly.find(params[:id])
    if @user.pages.size > 0 
      @page = @user.pages.first
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end
  
  def settings
    @user = User.friendly.find(params[:id])
    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not access someone else's settings"
      return
    end
  end
  
  def export_data
    user = User.friendly.find(params[:id])
    unless not current_user.nil? and current_user.id == user.id
      render status: :forbidden, body: "You may not export someone else's data"
      return
    end
    
    export = Exporter.new
    csv = export.export(user.id)
    
    send_data csv, {type: :csv, filename: "#{user.username}.csv"}
  end
end
