module SessionsHelper
  
  # 引数に渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id  
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 現在ログイン中のユーザーを返す(ただし、いる場合のみ)
  def current_user
    # if session[:user_id]
      # if @current_user.nil?
      #  @current_user = User.find_by(id: session[:user_id)
      # else
      #  @current_user  #または、@current_user = @current_user || User.find_by(id: session[:user_id)
      # 下記コードは上記コードと同じ
      # @current_user ||= User.find_by(id: session[:user_id])
      
    if (user_id = session[:user_id]) #<--このコードを言葉で表すと、
                                         #「(ユーザーIDにユーザーIDのセッションを代入した結果) ユーザーIDのセッションが存在すれば」
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
    # end
  end
  
  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    # 否定演算子!によって、current_userがnilの時にtrueを返す
    !current_user.nil? 
  end
  
  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  
  #現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 記憶しているURL(もしくはデフォルト値)にリダイレクトする
  def redirect_back_or(default)
    # session[:forwarding_url]がnilでなければその値を使い、そうでなければdefaultの値を使う
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  
  # アクセスしようとしたURLを記憶しておく
  def store_location
    # requestオブジェクトを使いURLを記憶する。後付けif文でGETリクエストのみを記憶するように設定
    session[:forwarding_url] = request.original_url if request.get?
  end
  
end
