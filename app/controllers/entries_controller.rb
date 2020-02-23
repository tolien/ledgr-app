class EntriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  # GET /entries
  # GET /entries.json
  def index
    @user = User.friendly.find(params[:user_id])

    if @user.is_private
      if current_user.nil?
        redirect_to new_user_session_path
      elsif current_user.id != @user.id
        render status: :forbidden
      end
    end
    @entries = @user.entries.includes(item: [:categories]).order("datetime desc").paginate(page: params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
    @user = User.friendly.find(params[:user_id])

    if @user.is_private
      if current_user.nil?
        redirect_to new_user_session_path
      elsif current_user.id != @user.id
        render status: :forbidden
      end
    end

    @entry = Entry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entry }
    end
  end

  # GET /entries/new
  # GET /entries/new.json
  def new
    @user = User.friendly.find(params[:user_id])

    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not create entries for someone else"
      return
    end

    @entry = Entry.new
    @entry.datetime = DateTime.current

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entry }
    end
  end

  # GET /entries/1/edit
  def edit
    @user = User.friendly.find(params[:user_id])
    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not edit entries for someone else"
      return
    end

    @entry = Entry.find(params[:id])
  end

  # POST /entries
  # POST /entries.json
  def create
    @user = User.find(params[:user_id])

    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not create entries for someone else"
      return
    end

    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to (user_entry_path(@user.id, @entry.id)), notice: "Entry was successfully created." }
        format.json { render json: @entry, status: :created, location: @entry }
      else
        format.html { render action: "new" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.json
  def update
    @user = User.friendly.find(params[:user_id])
    @entry = Entry.find(params[:id])

    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not update an entry belonging to someone else"
      return
    end

    respond_to do |format|
      if @entry.update!(entry_params)
        format.html { redirect_to (user_entry_path(@user.id, @entry)), notice: "Entry was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @user = User.friendly.find(params[:user_id])
    @entry = Entry.find(params[:id])

    unless current_user.id == @entry.item.user_id
      render status: :forbidden, body: "You don't own this entries!"
      return
    end
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to user_entries_url(@user.id) }
      format.js
      format.json { head :no_content }
    end
  end

  private

  def entry_params
    params.require(:entry).permit(:item_id, :quantity, :datetime)
  end
end
