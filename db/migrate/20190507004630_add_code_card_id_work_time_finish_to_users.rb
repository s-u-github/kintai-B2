class AddCodeCardIdWorkTimeFinishToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :code, :integer
    add_column :users, :card_id, :integer
    add_column :users, :work_time_finish, :datetime, default: Time.zone.parse("2019/04/22 18:00")
  end
end
