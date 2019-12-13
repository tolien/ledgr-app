class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  # GET /1
  # GET /1.json
  def show
    @user = User.friendly.find(params[:id])
    if @user.pages.size > 0
      for page in @user.pages
        if page.should_show_for? current_user
          @page = page
          break
        end
      end

      if @page.nil?
        render status: :forbidden
        return
      end
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

  def revoke_oauth_token
    user = User.friendly.find(params[:id])
    token_string = params[:token]
    refresh_token_string = params[:refresh_token]
    
    unless current_user.nil? or not current_user.eql? user
      unless token_string.nil? and refresh_token_string.nil?
        token = Doorkeeper::AccessToken.find_by("resource_owner_id = ? AND
          (token = ? OR refresh_token = ?)", user.id, token_string, refresh_token_string)

        unless token.nil?
          token.revoke
        else
         render status: :not_found
        end
      end
    else
      render status: :forbidden, body: nil
    end
  end
end
