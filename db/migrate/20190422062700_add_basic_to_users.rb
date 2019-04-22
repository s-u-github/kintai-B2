class AddBasicToUsers < ActiveRecord::Migration[5.1]
  def change
    # parseの引数にしている文字列"2019/04/22 08:00"をDateTimeクラスのオブジェクトとして作成している
    add_column :users, :basic_time, :datetime, default: Time.zone.parse("2019/04/22 7:30")
    add_column :users, :work_time, :datetime,  default: Time.zone.parse("2019/04/22 8:00")
  end
end
