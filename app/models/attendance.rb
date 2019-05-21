class Attendance < ApplicationRecord
# 1対1の関連性を示す
  belongs_to :user

end
