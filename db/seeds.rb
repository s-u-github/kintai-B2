User.create!(name:  "管理者",
             email: "email@sample.com",
             department: "管理部",
             password:              "password",
             password_confirmation: "password",
             code: 1111,
             card_id: 1111,
             admin: true,
             superior: false)
             
User.create!(name:  "上司A",
             email: "email2@sample.com",
             department: "上司A部",
             password:              "password",
             password_confirmation: "password",
             code: 2222,
             card_id: 2222,
             admin: false,
             superior: true)
             
User.create!(name:  "上司B",
             email: "email3@sample.com",
             department: "上司B部",
             password:              "password",
             password_confirmation: "password",
             code: 3333,
             card_id: 3333,
             admin: false,
             superior: true)
             
User.create!(name:  "上司C",
             email: "email4@sample.com",
             department: "上司C部",
             password:              "password",
             password_confirmation: "password",
             code: 4444,
             card_id: 4444,
             admin: false,
             superior: true)
             
User.create!(name:  "上司D",
             email: "email5@sample.com",
             department: "上司D部",
             password:              "password",
             password_confirmation: "password",
             code: 5555,
             card_id: 5555,
             admin: false,
             superior: true)

# faker gemでサンプルユーザー作成
# 59.timesは59回ブロックの中身を繰り返す
5.times do |n|
  name  = Faker::Name.name
  email = "email#{n+10}@sample.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end