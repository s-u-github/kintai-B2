class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    # debugger  # インスタンス変数を定義した直後にこのメソッドが実行される
  end
  
  def new
    # 新規作成されたUserオブジェクトをインスタンス変数に代入する
    @user = User.new
  end
  
  def create
    # Strong Parametersを用いる
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "ユーザーの新規作成に成功しました。"
      # redirect_to user_url(@user)と同じ内容
      redirect_to @user
    else
      render 'new'
    end
  end
  
  private
  
    # Strong Parameters 必須となるパラメータと許可されたパラメータを指定することができる。
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  
end
