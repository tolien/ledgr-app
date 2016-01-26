class CategoriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  # GET /categories
  # GET /categories.json
  def index
    @user = User.friendly.find(params[:user_id])
    @categories = @user.categories.order("name asc").includes(:items, :user)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @category = Category.find(params[:id])
    @user = User.friendly.find(params[:user_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.json
  def new
    @user = User.friendly.find(params[:user_id])
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create categories for someone else"
      return
    end
    
    @category = @user.categories.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    @user = @category.user
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    @user = User.friendly.find(params[:user_id])
    
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create categories for someone else"
      return
    end
          
    @category.user_id = @user.id

    respond_to do |format|
      if @category.save
        format.html { redirect_to user_category_path(@category.user.id, @category.id), notice: 'Category was successfully created.' }
        format.json { render json: @category, status: :created, location: @category }
      else
        format.html { render action: "new" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    @category = Category.find(params[:id])
    @user = @category.user
    
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not update a category belonging to someone else"
      return
    end
    
    unless params[:category][:user_id].nil?
      params[:category][:user_id] = @user.id
    end
    
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to user_category_path(@category.user, @category), notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category = Category.find(params[:id])
    user = @category.user
    unless current_user.id == user.id
      render status: :forbidden, text: "You don't own this category!"
      return
    end
    @category.destroy

    respond_to do |format|
      format.html { redirect_to user_categories_url }
      format.json { head :no_content }
    end
  end
  
  private
  
  def category_params
    params.require(:category).permit(:name, :user_id)
  end
end
