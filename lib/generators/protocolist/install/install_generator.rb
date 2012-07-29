require 'rails/generators/active_record'

module Protocolist
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      class_option 'model-orm',       type: :string, default: 'active_record',          aliases: '-o', desc: 'Model ORM (ActiveRecord or MongoId)'
      class_option 'model-classname', type: :string, default: 'Activity',               aliases: '-c'
      class_option 'model-filename',  type: :string, default: 'app/models/activity.rb', aliases: '-f'


      def generate_activity_model
        if model_orm == 'mongoid' && defined?(Mongoid)
          generate_mongoid_activity_model
        elsif model_orm == 'active_record' && defined?(ActiveRecord)
          generate_active_record_activity_model
        end
      end

      def self.next_migration_number(dirname) #:nodoc:
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      private

      def generate_mongoid_activity_model
        content = <<-CONTENT.gsub(/^ +/, '  ')

          belongs_to :actor,  polymorphic: true
          belongs_to :target, polymorphic: true

          field :activity_type, type: String
          field :data,          type: Hash
        CONTENT


        invoke "mongoid:model", [model_classname]

        if model_exists?
          inject_into_file(model_filename, content, after: "include Mongoid::Document\n")
        end
      end

      def generate_active_record_activity_model
        content = <<-CONTENT.gsub(/^ +/, '  ')
          attr_accessible :activity_type, :target, :actor, :data

          belongs_to :target, polymorphic: true
          belongs_to :actor,  polymorphic: true

          serialize :data
        CONTENT


        migration_template "migration.rb", "db/migrate/create_activities"
        invoke "active_record:model", [model_classname], migration: false

        if model_exists?
          gsub_file model_filename, / +# attr_accessible :title, :body\n/, ''
          inject_into_class(model_filename, model_classname, content)
        end
      end

      def model_exists?
        File.exists?(File.join(destination_root, model_filename))
      end

      def model_filename
        options['model-filename']
      end

      def model_classname
        options['model-classname']
      end

      def model_orm
        options['model-orm']
      end
    end
  end
end
