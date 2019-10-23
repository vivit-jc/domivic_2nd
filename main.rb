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
:trade, :construction, :warrior, :horseman, :walls, :archer, :catapult, :money_bag, :coin]

TECH_1 = [[:agriculture,"農業"],[:writing,"筆記"],[:archery,"弓術"],[:metal_working,"金属加工"],[:mythology,"神話"],[:masonry,"石工術"]]
TECH_2 = [[:monarchy,"君主政治"],[:mathematics,"数学"],[:law,"法律"],[:currency,"通貨"],[:horse_riding,"騎乗"],[:religion,"宗教"],[:irrigation,"灌漑"]]
TECH_3 = [[:chivalry,"騎士道"],[:education,"教育"],[:metal_casting,"鋳金"],[:music,"音楽"],[:banking,"銀行制度"],[:philosofy,"哲学"]]
TECH_4 = [[:monarchy,"君主政治"],[:mathematics,"数学"],[:law,"法律"],[:currency,"通貨"],[:horse_riding,"騎乗"],[:religion,"宗教"],[:irrigation,"灌漑"]]
TECH_5 = [[:agriculture,"農業"],[:writing,"筆記"],[:archery,"弓術"],[:metal_working,"金属加工"],[:mythology,"神話"],[:masonry,"石工術"]]
TECH_6 = [[:monarchy,"君主政治"],[:mathematics,"数学"],[:law,"法律"],[:currency,"通貨"],[:horse_riding,"騎乗"],[:religion,"宗教"],[:irrigation,"灌漑"]]


Window.height = 480
Window.width = 640

Image.register(:title, "./img/chichen-itza.jpg")
IMAGES.each do |m|
  Image.register(m, "./img/"+m.to_s+".png")
end
(TECH_1+TECH_2+TECH_3).each do |sym,name|
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

  game = Game.new
  controller = Controller.new(game)
  view = View.new(game,controller)

  Window.bgcolor = C_BLACK
  Window.loop do
    controller.input
    view.draw
  end
end
