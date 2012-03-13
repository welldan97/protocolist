require 'rails/generators/active_record'

module Protocolist
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def generate_activity_model
        migration_template "migration.rb", "db/migrate/create_activities"
        invoke "active_record:model", ['Activity'], :migration => false
        model_content = <<CONTENT
  belongs_to :object, :polymorphic => true
  belongs_to :subject, :polymorphic => true
  serialize :data
CONTENT
        inject_into_class('app/models/activity.rb', 'Activity', model_content) if File.exists?(File.join(destination_root, 'app/models/activity.rb'))


      end

      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
