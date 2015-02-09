class PagesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]

  # GET /pages/1
  # GET /pages/1.json
  def show
    @user = User.find(params[:user_id])
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @user = User.find(params[:user_id])
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @user = User.find(params[:user_id])
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @user = User.find(params[:user_id])
    @page = Page.new(params[:page])

    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create pages for someone else"
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
    @user = User.find(params[:user_id])
    @page = Page.find(params[:id])

    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create pages for someone else"
      return
    end

    respond_to do |format|
      if @page.update_attributes(params[:page])
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
      render status: :forbidden, text: "You may not create pages for someone else"
      return
    end
    @page.destroy

    respond_to do |format|
      format.html { redirect_to user_url }
      format.json { head :no_content }
    end
  end
end
