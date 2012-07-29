class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :actor,  polymorphic: true
      t.references :target, polymorphic: true

      t.string :activity_type
      t.text :data

      t.timestamps
    end
    add_index :activities, [:actor_id, :actor_type]
    add_index :activities, [:target_id, :target_type]
  end
end
