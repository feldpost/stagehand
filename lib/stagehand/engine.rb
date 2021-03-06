require 'stagehand/configuration'

module Stagehand
  class Engine < ::Rails::Engine
    isolate_namespace Stagehand

    config.generators do |g|
      g.test_framework :rspec
    end

    # These require the rails application to be initialized because configuration variables are used
    initializer 'stagehand.load_modules' do
      require 'stagehand/cache'
      require 'stagehand/key'
      require 'stagehand/database'
      require 'stagehand/connection_adapter_extensions'
      require 'stagehand/controller_extensions'
      require 'stagehand/active_record_extensions'
      require 'stagehand/schema_extensions'
      require 'stagehand/staging'
      require 'stagehand/production'
      require 'stagehand/schema'
      require 'stagehand/auditor'
    end
  end
end
