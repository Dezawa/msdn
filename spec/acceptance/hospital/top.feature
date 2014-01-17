# -*- coding: utf-8 -*-
# language: ja

機能:       勤務割付TOP画面
  シナリオ: MSDNトップページから勤務TOPにアクセスする
    前提    トップページを表示する
    ならば  画面に「南足柄システムデザイン＆ネットワーク」と表示されていること
    かつ    ログインリンクをクリックする
    ならば  ログイン画面が表示されること
    かつ    ユーザ名とパスワードを入力し
    かつ    サインインボタンをクリックする
    かつ    リンク "勤務割付" をクリックする
    ならば  勤務割付TOPが表示される

  シナリオテンプレート: 勤務TOPにアクセスするとサブシステムへのリンクがある
    前提    ログインし "勤務割付" にアクセスする。
    ならば  "table#menuline" にリンク "<link>" がある
    かつ    "table#menuline" のリンク "<link>" をクリックすると "<path>" に飛ぶ
    例:
        |link|path|
        |記号一覧|/hospital/kinmucodes|
	|役割一覧|/hospital/roles|
	|部署登録|/hospital/bushos|
	|必要人数|/hospital/needs|
	|個人登録|/hospital/nurces|
	|役割割当|/hospital/roles/show_assign|
	|会議登録|/hospital/meetings|
	|希望入力|/hospital/monthly/hope_regist|
	|様式9|/hospital/form9|
	|割付|/hospital/monthly/show_assign|

  シナリオ: 勤務TOPにアクセスすると、年月、部署の選択画面がある
    前提    ログインし "勤務割付" にアクセスする。
    ならば  年月入力欄があり
    かつ    初期値は来月
    かつ    部署選択欄があり
    かつ    選択肢はHospitalBushoにあるのと同じ
    かつ    初期値は部署ID順で最初の部署




