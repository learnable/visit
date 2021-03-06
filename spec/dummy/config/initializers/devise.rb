# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # A *lot* of comments and optional config has been taken out of here. See the
  # devise gem generator if you're trying to configure this.

  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  config.secret_key = '96f2ee8e8dc81b5addd0d6ae306787e907a72c1d0261ef719c8c13bf8e72540ace3a881043477b6661eccf47cb7e29d6f73d76560c23c493898ee6cfc28e102d'
end
