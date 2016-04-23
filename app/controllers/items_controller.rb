class ItemsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  # GET /items
  # GET /items.json
  def index
    @user = User.find(params[:user_id])
    @items = @user.items.includes(:categories)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
    @user = User.find(params[:user_id])
    @item_entries = @item.entries.order("datetime desc").paginate(page: params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @user = User.find(params[:user_id])
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create items for someone else"
      return
    end
    @item = @user.items.build
    @category_id = params[:category_id]
    unless @category_id.nil?
      Rails.logger.info("Category ID: " + @category_id)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
    @user = User.find(params[:user_id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(name: params[:item][:name], user_id: User.find(params[:user_id]).id)
    @user = User.find(params[:user_id])
    @item.user = @user
    
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create items for someone else"
      return
    end

    respond_to do |format|
      if @item.save
        category_id = params[:item][:category_id]
        if(!category_id.nil? and category_id.length > 0)
          category = Category.where('id = ? and user_id = ?', category_id.to_i, @user.id).first
          unless category.nil?
            Rails.logger.info("Category ID: #{category.id}")
            @item.add_category(category)
          
            @item.save
            format.html { redirect_to user_category_url(@user.id, category) }
          end
        end
        format.html { redirect_to user_items_url(@user.id) }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])
    @user = @item.user
    
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not update an item belonging to someone else"
      return
    end

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to user_item_path(@user.id, @item.id), notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    unless current_user.id == @item.user.id
      render status: :forbidden, text: "You don't own this item!"
      return
    end
    @item.destroy

    respond_to do |format|
      format.html { redirect_to user_items_url }
      format.json { head :no_content }
    end
  end
end
