class AddOrderStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :order_status, :string
  end
end
