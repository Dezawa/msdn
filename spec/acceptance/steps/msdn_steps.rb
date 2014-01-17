# encoding: utf-8

step 'msdn サイトにアクセスする' do
  Capybara.app_host = "http://exsample.com/"
end

step 'トップページを表示する' do
  visit "/"
end

step '画面に「南足柄システムデザイン＆ネットワーク」と表示されていること' do
  expect(page).to have_content("南足柄システムデザイン＆ネットワーク")
end

step 'トップページにアクセスして簿記をアクセスする' do
  click_link("複式簿記")
end

step '複式簿記をクリックする' do
  click_link "複式簿記"
end

step 'ログインリンクをクリックする' do
  click_link("ログイン")
end

step 'ログイン画面が表示されること' do
  expect(current_path).to eq "/users/sign_in"
end
step '複式簿記メインが表示されること' do
  expect(current_path).to eq "/book/keeping"
end

step 'ユーザ名とパスワードを入力し' do
  fill_in("user_username",with: "dezawa")
  fill_in("user_password",with: "ug8sau6m")
end

step 'サインインボタンをクリックする' do
  click_button("Sign in")
end

step 'ログインできていること' do
  expect(page.has_no_link?("ログイン")).to be_true
  expect(page.has_link?("ログアウト")).to be_true
end

step 'リンク :link をクリックする' do |link|  click_link link
end

step ':theplace にリンク :link がある' do |theplace,link|
  expect(find(theplace).has_link?(link)).to be
end

step ':theplace のリンク :link をクリックすると :path に飛ぶ' do |theplace,link,path|
  find(theplace).click_link(link)
  expect(current_path).to eq path
end


step 'リンク :link がある' do |link|  click_link link
end

step 'テストデータ :fixture をloadする' do |fixture|
  fixtures fixture

end

step 'ログインし :menu_button にアクセスする。' do |menu_button|
#  Capybara.app_host = "http://exsample.com/"
  visit "/"
  click_link("ログイン")
  fill_in("user_username",with: "dezawa")
  fill_in("user_password",with: "ug8sau6m")
  click_button("Sign in")
  expect(page.has_no_link?("ログイン")).to be_true
  expect(page.has_link?("ログアウト")).to be_true
  expect(page).to have_content(" #{menu_button} ")
  expect(page.has_link?(menu_button)).to be_true
  click_link(menu_button)
end


  
