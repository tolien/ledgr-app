class QuickEntriesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  def create
    @user = User.friendly.find(params[:user_id])
    
    unless current_user.id == @user.id
      render status: :forbidden, text: "You may not create entries for someone else"
      return
    end
    
    Rails.logger.debug("*** Quick entry for user #{@user.username} ***")
    Rails.logger.debug("Item name: #{params[:item_name]}")
    Rails.logger.debug("Quantity: #{params[:quantity].to_f}")
    Rails.logger.debug("Datetime: #{params[:datetime]}")
    @entry = Entry.new()
    @entry.item = Item.find_or_create_by(user_id: @user.id, name: params[:item_name])
    @entry.datetime = params[:datetime]
    unless params[:quantity].nil?
      @entry.quantity = params[:quantity].to_f
      else
        @entry.quantity = 1.0
      end
      
    respond_to do |format|
      if @entry.save
        referer = request.headers['Referer']
        Rails.logger.debug("Referrer: #{referer}")

        format.html { redirect_to (user_entry_path(@user.id, @entry.id)), notice: 'Entry was successfully created.' }
        format.json { render json: @entry, status: :created, location: @entry }
      else
        format.html { render action: "new" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end
end
