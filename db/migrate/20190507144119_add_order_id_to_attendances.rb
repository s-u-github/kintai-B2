class AddOrderIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_order_id, :string
    add_column :attendances, :month_order_id, :string
    add_column :attendances, :over_order_id, :string
  end
end
