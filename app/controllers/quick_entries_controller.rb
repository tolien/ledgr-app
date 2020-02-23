class QuickEntriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def create
    @user = User.friendly.find(params[:user_id])

    unless current_user.id == @user.id
      render status: :forbidden, body: "You may not create entries for someone else"
      return
    end

    Rails.logger.debug("*** Quick entry for user #{@user.username} ***")
    Rails.logger.debug("Item name: #{params[:item_name]}")
    Rails.logger.debug("Quantity: #{params[:quantity].to_f}")
    Rails.logger.debug("Datetime: #{params[:datetime]}")
    @entry = Entry.new()

    item = Item.where("user_id = ? AND lower(name) = ?", @user.id, params[:item_name].downcase).first_or_create(user_id: @user.id, name: params[:item_name])
    item.save!
    @entry.item = item

    @entry.datetime = params[:datetime]
    unless params[:quantity].nil?
      @entry.quantity = params[:quantity].to_f
    else
      @entry.quantity = 1.0
    end

    respond_to do |format|
      if @entry.save
        referer = request.headers["Referer"]
        Rails.logger.debug("Referrer: #{referer}")

        format.html { redirect_to (user_entry_path(@user.id, @entry.id)), notice: "Entry was successfully created." }
      else
        format.html { render nothing: true, status: :not_acceptable }
      end
    end
  end
end
