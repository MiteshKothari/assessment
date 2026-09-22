require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module AcmeSalaryPlatform
  class Application < Rails::Application
    config.load_defaults 7.2

    # Configure as API only app
    config.api_only = true

    # Autoload services and lib
    config.autoload_paths << Rails.root.join("app/services")
  end
end
