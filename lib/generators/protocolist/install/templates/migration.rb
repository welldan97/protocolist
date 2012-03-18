class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :subject, :polymorphic => true
      t.references :object, :polymorphic => true
      t.string :type
      t.text :data

      t.timestamps
    end
    add_index :activities, :subject_id
    add_index :activities, :object_id
  end
end
