class AddAgreementToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :agreement, :boolean
  end
end
