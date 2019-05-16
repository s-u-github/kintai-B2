Rails.application.routes.draw do
  
# static_pagesコントローラー
  # ルートページ
  root 'static_pages#home'
  
# usersコントローラー
  # 新規作成画面へ 
  get '/signup',    to: 'users#new'
  # 基本情報編集画面へ (/edit-basic-info/1という形式のURLでGETリクエストが送信出来るようになる)
  # このURLの記法だと_pathヘルパーが作成されないので、asオプションを使用することでbasic_info_pathメソッドが生成する
  get '/edit-basic-info', to: 'users#edit_basic_info', as: :basic_info 
  # 基本情報編集画面の更新処理
  patch 'update-basic-info', to: 'users#update_basic_info'
  
# sessionsコントローラー
  # ログイン画面へ
  get    '/login',  to: 'sessions#new'
  # セッションを作成&保存(ログイン状態になる)
  post   '/login',  to: 'sessions#create'
  # ログイン状態を破棄
  delete '/logout', to: 'sessions#destroy'
  
# users > attendancesコントローラー
  # 勤怠編集画面へ ( 何年何月の勤怠表示画面から遷移したかも判定し、編集画面の１ヶ月分の表示を合わせる必要があるため:dateを入れる )
  get 'user/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  # 勤怠編集の更新
  patch 'user/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  
# basesコントローラー
  # # 拠点情報ページへ
  # get 'bases/index', to: 'bases#index'
  # # 拠点情報の追加ページ
  # get 'bases/new', to: 'bases#new'
  # # 拠点情報の新規作成
  # post 'bases/create', to: 'bases#create', as: :bases
  # # 拠点情報の編集ページ
  # get 'bases/:id/edit', to: 'bases#edit', as: :edit_base
  # # 拠点情報の更新
  # patch 'bases/:id', to: 'bases#update', as: :base
  # # 拠点情報の削除
  # delete 'bases/:id', to: 'bases#destroy'
  
# baseリソース
  resources :bases do
  end
  
# usersリソース
  resources :users do
    
    member do
      patch  'update_index', as: :update_index # ユーザ一覧の更新
      get 'attendance_log', as: :attendance_log # 勤怠修正ログページ
    end
    
    # 勤怠情報を保存する
    resources :attendances, only: :create #リソースをネストしていることで/users/:user_id/attendanceというURLになる。
    
  end
  
  resources :attendances do
    collection do
      get 'attendance_list', as: :attendance_list # 出勤社員一覧ページ
      get 'csv_output', as: :csv_output # csv出力アクション
    end
    
    member do
      patch 'update_attendance_info', as: :update_attendance_info # 勤怠変更お知らせの更新
      patch 'update_overtime', as: :update_overtime # 残業申請
      patch 'update_overtime_info', as: :update_overtime_info # 残業申請お知らせの更新
      patch 'update_month', as: :update_month # １ヶ月分の勤怠申請
      patch 'update_month_info', as: :update_month_info # １ヶ月分の勤怠申請お知らせの更新
    end
  end

end
