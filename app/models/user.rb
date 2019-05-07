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
  
  
# 上長一覧(自分が上長の場合、自分を除く)
  def User.superior_user_list_non_self(session)
    if User.find(session[:user_id]).superior == true
      where(superior: true).where.not(id: session[:user_id])
    else
      where(superior: true)
    end
  end

end
