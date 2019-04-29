module AttendancesHelper
  
  # 現在の時間を作成(started_atとfinished_atを作成するときに使用)
  def current_time
    Time.new(
        Time.now.year,
        Time.now.month,
        Time.now.day,
        Time.now.hour,
        Time.now.min, 0
        )
  end
  
  # 在社時間のフォーマット
  def working_time(started_at, finished_at)
    format("%.2f", (((finished_at - started_at) / 60) / 60.0)) #この計算結果は秒数で返ってくるため、秒数を2度60で割っている
  end
  
  # 在社時間の合計値
  def working_time_sum(seconds)
    format("%.2f", seconds / 60 / 60.0)
  end
  
end
