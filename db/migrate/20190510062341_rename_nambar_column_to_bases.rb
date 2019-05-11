class RenameNambarColumnToBases < ActiveRecord::Migration[5.1]
  def change
    rename_column :bases, :base_namber,:base_number
  end
end
