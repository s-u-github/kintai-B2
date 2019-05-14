class SessionsController < ApplicationController
  # ログイン画面
  def new
  end
  
  # ログイン状態にする
  def create
    # ログインフォームにて入力されたメールアドレスを使って、データベースからユーザーを取得
    user = User.find_by(email: params[:session][:email].downcase)
    # userオブジェクトがtrueの場合は入力されたメールアドレスを持つユーザーが存在したということ
    # authenticateメソッドの引数として入力されたパスワードを指定しているため、認証に成功した場合のみtrueとして変える
    # 有効なユーザーで、かつパスワードの認証に成功した場合のみtrueになる
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user) # sessionsヘルパーメソッド
      redirect_back_or user # sessionsヘルパーメソッド
    else
      flash.now[:danger] = 'メールアドレスとパスワードの情報が一致しませんでした。'
      render 'new'
    end
  end
  
  def destroy
    # sessionsヘルパーメソッド
    log_out if logged_in? # ログイン中の場合のみログアウトする
    redirect_to root_url
  end


end
