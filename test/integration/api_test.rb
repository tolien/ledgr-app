require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  fixtures :all
    
  def sign_in(user, password)
    post user_session_path, params: { user: {username: user.username, password: password} }
    follow_redirect!
  end
    
  def setup
    @user_one = FactoryBot.create(:user, password: 'password', password_confirmation: 'password')
    @user_two = FactoryBot.create(:user, password: 'password', password_confirmation: 'password')
    @category = FactoryBot.create(:category, user: @user_one)
    @item = FactoryBot.create(:item, user: @user_one, categories: [@category])

    @page_one = FactoryBot.create(:page, user: @user_one)
    @page_two = FactoryBot.create(:page, user: @user_one)

    @display = FactoryBot.create(:display, page: @page_one, is_private: :true)
    @display_type = DisplayTypes::StreamGraph.first
    if @display_type.nil?
      @display_type = DisplayTypes::StreamGraph.new
      @display_type.name = 'Streamgraph'
      @display_type.save!
    end

    @application = Doorkeeper::Application.create(name: 'TestApp', redirect_uri: 'http://localhost:3000')
    @user_one_token = Doorkeeper::AccessToken.create(application_id: @application.id, resource_owner_id: @user_one.id, scopes: 'public')
    @user_two_token = Doorkeeper::AccessToken.create(application_id: @application.id, resource_owner_id: @user_two.id, scopes: 'public')
  end
  
  test "OAuth token controls access to displays" do
    get api_user_display_path(@user_one, @display, format: :json)
    assert_response :unauthorized

    get api_user_display_path(@user_one, @display, format: :json), params: { access_token: @user_one_token.token }
    assert_response :success

    get api_user_display_path(@user_one, @display, format: :json), params: { access_token: @user_two_token.token }
    assert_response :forbidden
  end

  test "Oauth token revocation works" do
    get api_user_display_path(@user_one, @display, format: :json), params: { access_token: @user_one_token.token }
    assert_response :success

    sign_in(@user_one, 'password')
    post revoke_oauth_token_user_path(@user_one), params: { token: @user_one_token.token }

    get api_user_display_path(@user_one, @display, format: :json), params: { access_token: @user_one_token.token }
    assert_response :unauthorized
  end

  test "Can't revoke someone else's tokens" do
    post revoke_oauth_token_user_path(@user_one), params: { token: @user_one_token.token }
    assert_redirected_to new_user_session_path
    
    sign_in(@user_two, 'password')
    post revoke_oauth_token_user_path(@user_one), params: { token: @user_one_token.token }
    assert_response :forbidden
  end
end
