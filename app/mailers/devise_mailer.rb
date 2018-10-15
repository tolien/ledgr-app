class DeviseMailer < Devise::Mailer
    helper :application
    include Devise::Controllers::UrlHelpers
    default template_path: 'devise_mailer'

    def headers_for(action, opts)
        @username = resource.username

        super
    end
end
