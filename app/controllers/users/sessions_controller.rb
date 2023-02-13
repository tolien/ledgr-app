# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

   # DELETE /resource/sign_out
   def destroy
     super do
       # Turbo requires redirects be :see_other (303); so override Devise default (302)
       return redirect_to after_sign_out_path_for(resource_name), status: :see_other
     end
   end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
