Rails.application.routes.draw do
# static_pagesコントローラー
  # ルートページ
  root 'static_pages#home'
  
# usersコントローラー
  # 新規作成画面へ 
  get '/signup',    to: 'users#new'
  # 基本情報編集画面へ(/edit-basic-info/1という形式のURLでGETリクエストが送信出来るようになる)
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
  
# usersリソース
  resources :users
end
