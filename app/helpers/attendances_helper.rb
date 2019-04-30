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
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end
  
end
