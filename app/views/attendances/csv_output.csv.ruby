require 'csv'

CSV.generate do |csv|
  csv_column_names = ["日付","出社時間","退社時間"]
  csv << csv_column_names
  @attendances.each do |attendance|
    csv_column_values = [
      attendance.worked_on,
      if attendance.started_at.nil?
        attendance.started_at
      else
        attendance.started_at.strftime("%R")
      end,
      if attendance.finished_at.nil?
        attendance.finished_at
      else
        attendance.finished_at.strftime("%R")
      end
    ]
    csv << csv_column_values
  end
end