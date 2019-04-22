User.create!(name:  "管理者",
             email: "email@sample.com",
             department: "管理部",
             password:              "password",
             password_confirmation: "password",
             admin: true)

# faker gemでサンプルユーザー作成
# 59.timesは59回ブロックの中身を繰り返す
59.times do |n|
  name  = Faker::Name.name
  email = "email#{n+1}@sample.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end