require 'protocolist'
require 'supermodel'
Bundler.require(:default)

User     = Class.new(SuperModel::Base)
Activity = Class.new(SuperModel::Base)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
