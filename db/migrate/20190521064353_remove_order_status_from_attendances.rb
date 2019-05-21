class RemoveOrderStatusFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :order_status, :string
  end
end
