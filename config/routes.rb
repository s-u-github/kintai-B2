Rails.application.routes.draw do
# static_pagesコントローラー
  # ルートページ
  root 'static_pages#home'
  
# usersコントローラー
  # 新規作成画面へ 
  get '/signup',    to: 'users#new'
  
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
