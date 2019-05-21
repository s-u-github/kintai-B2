class AddAfterToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_after, :datetime
    add_column :attendances, :finished_at_after, :datetime
  end
end
