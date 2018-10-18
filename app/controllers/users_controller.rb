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

  def upload_for_import
    uploaded_io = params[:data]
    user = User.friendly.find(params[:id])
    
    unless current_user.id == user.id
      render status: :forbidden, body: "You may not import data into someone else's account"
    end

    unless uploaded_io.nil?
      tempfile = Rails.root.join('tmp', 'pending_imports', SecureRandom.urlsafe_base64(12) + '.csv')
      unless Dir.exist? tempfile.dirname
          tempfile.dirname.mkpath
      end
      file = File.new(tempfile, 'wb')
      file.write(uploaded_io.read)
      file.close
      DaytumImportJob.perform_later user.id, file.path, true
    end
  end
end
