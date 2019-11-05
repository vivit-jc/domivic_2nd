require 'dxopal'
include DXOpal

require_remote './game.rb'
require_remote './view.rb'
require_remote './controller.rb'

BLACK = [0,0,0]
RED = [255,0,0]
YELLOW = [255,255,0]
CHEESE = [255,240,0]
GRAY = [90,90,90]
O_BLACK = [10,10,30]
DARKBLUE = [25,25,230]
WHITE = [255,255,255]
CREAM = [255,240,210]
BAKED = [255,210,140]
BROWN = [230,70,70]
GREEN = [0,255,0]
DARKGREEN = [0,100,0]
DARKMAGENTA = [139,0,139]
DARKGRAY = [70,70,70]
DARKGRAY2 = [80,80,80]
DARKRED = [140,0,0]

FRAME = 15
TITLE_MENU_X = 30
TITLE_MENU_Y = [360,392,424]
TITLE_MENU_TEXT = ["START","STATS","ALL CLEAR"]

RIGHT_SIDE_WIDTH = 110
LEFT_SIDE_X = 460
UNITS_Y = 160
BOTTOM_Y = 400
BOTTOM_WIDTH = 160
MESSAGE_BOX_HEIGHT = 10

Font12 = Font.new(12)
Font16 = Font.new(16)
Font20 = Font.new(20)
Font24 = Font.new(20)
Font28 = Font.new(28)
Font32 = Font.new(32)
Font50 = Font.new(50)
Font60 = Font.new(60)
Font100 = Font.new(100)

IMAGES = [:science, :production, :culture, :growth, :deck, :trash, :emblem, :greatperson, :authority, :stagnation, :swordman, :inheritance,
:trade, :construction, :warrior, :horseman, :walls, :archer, :catapult, :money_bag, :coin, :coin_l, :invasion, :inspiration, :trend, :threat,
:instant, :riot]

TECH_1 = [[:agriculture,"農業"],[:writing,"筆記"],[:archery,"弓術"],[:metal_working,"金属加工"],[:mythology,"神話"],[:masonry,"石工術"]]
TECH_2 = [[:monarchy,"君主政治"],[:mathematics,"数学"],[:law,"法律"],[:currency,"通貨"],[:horse_riding,"騎乗"],[:religion,"宗教"],[:irrigation,"灌漑"]]
TECH_3 = [[:chivalry,"騎士道"],[:education,"教育"],[:metal_casting,"鋳金"],[:music,"音楽"],[:machinery,"機械"],[:guilds,"ギルド"]]
TECH_4 = [[:gunpowder,"火薬"],[:printing_press,"活版印刷"],[:navigation,"航海術"],[:nationalism,"ナショナリズム"],[:banking,"銀行制度"],[:military_science,"軍事学"],[:philosophy,"哲学"]]
TECH_5 = [[:physics,"物理学"],[:steam_power,"蒸気機関"],[:steel,"鋼鉄"],[:biology,"生物学"],[:corporation,"企業"],[:assembly_line,"大量生産"]]
TECH_6 = [[:electricity,"電気"],[:computers,"コンピューター"],[:flight,"飛行機"],[:fission,"核分裂"],[:radio,"無線通信"],[:mass_media,"マスメディア"],[:plastics,"プラスチック"]]


Window.height = 480
Window.width = 640

Image.register(:title, "./img/chichen-itza.jpg")
IMAGES.each do |m|
  Image.register(m, "./img/"+m.to_s+".png")
end
(TECH_1+TECH_2+TECH_3+TECH_4+TECH_5+TECH_6).each do |sym,name|
  Image.register(sym,"./img/"+sym.to_s+".png")
end

Window.load_resources do

  url = 'textdata.json'
  req = Native(`new XMLHttpRequest()`)
  req.overrideMimeType("text/plain")
  req.open("GET", url, false)
  req.send
  text_data = req.responseText
  DATA = Native(`JSON.parse(text_data)`)
  TECHDATA = DATA[:tech]
  BLDGDATA = DATA[:product][:bldg]
  CARDDATA = DATA[:product][:card]
  UNITDATA = DATA[:product][:unit]
  BONUSDATA = DATA[:invasion_bonus]
  ERAMISSION = DATA[:era_mission]
  ERABONUS = DATA[:era_bonus]
  WONDERSDATA = DATA[:wonders]
  # jsonからデータを読むと普通のハッシュとして扱えないので、苦肉の策として世界遺産の名前リストを作る（上記TECHリストに近い）
  WONDERSLIST = DATA[:wonders_list]
  TURN_ERA = 10

  game = Game.new
  controller = Controller.new(game)
  view = View.new(game,controller)

  Window.bgcolor = C_BLACK
  Window.loop do
    controller.input
    view.draw
  end
end
