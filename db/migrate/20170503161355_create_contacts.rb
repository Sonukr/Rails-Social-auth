class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :name
      t.integer :number
      t.string :picture

      t.timestamps
    end
  end
end
