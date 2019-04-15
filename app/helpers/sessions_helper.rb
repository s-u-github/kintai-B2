module SessionsHelper
  
  # 引数に渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id  
  end
  
  # 現在ログイン中のユーザーを返す(ただし、いる場合のみ)
  def current_user
    if session[:user_id]
      # if @current_user.nil?
      #  @current_user = User.find_by(id: session[:user_id)
      # else
      #  @current_user  #または、@current_user = @current_user || User.find_by(id: session[:user_id)
      # 下記コードは上記コードと同じ
      @current_user ||= User.find_by(id: session[:user_id]) 
    end
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    # 否定演算子!によって、current_userがnilの時にtrueを返す
    !current_user.nil? 
  end
  
  #現在のユーザーをログアウトする
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
end
