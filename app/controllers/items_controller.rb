class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    @user = User.find(params[:user_id])
    @items = @user.items

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
    @user = User.find(params[:user_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @user = User.find(params[:user_id])
    @item = @user.items.build

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
    @item = Item.new(params[:item])
    @user = User.find(params[:user_id])
    @item.user = @user

    respond_to do |format|
      if @item.save
        format.html { redirect_to [@user, @item], notice: 'Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
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
    @item.destroy

    respond_to do |format|
      format.html { redirect_to user_items_url }
      format.json { head :no_content }
    end
  end
end
