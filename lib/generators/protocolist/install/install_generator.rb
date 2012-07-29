require 'rails/generators/active_record'

module Protocolist
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def generate_activity_model
        if defined?(Mongoid)
          invoke "mongoid:model", ['Activity']
          inject_into_file('app/models/activity.rb', mongoid_model_contents, :after => "include Mongoid::Document\n") if model_exists?
        else
          migration_template "migration.rb", "db/migrate/create_activities"

          invoke "active_record:model", ['Activity'], :migration => false
          inject_into_class('app/models/activity.rb', 'Activity', active_record_model_contents) if model_exists?
        end
      end

      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      private

      def model_exists?
        File.exists?(File.join(destination_root, 'app/models/activity.rb'))
      end

      def mongoid_model_contents
<<CONTENTS

  belongs_to :actor,  :polymorphic => true
  belongs_to :target, :polymorphic => true

  field :activity_type, :type => String
  field :data, :type => Hash
CONTENTS
      end

      def active_record_model_contents
<<CONTENTS
  attr_accessible :activity_type, :target, :actor, :data

  belongs_to :target, :polymorphic => true
  belongs_to :actor, :polymorphic => true

  serialize :data
CONTENTS
      end
    end
  end
end
