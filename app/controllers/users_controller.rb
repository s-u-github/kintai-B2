class UsersController < ApplicationController
  # ログイン済みでなければ実行できない
  before_action :logged_in_user, only: [:edit, :update]
  # 正しいユーザーでなければ実行できない
  before_action :correct_user,   only: [:edit, :update]
  
  # ユーザー勤怠画面
  def show
    @user = User.find(params[:id])
    # debugger  # インスタンス変数を定義した直後にこのメソッドが実行される
  end
  
  # 新規登録ページ
  def new
    # 新規作成されたUserオブジェクトをインスタンス変数に代入する
    @user = User.new
  end
  
  # 新規登録作成
  def create
    # Strong Parametersを用いる
    @user = User.new(user_params)
    if @user.save
      # 登録成功時にログインする
      log_in @user
      flash[:success] = "ユーザーの新規作成に成功しました。"
      # redirect_to user_url(@user)と同じ内容
      redirect_to @user
    else
      render 'new'
    end
  end
  
  # ユーザー編集ページ
  def edit
    # correct_userで定義したため削除していい
    # @user = User.find(params[:id])
  end
  
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
  
  private
  
    # Strong Parameters 必須となるパラメータと許可されたパラメータを指定することができる。
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
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
end
