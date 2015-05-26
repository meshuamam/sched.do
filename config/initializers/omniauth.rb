require Rails.root.join('lib', 'yammer-staging-strategy')
require Rails.root.join('lib', 'yammer-strategy')
OmniAuth.config.on_failure = SessionsController.action(:oauth_failure)
OmniAuth.config.logger = Rails.logger
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end
