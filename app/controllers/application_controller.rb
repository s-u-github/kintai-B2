class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper   # SessionsHelperを読み込む。これでhelperに記述したメソッドが使える
  include AttendancesHelper # AttendancesHelperを読み込む。これでhelperに記述したメソッドが使える
end
