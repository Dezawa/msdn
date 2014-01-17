# encoding: utf-8
step '勤務割付をクリックする' do
  click_link "勤務割付"
end

step '勤務割付TOPが表示される' do
  expect(current_path).to eq "/hospital"
end

step "年月入力欄があり" do
  expect(page.has_field?("month")).to be
  expect(page.has_field?("月度")).to be
end

step "部署選択欄があり" do
  expect(page.has_select?("busho_name")).to be
end
step "初期値は部署ID順で最初の部署" do
  expect(find("select#busho_name").value).to eq Hospital::Busho.first.name
end

step "選択肢はHospitalBushoにあるのと同じ" do
expect(find_by_id('busho_name').all("option").count).to eq Hospital::Busho.count
  Hospital::Busho.pluck(:name).each{|busho_name|
    expect(find_by_id('busho_name').find("option", text: busho_name)).to be
  }
end


step "初期値は来月" do
  expect(page.find_field("月度").value).to eq Time.now.next_month.strftime("%Y/%m")
end


