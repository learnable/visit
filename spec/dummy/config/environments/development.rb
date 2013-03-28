Dummy::Application.configure do
  config.cache_classes = false
  config.whiny_nils = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.active_record.auto_explain_threshold_in_seconds = 0.5
  # Devise-neccessary config
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
end
