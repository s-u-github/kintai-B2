Rails.application.routes.draw do
# static_pagesコントローラー
  # ルートページ
  root 'static_pages#home'
  
# usersコントローラー
  # 新規作成画面へ 
  get '/signup',    to: 'users#new'
  # 基本情報編集画面へ (/edit-basic-info/1という形式のURLでGETリクエストが送信出来るようになる)
  # このURLの記法だと_pathヘルパーが作成されないので、asオプションを使用することでbasic_info_pathメソッドが生成する
  get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info 
  # 基本情報編集画面の更新処理
  patch 'update-basic-info', to: 'users#update_basic_info'
  
# sessionsコントローラー
  # ログイン画面へ
  get    '/login',  to: 'sessions#new'
  # セッションを作成&保存(ログイン状態になる)
  post   '/login',  to: 'sessions#create'
  # ログイン状態を破棄
  delete '/logout', to: 'sessions#destroy'
  
# user > attendanceコントローラー
  # 勤怠編集画面へ ( 何年何月の勤怠表示画面から遷移したかも判定し、編集画面の１ヶ月分の表示を合わせる必要があるため:dateを入れる )
  get 'user/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  # 勤怠編集の更新
  patch 'user/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  
# usersリソース
  resources :users do
    
    member do
      patch  'update_index', as: :update_index # ユーザ一覧の更新
    end
    
    # 勤怠情報を保存する
    resources :attendances, only: :create #リソースをネストしていることで/users/:user_id/attendanceというURLになる。
  end
  
  resources :attendances do
    
    member do
      patch 'update_attendance_info', as: :update_attendance_info # 勤怠変更の更新
    end
     
  end
end
