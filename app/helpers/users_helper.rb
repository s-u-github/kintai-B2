module UsersHelper
  
  # 基本時間などの値を、指定の書式にフォーマットして返す
  def format_basic_time(datetime)
    format("%.2f", ((datetime.hour * 60) + datetime.min)/60.0) # %.2f"は戻り値となる文字列書式を指定している
  end

end
