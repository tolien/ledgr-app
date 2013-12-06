class UsersController < ApplicationController
  # GET /1
  # GET /1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end
end
