=begin
  複式簿記試用    制限ユーザguestの編集可能共有ユーザとなる。guest本人も
  複式簿記	  簿記のownerとなる。複式簿記試用権も持つ。
  複式簿記メンテ　複式簿記権限の他、勘定科目の追加削除編集が可能

　共有ユーザ 編集可能：簿記のownerと同じ権限を持つが、共有ユーザの追加削除編集はできない。
             参照可能：参照のみ可能。各伝票のCSVダウンロードも可能。uploadはできない。
             権限なし：削除された者と同じ。共有ユーザとしての扱いを受けない
  login      権限    編集owner 参照owner
  dezawa     メンテ  aaron     ube
  aaron      簿記    dezawa    ube　　  dezawa の編集可能共有ユーザ：メンテ権限を持たないこと
  quantain   ーー　　なし      ube,dezawa
  ubeboard   簿記    なし　　  なし
  guest      試用    なし      なし
  testuser   試用    なし      なし
  old_       ーー    なし      なし

=end
class BookControllerTest < ActionController::TestCase
  Users = %w(dezawa  aaron     quentin    ubeboard  guest  testuser old_password_holder)
  #id          1       3          2       6           5     7           4
  #option     7,8      8                  8           7     7 
  #permit    a2,u1     u1,d2      d1,u1

  SUCCESS= 0..5
  DEZAWA = 0..2
  NO_DZW = 3..5

  @@url_permit    = "/msg_book_permit.html"
  @@url_error   = "/book_keeping/error"

  def owner_change(login,owner)
    login_as login
    get :index
    session[:book_keeping_owner] = 
      assigns(:arrowed).find{|arrw| arrw.owner == owner } || Book::Permission.create_nobody
  end
end
