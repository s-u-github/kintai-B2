class AddEndplansTimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :endplans_time, :datetime
    add_column :attendances, :business_contents, :string
  end
end
