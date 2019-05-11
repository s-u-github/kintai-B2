class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.integer :base_namber
      t.string :base_name
      t.string :base_info

      t.timestamps
    end
  end
end
