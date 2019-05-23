class UsersController < ApplicationController
  # ログイン済みでなければ実行できない
  before_action :logged_in_user, only: [:index, :edit, :update]
  # 正しいユーザーでなければ実行できない
  before_action :correct_user,   only: [:edit, :update]
  # 管理者でなければ実行できない
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info, :index]
  # 管理者はNG
  before_action :not_admin_user, only: [:show, :edit]
  
  # ユーザー一覧ページ
  def index
    # @users = User.paginate(page: params[:page]) # paginateメソッドの働きで、ユーザーのページネーションが行えるようになる。paramsの:pageはビューに記述したwill_paginateで自動生成される
    @users = User.all
  end
  
  # ユーザ一覧　編集して更新(管理者のみ)
  def update_index
    @user = User.find(params[:id])
    if @user.update_attributes(users_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      render 'edit'
    end
  end
  
  # ユーザー勤怠画面
  def show
    @user = User.find(params[:id])
    # debugger  # インスタンス変数を定義した直後にこのメソッドが実行される
    # attendanceヘルパーメソッド使用
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month # 初月の日付を使って月末をインスタンス変数に代入
    @week = %w{日 月 火 水 木 金 土} # 曜日を配列に代入
    (@first_day..@last_day).each do |day|
      # any?メソッドは、ブロック変数attendanceに要素を入れながらブロック（ここではattendance.worked_on == day）を実行し、
      # ブロックが真（true）を返した時は、ブロック実行をその時点で中断しtrueを返します。ブロックの戻り値が全て偽（false）である時はfalseが返されます
      unless @user.attendances.any? {|attendance| attendance.worked_on == day} # unless文なのでfalseの場合、下の処理をする。
        record = @user.attendances.build(worked_on: day) # Railsの慣習に倣い、あるモデルに関連づいたモデルのデータを生成するのにbuildメソッドを使っている
        record.save
      end
    end
    # orderメソッドは取得した値を特定のキーで並び替える。並び替えはデフォルトで昇順(ASC)
    @dates = user_attendances_month_date
    # 出勤日数の合計
    @worked_sum = @dates.where.not(started_at: nil).count
    # 残業モーダルのform用
    @attendance = @user.attendances.new
    # 勤怠変更申請のカウント
    @attendance_application_count = Attendance.where(attendance_order_id: current_user.name).count
    # 残業申請のカウント
    @overtime_application_count = Attendance.where(over_order_id: current_user.name).count
    # １ヶ月の勤怠申請のカウント
    @month_application_count = Attendance.where(month_order_id: current_user.name).count
  end
  
  # 新規登録ページ
  def new
    @user = User.new # 新規作成されたUserオブジェクトをインスタンス変数に代入する
  end
  
  # 新規登録作成
  def create
    # admin　ユーザー一覧からのCSVインポート
    if params[:commit] == "CSVをインポート"
      
      if params[:users_file].content_type == "text/csv" # file_field_tagで選択したファイルがCSVファイルかどうか
          registered_count = import_users # import_usersは下の方にメソッドあり CSVのインポート処理関連
          unless @errors.count == 0
            flash[:danger] = "#{@errors.count}件登録に失敗しました"
          end
          unless registered_count == 0
            flash[:success] = "#{registered_count}件登録しました"
          end
          redirect_to users_url(error_users: @errors)
      else
        flash[:danger] = "CSVファイルのみ有効です"
        redirect_to users_url
      end
    else
      @user = User.new(users_params) # Strong Parametersを用いる
      if @user.save
        log_in @user # 登録成功時にログインする
        flash[:success] = "ユーザーの新規作成に成功しました。"
        redirect_to @user # redirect_to user_url(@user)と同じ内容
      else
        render 'new'
      end
    end
  end
  
  # ユーザー編集ページ
  def edit
    # correct_userで定義したため削除していい
    # @user = User.find(params[:id])
  end
  
  # ユーザーの更新
  def update
    # correct_userで定義したため削除していい
    # @user = User.find(params[:id])
    # update_attributesには引数としてuser_pramsを渡し、無効な情報だった場合はfalseが返ってくるのでそれを利用してif~else文を構築
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  # ユーザーの削除
  def destroy
    if current_user.admin?
      User.find(params[:id]).destroy
      flash[:success] = "削除しました。"
    else
      flash[:danger] = "管理者しか削除できません。"
    end
    redirect_to users_url
  end
  
  # 基本情報編集ページ
  def edit_basic_info
    # @user = User.find(params[:id])  
  end
  
  # 基本情報編集の更新
  # def update_basic_info
  #   @user = User.find(params[:id])
  #   if @user.update_attributes(basic_info_params)
  #     flash[:success] = "基本情報を更新しました。"
  #     redirect_to @user
  #   else
  #     render 'edit_basic_info'
  #   end
  # end
  
  # 勤怠修正ログページ
  def attendance_log
    @user = User.find(params[:id])
    # @attendance_logs = @user.attendances.where(attendance_order_id: "承認").order('worked_on')
    if params[:year]
      date = Date.new(params[:year].to_i, params[:month].to_i)
      @attendance_logs = @user.attendances.where(attendance_order_id: "承認").where(worked_on: date.beginning_of_month..date.end_of_month)
    else
      @attendance_logs = @user.attendances.where(attendance_order_id: "承認").where(worked_on: Time.now.beginning_of_month..Time.now.end_of_month)
    end
  end
  
  
  private
  
    # Strong Parameters 必須となるパラメータと許可されたパラメータを指定することができる。
    # ユーザー設定で使用
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    # 基本情報の更新で使用
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end
  
    # ユーザ一覧の更新で使用
    def users_params
      params.require(:user).permit(:name, :email, :department, :password, :code, :card_id, :surperior, :basic_time, :work_time, :work_time_finish)
    end
  
    # beforeアクション
    
    # ログイン済みユーザーか確認
    def logged_in_user
      unless logged_in?
        # sessionsヘルパーメソッド
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      # 後付けif文の構成と一緒で、条件式がfalseの場合のみ、冒頭のコードが実行される、current_user?はsessonヘルパーメソッド
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    # 管理者はNG
    def not_admin_user
      redirect_to(root_url) if current_user.admin?
    end
    
    # CSVインポート
    def import_users
      # 登録処理前のレコード数
      current_user_count = ::User.count
      users = []
      @errors = []
      # windowsで作られたファイルに対応するので、encoding: "SJIS"を付けている
      # headersオプションを使うと、CSVの初めの1行はheaderとして出力の際に無視される (nameなどの属性名部分)
      CSV.foreach(params[:users_file].path, headers: true) do |row| # CSV.foreach # ファイルから一行ずつ読み込み 又、application.rbでrequire 'csv'も必要
        user = User.new({ name: row["name"], email: row["email"], department: row["department"], code: row["code"], card_id: row["card_id"], basic_time: row["basic_time"], 
                              work_time: row["work_time"], work_time_finish: row["work_time_finish"], superior: row["superior"], admin: row["admin"], password: row["password"]})
        if user.valid?
            users << ::User.new({ name: row["name"], email: row["email"], department: row["department"], code: row["code"], card_id: row["card_id"], basic_time: row["basic_time"], 
                              work_time: row["work_time"], work_time_finish: row["work_time_finish"], superior: row["superior"], admin: row["admin"], password: row["password"]})
        else
          @errors << user.errors.inspect # inspectメソッドとは、オブジェクトや配列などをわかりやすく文字列で返してくれるメソッド
        end
      end
      # importメソッドでバルクインサートできる(gem 'activerecord-import'が必要)
      ::User.import(users)
      # 何レコード登録できたかを返す
      ::User.count - current_user_count
    end
end
