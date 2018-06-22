class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  # GET /pages/1
  # GET /pages/1.json
  def show
    @user = User.friendly.find(params[:user_id])
    @page = Page.find(params[:id])

    unless @page.should_show_for? current_user
      render status: :forbidden
      return
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @user = User.friendly.find(params[:user_id])
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @user = User.friendly.find(params[:user_id])
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @user = User.friendly.find(params[:user_id])
    @page = Page.new(page_params)

    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not create pages for someone else"
      return
    end

    respond_to do |format|
      if @page.save
        format.html { redirect_to user_page_url(@user, @page), notice: 'Page was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @user = User.friendly.find(params[:user_id])
    @page = Page.find(params[:id])

    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not create pages for someone else"
      return
    end

    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to user_page_url(@user, @page), notice: 'Page was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])

    unless current_user.id == @page.user.id
      render status: :forbidden, body: "You may not create pages for someone else"
      return
    end
    @page.destroy

    respond_to do |format|
      format.html { redirect_to user_url }
      format.json { head :no_content }
    end
  end
  
  private
  
  def page_params
    params.require(:page).permit(:title, :user_id)
  end
end
