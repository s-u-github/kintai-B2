class AddMonthOrderToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_order_status, :string
  end
end
