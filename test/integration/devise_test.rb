require "test_helper"

class DeviseTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = FactoryBot.build(:user)
    @controller = Devise::RegistrationsController.new
  end

  test "can sign up" do
    get new_user_registration_path
    assert_response :success
    assert_difference "ActionMailer::Base.deliveries.size", +1 do
      assert_difference("User.count") do
        post user_registration_path, params: {
                                  user: {
                                    username: @user.username,
                                    password: @user.password,
                                    password_confirmation: @user.password,
                                    email: @user.email,
                                  },
                                }
      end
    end
    confirmation_email = ActionMailer::Base.deliveries.last
    assert_not_nil confirmation_email
    assert_match /Welcome #{@user.username}/, confirmation_email.body.to_s, "Confirmation email should open with 'Welcome username'"
  end

  test "can log in" do
    @user.save!

    post user_session_url, params: {
                        user: {
                          username: @user.username,
                          password: @user.password,
                        },
                      }

    assert_response :redirect
    assert_redirected_to "/"
  end

#  test "can log in with 2FA enabled" do
#    @user.save!
#
#    @user.otp_required_for_login = true
#    @user.otp_secret = User.generate_otp_secret
#    @user.save!
#
#    post user_session_url, params: {
#                        user: {
#                          username: @user.username,
#                          password: @user.password,
#                        },
#                      }
#
#    assert_response :ok
#
#    post user_session_url, params: {
#                             user: {
#                               username: @user.username,
#                               password: @user.password,
#                               otp_attempt: @user.current_otp,
#                             },
#                           }
#    assert_response :redirect
#    assert_redirected_to "/"
#  end
end
