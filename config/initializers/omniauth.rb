Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.secrets.omniauth_provider_key, Rails.application.secrets.omniauth_provider_secret, image_size: { width: 800, height: 800 }, scope: 'publish_actions', secure_image_url: true
end
