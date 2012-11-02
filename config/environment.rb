# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Wazu::Application.initialize!

# Custom settings
APP_SETTINGS = YAML.load_file("#{Rails.root.to_s}/config/settings.yml")[Rails.env]

