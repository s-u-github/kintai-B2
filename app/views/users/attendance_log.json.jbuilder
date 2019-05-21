# コントローラで定義した@mealsに対し、繰り返し処理を行い、jsonの配列を作成します。
json.array! @attendance_logs do |log|
  # meal.nameがjsonデータのnameに代入されます
  # json.〇〇の〇〇がデータから値を取り出す時に使う変数名となります
  json.worked_on         log.worked_on
  json.started_at        log.started_at.to_s(:time)
  json.finished_at       log.finished_at.to_s(:time)
  json.started_at_after  log.started_at_after.to_s(:time)
  json.finished_at_after log.finished_at_after.to_s(:time)
  json.order_status      log.order_status
  json.approval_day      log.approval_day
end