class User < ApplicationRecord
# 1対多の関連性を示す。又、ユーザーが削除された時に関連する勤怠情報も同様に削除されるよう設定している
  has_many :attendances, dependent: :destroy
# コールバックメソッド 保存される前に現在のメールアドレスの値を小文字にする。又、selfは現在のユーザーを指している
  before_save { self.email = email.downcase }
# nameカラムの存在性と最大文字数を検証
  validates :name, presence: true, length: { maximum: 50}
# メールアドレスのフォーマットを検証できる
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
# emailカラムの存在性と最大文字数、フォーマット、一意性を検証(indexを追加してデータベースレベルでも一意性を強制する)
  validates :email, presence: true, length: { maximum: 100}, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
# password_digestカラムとbcrpt gemを追加したことで使用可能になった
  has_secure_password
# パスワードの存在性と最小文字数の検証、allow_nilでパスワードを入力していない場合は検証をスルーして更新
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
# departmentカラムの文字数検証は範囲を指定するオプションinを使用、空でも通るようにallow_nil
  validates :department, length: {in: 3..50}, allow_blank: true
# user.remember_tokenでトークンにアクセス出来るように、かつトークンをデータベースに保存せずに実装する必要があるため
# attr_accessorを使ってアクセス可能な属性を作成している
  attr_accessor :remember_token
  
  
  # 上長一覧(自分が上長の場合、自分を除く)
  def User.superior_user_list_non_self(session)
    if User.find(session[:user_id]).superior == true
      where(superior: true).where.not(id: session[:user_id])
    else
      where(superior: true)
    end
  end
  
  # remember
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64 # SecureRandomモジュールにあるurlsafe_base64メソッド（ランダムな文字64種から22字の字列を作成）
  end
  
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token #selfキーワードを与えると、この代入によってユーザーのremember_token属性が期待どおりに設定される
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil? # authenticated?を更新して、ダイジェストが存在しない場合に対応
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

end
