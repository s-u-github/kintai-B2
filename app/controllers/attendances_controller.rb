class AttendancesController < ApplicationController
  # 管理者はNG
  before_action :not_admin_user, only: [:edit]
  
  # 勤怠情報を更新
  def create
    @user = User.find(params[:user_id]) # /users/:user_id/attendancesの:user_idから、インスタンス変数@userを定義している。
    @attendance = @user.attendances.find_by(worked_on: Date.today) # 出勤時間を保存するためのレコードをattendancesテーブルから探し、インスタンス変数@attendanceに代入している。
    if @attendance.started_at.nil?
      @attendance.update_attributes(started_at: current_time) # attendanceヘルパーメソッドを使用
      flash[:info] = 'おはようございます。'
    elsif @attendance.finished_at.nil?
      @attendance.update_attributes(finished_at: current_time)
      flash[:info] = 'おつかれさまでした。'
    end
    redirect_to @user
  end
  
  # 勤怠編集画面
  def edit
    # ルーティングで割り当てたパラメータからそれぞれのインスタンス変数に値を代入できるように設定している。
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    @week = %w{日 月 火 水 木 金 土}
    @dates = user_attendances_month_date
  end

  # 勤怠編集の更新
  def update
    @user = User.find(params[:id])
    # attendanceヘルパーメソッドを使用
    if attendances_invalid?
      attendances_params.each do |key, value| # idと値
        attendance = Attendance.find(key) # idを使い更新対象となるAttendanceモデルのデータを取得
        if value[:attendance_order_id] != "" && attendance.started_at == nil && attendance.finished_at == nil  # started_at,finished_atがnilならそのまま入力値を入れる
          attendance.update_attributes(started_at: value[:started_at], finished_at: value[:finished_at], started_at_after: value[:started_at], finished_at_after: value[:finished_at],
                                          next_day: value[:next_day], note: value[:note], attendance_order_id: value[:attendance_order_id])
        elsif value[:attendance_order_id] == ""
          next
        else
          attendance.update_attributes(started_at_after: value[:started_at], finished_at_after: value[:finished_at],next_day: value[:next_day],
                                        note: value[:note], attendance_order_id: value[:attendance_order_id]) # 編集した値に更新する
        end
      end
      flash[:success] = '勤怠情報を更新しました。'
      redirect_to user_url(@user, params:{first_day: params[:date]})
    else
      flash[:danger] ='不正な時間入力がありました、再入力してください。'
      redirect_to edit_attendances_path(@user, params[:date])
    end
  end
  
  # 勤怠変更お知らせの更新
  def update_attendance_info
    @user = User.find(params[:id])
    update_count = 0
    update_attendance_info_params.each do |id, item|
      if item[:agreement] == "true"
        attendance = Attendance.find(id)
        attendance.update_attributes(attendance_order_id: item[:attendance_order_id], attendance_order_status: current_user.name, approval_day: Date.today)
        update_count += 1
      end
    end
    flash[:success] = "#{update_attendance_info_params.keys.count}件中#{update_count}件の申請を更新しました。"
    redirect_to user_path(@user)
  end
  
  # 残業申請の申請
  def update_overtime
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(worked_on: params[:attendance][:day])
    if @attendance.update_attributes(update_overtime_params)
      flash[:success] = "残業の申請をしました。"
      redirect_to @user
    end
  end
  
  # 残業申請お知らせの更新
  def update_overtime_info
    @user = User.find(params[:id])
    update_count = 0
    update_overtime_info_params.each do |id, item|
      if item[:agreement] == "true"
        attendance = Attendance.find(id)
        attendance.update_attributes(over_order_id: item[:over_order_id], over_order_status: current_user.name)
        update_count += 1
      end
    end
    flash[:success] = "#{update_overtime_info_params.keys.count}件中#{update_count}件の申請を更新しました。"
    redirect_to @user
  end
  
  # １ヶ月分の勤怠申請の申請
  def update_month
    @user = User.find(params[:id])
    day = params[:first_day]
    @attendance = @user.attendances.find_by(worked_on: day)
    unless params[:attendance][:month_order_id].empty? # 申請時、所属長選択が空の場合
      @attendance.update_attributes(update_month_params)
      flash[:success] = "１ヶ月の勤怠を申請をしました。"
    else
      flash[:danger] = "所属長を選択してください。"
    end
    redirect_to @user
  end
  
  # １ヶ月分の勤怠申請の更新
  def update_month_info
    @user = User.find(params[:id])
    update_count = 0
    update_month_info_params.each do |id, item|
      if item[:agreement] == "true"
        attendance = Attendance.find(id)
        attendance.update_attributes(month_order_id: item[:month_order_id], month_order_status: current_user.name, approval_day: Date.today)
        update_count += 1
      end
    end
    flash[:success] = "#{update_month_info_params.keys.count}件中#{update_count}件の申請を更新しました。"
    redirect_to @user
  end
  
  # 出勤社員一覧ページ
  def attendance_list
    # usersテーブルとattendancesテーブルの両方のテーブルの値を取得するため、includesメソッドを使用
    @users = User.all.includes(:attendances)
  end
  
  # csv出力
  def csv_output
    @user = User.find(current_user.id)
    @attendances = @user.attendances.all
    send_data render_to_string, filename: "#{@user.name}の勤怠情報.csv", type: :csv
  end
  
  
  private
    
    # 勤怠編集の更新で使用
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note, :next_day, :attendance_order_id])[:attendances]
    end
    
    # 勤怠変更お知らせの更新で使用
    def update_attendance_info_params
      params.permit(attendances: [:attendance_order_id, :agreement])[:attendances]
    end
    
    # 残業申請で使用
    def update_overtime_params
      params.require(:attendance).permit(:endplans_time, :next_day, :business_contents, :over_order_id)
    end
    
    # 残業申請お知らせの更新で使用
    def update_overtime_info_params
      params.permit(attendances: [:over_order_id, :agreement])[:attendances]
    end
    
    # １ヶ月分の勤怠申請で使用
    def update_month_params
      params.require(:attendance).permit(:month_order_id)
    end
    
    # １ヶ月分の勤怠申請お知らせの更新で使用
    def update_month_info_params
      params.permit(attendances: [:month_order_id, :agreement])[:attendances]
    end
    
    # 管理者はNG
    def not_admin_user
      redirect_to(root_url) if current_user.admin?
    end
end
