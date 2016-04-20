class AutocompleteController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @user = current_user
    name = params[:term]
    @items = @user.items.where('name like :name', {name: "%#{name}%"}).reorder(entries_count: :desc).pluck(:name)

    respond_to do |format|
      format.json
    end
  end
end