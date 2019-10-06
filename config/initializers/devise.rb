Rails.application.configure do
    Devise.secret_key = ENV['DEVISE_SECRET']
  end