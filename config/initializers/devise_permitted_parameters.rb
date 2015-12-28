module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_filter :configure_permitted_parameters
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :email
#    devise_parameter_sanitizer.for(:account_update) << :email
  end

end

DeviseController.send :include, DevisePermittedParameters