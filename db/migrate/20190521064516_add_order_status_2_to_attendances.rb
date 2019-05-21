class AddOrderStatus2ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_order_status, :string
    add_column :attendances, :over_order_status, :string
  end
end
