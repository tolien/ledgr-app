class UsersController < ApplicationController
  # GET /1
  # GET /1.json
  def show
    @user = User.find(params[:id])
    if (@user.pages.size > 0)
      @page = @user.pages.first
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end
end
