class UsersController < ApplicationController
  # ログイン済みでなければ実行できない
  before_action :logged_in_user, only: [:index, :edit, :update]
  # 正しいユーザーでなければ実行できない
  before_action :correct_user,   only: [:edit, :update]
  # 管理者でなければ実行できない
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info]
  
  # ユーザー一覧ページ
  def index
    @users = User.paginate(page: params[:page]) # paginateメソッドの働きで、ユーザーのページネーションが行えるようになる。paramsの:pageはビューに記述したwill_paginateで自動生成される

  end
  
  # ユーザー勤怠画面
  def show
    @user = User.find(params[:id])
    # debugger  # インスタンス変数を定義した直後にこのメソッドが実行される
    # @first_day = Date.today.beginning_of_month # 当月の日付を使って初月をインスタンス変数に代入
    if params[:first_day].nil? # 時間管理表のlink_toでパラメータを受け取っているかどうか
      @first_day = Date.today.beginning_of_month
    else
      @first_day = Date.parse(params[:first_day]) # params[:first_day]で受け取った値は文字列なので、parseメソッドでDateクラスオブジェクトに変えている
    end
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
  @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  # 出勤日数の合計
  @worked_sum = @dates.where.not(started_at: nil).count
  end
  
  # 新規登録ページ
  def new
    @user = User.new # 新規作成されたUserオブジェクトをインスタンス変数に代入する
  end
  
  # 新規登録作成
  def create
    @user = User.new(user_params) # Strong Parametersを用いる
    if @user.save
      log_in @user # 登録成功時にログインする
      flash[:success] = "ユーザーの新規作成に成功しました。"
      redirect_to @user # redirect_to user_url(@user)と同じ内容
    else
      render 'new'
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
    User.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to users_url
  end
  
  # 基本情報編集ページ
  def edit_basic_info
    @user = User.find(params[:id])  
  end
  
  # 基本情報編集の更新
  def update_basic_info
    @user = User.find(params[:id])
    if @user.update_attributes(basic_info_params)
      flash[:success] = "基本情報を更新しました。"
      redirect_to @user
    else
      render 'edit_basic_info'
    end
  end
  
  private
  
    # Strong Parameters 必須となるパラメータと許可されたパラメータを指定することができる。
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
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
end
