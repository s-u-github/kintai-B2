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
    if started_at > finished_at # 翌日だった場合
      format("%.2f", (((finished_at.tomorrow - started_at) / 60) / 60.0)) #この計算結果は秒数で返ってくるため、秒数を2度60で割っている
    else
      format("%.2f", (((finished_at - started_at) / 60) / 60.0)) #この計算結果は秒数で返ってくるため、秒数を2度60で割っている
    end
  end
  
  # 在社時間の合計値
  def working_time_sum(seconds)
    format("%.2f", seconds / 60 / 60.0)
  end
  
  # 時間外時間
  def off_hours_time(id, overtime)
    end_time = overtime.endplans_time # endplans_timeを取得
    work_time = User.find(id).work_time_finish # usersテーブルのwork_time_finishを取得
    end_adjust = Time.new(end_time.year, end_time.month, end_time.day, end_time.hour, end_time.min, 0) # end_plans_timeを新しく作り調整
    work_adjust = Time.new(end_time.year, end_time.month, end_time.day, work_time.hour, work_time.min, 0) # work_time_finishを新しく作り調整(年月)
    if overtime.next_day == true  # 翌日だった場合
      format("%.2f", ((end_adjust.tomorrow - work_adjust) / 60) / 60)
    else
      format("%.2f", ((end_adjust - work_adjust) / 60) / 60)
    end
  end

  # 残業承認の表示
  def overtime_display(date)
    if date.over_order_id == "上司A" || date.over_order_id == "上司B" || date.over_order_id == "上司C" || date.over_order_id == "上司D"
      "残業申請中：#{date.over_order_id}"
    elsif date.over_order_id == "承認"
      "残業承認済：#{date.over_order_status}"
    elsif date.over_order_id == "否認"
      "残業否認：#{date.over_order_status}"
    end
  end

  # 勤怠変更承認の表示
  def attendance_display(date)
    if date.attendance_order_id == "上司A" || date.attendance_order_id == "上司B" || date.attendance_order_id == "上司C" || date.attendance_order_id == "上司D"
      "勤怠編集申請中：#{date.attendance_order_id}"
    elsif date.attendance_order_id == "承認"
      "勤怠編集承認済：#{date.attendance_order_status}"
    elsif date.attendance_order_id == "否認"
      "勤怠編集否認：#{date.attendance_order_status}"
    end
  end

  # 所属長承認のステータス
  def current_month_status(day)
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(worked_on: day)
    if @attendance.month_order_id == "上司A" || @attendance.month_order_id == "上司B" || @attendance.month_order_id == "上司C" || @attendance.month_order_id == "上司D"
      "#{@attendance.month_order_id}に申請中"
    elsif @attendance.month_order_id == "承認" &&  @attendance.month_order_status.present?
      "#{@attendance.month_order_status}から承認済"
    elsif @attendance.month_order_id == "否認" &&  @attendance.month_order_status.present?
      "#{@attendance.month_order_status}から否認"
    else
      "未"
    end
  end
  
  # @first_dayの定義のリファクタリング (params[:first_day])
  def first_day(date)
    !date.nil? ? Date.parse(date) : Date.current.beginning_of_month
    # 元々は下記を使用していた
    # if params[:first_day].nil? # 時間管理表のlink_toでパラメータを受け取っているかどうか
    #   @first_day = Date.today.beginning_of_month
    # else
    #   @first_day = Date.parse(params[:first_day]) # params[:first_day]で受け取った値は文字列なので、parseメソッドでDateクラスオブジェクトに変えている
    # end
  end
  
  # @datesのリファクタリング
  def user_attendances_month_date
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  # 勤怠編集の更新時、不正な値がないか確認
  def attendances_invalid? # attendances_invalid?は真偽値（true, false）を返す
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next # nextは繰り返し処理の中で呼び出されると、その後の処理をスキップしつつ、繰り返し処理自体は続行。
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break # breakは単純に繰り返し処理を中断する。
      elsif item[:started_at] > item[:finished_at] && item[:next_day] == "true" # 翌日テェックがtrueの場合はOK
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end
  
end
