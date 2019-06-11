Rails.application.configure do
  config.secret_key = ENV['DEVISE_SECRET']
end
