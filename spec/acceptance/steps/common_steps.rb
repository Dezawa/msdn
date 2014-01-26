# -*- coding: utf-8 -*-


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

step '画面に :string と表示されている。' do |string|
  expect(page).to have_content(string)
end


step 'リンク :link をクリックする' do |link|  click_link link
end
step 'ボタン :button をクリックする' do |button|  click_button button
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

step '選択肢 :location の値は :busho となっている。' do |location,busho|
  expect(find(location).value).to eq busho
end

step '選択肢 :select を選び' do |select_item|
   select select_item
end
