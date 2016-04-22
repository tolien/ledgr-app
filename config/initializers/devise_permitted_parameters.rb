module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters
  end

  protected

  def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username, :password, :password_confirmation])
#    devise_parameter_sanitizer.for(:account_update) << :email
  end

end

DeviseController.send :include, DevisePermittedParameters
