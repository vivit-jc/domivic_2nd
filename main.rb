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
DARKMAGENTA = [139,0,139]
DARKGRAY = [70,70,70]
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

MAIN_MENU_TEXT = ["実験","外出","ノート","論文","素材","休む","ヘルプ"]

EXPERIMENT = [[100,80],[250,80]]

Font12 = Font.new(12)
Font16 = Font.new(16)
Font20 = Font.new(20)
Font24 = Font.new(20)
Font28 = Font.new(28)
Font32 = Font.new(32)
Font50 = Font.new(50)
Font60 = Font.new(60)
Font100 = Font.new(100)

IMAGES = [:science, :production, :culture, :growth, :deck, :trash, :emblem, :greatperson, :authority, :stagnation, :sword, :arch]

Window.height = 480
Window.width = 640

Image.register(:title, "./img/chichen-itza.jpg")
IMAGES.each_with_index do |m,i|
  Image.register(m, "./img/"+m.to_s+".png")
end

Window.load_resources do

  url = 'textdata.json'
  req = Native(`new XMLHttpRequest()`)
  req.overrideMimeType("text/plain")
  req.open("GET", url, false)
  req.send
  text_data = req.responseText
  TEXT = Native(`JSON.parse(text_data)`)

  game = Game.new
  controller = Controller.new(game)
  view = View.new(game,controller)

  Window.bgcolor = C_BLACK
  Window.loop do
    controller.input
    view.draw
  end
end
