require 'csv'

CSV.generate do |csv|
  csv_column_names = ["日付","出社時間","退社時間"]
  csv << csv_column_names
  @attendances.each do |attendance|
    csv_column_values = [
      attendance.worked_on,
      attendance.started_at,
      attendance.finished_at,
    ]
    csv << csv_column_values
  end
end