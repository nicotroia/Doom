package
{
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.desktop.doom.WADParser;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	[SWF(width="640", height="480")]
	public class Doom extends Sprite
	{
		private var _wadStream:WADParser;
		private var _appDirectory:File;
		private var _wadDirectory:File;
		private var _doomWAD:File;
		private var _data:ByteArray;
		private var _playpal:ByteArray;
		
		//UI
		private var _uiContainer:Sprite;
		private var _outputContainer:Sprite;
		private var _startButton:PushButton;
		private var _testWriteButton:PushButton;
		private var _palette00Button:PushButton;
		private var _palette01Button:PushButton;
		private var _palette02Button:PushButton;
		private var _palette03Button:PushButton;
		private var _palette04Button:PushButton;
		private var _palette05Button:PushButton;
		private var _palette06Button:PushButton;
		private var _palette07Button:PushButton;
		private var _palette08Button:PushButton;
		private var _palette09Button:PushButton;
		private var _palette10Button:PushButton;
		private var _palette11Button:PushButton;
		private var _palette12Button:PushButton;
		private var _palette13Button:PushButton;
		private var _paletteButtons:Vector.<PushButton>;
		
		private var _testPalette:Bitmap;
		private var _paletteBMD:BitmapData;
		
		private var _buttonUIPadding:uint = 28; 
		
		public function Doom()
		{
			stage.align = StageAlign.TOP_LEFT
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			trace("hello doom");
			
			_wadStream = new com.desktop.doom.WADParser();
			
			_uiContainer = new Sprite();
			_outputContainer = new Sprite();
			_outputContainer.x = 125;
			
			addChild( _uiContainer );
			addChild( _outputContainer );
			
			_appDirectory = File.applicationDirectory;
			_wadDirectory = _appDirectory.resolvePath("assets"+File.separator+"wad");
			
			_doomWAD = _wadDirectory.resolvePath("DOOM.WAD"); //"rainbow_colors.WAD");
			_doomWAD.addEventListener(Event.COMPLETE, loadCompleteHandler);
			
			initUI();
			
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
		}
		
		protected function stageResizeHandler(event:Event):void
		{
			drawUI(event);
		}
		
		private function drawUI(event:Event = null):void
		{
			
		}
		
		private function initUI():void
		{
			_startButton = new PushButton(_uiContainer, 7, 7, "Load DOOM.WAD", function():void { 
				_doomWAD.load();
				_startButton.enabled = false;
			});
			
			_testWriteButton = new PushButton(_uiContainer, 150, 7, "Write PWAD", function():void { 
				_wadStream.startPWAD();
				writeLumpPLAYPAL();
				_wadStream.endPWAD();
			});
			
			_palette00Button = new PushButton( _uiContainer, 7, _startButton.y + _buttonUIPadding, "Load Palette 00", function():void { loadPalette(0); });
			_palette01Button = new PushButton( _uiContainer, 7, _palette00Button.y + _buttonUIPadding, "Load Palette 01", function():void { loadPalette(1); });
			_palette02Button = new PushButton( _uiContainer, 7, _palette01Button.y + _buttonUIPadding, "Load Palette 02", function():void { loadPalette(2); });
			_palette03Button = new PushButton( _uiContainer, 7, _palette02Button.y + _buttonUIPadding, "Load Palette 03", function():void { loadPalette(3); });
			_palette04Button = new PushButton( _uiContainer, 7, _palette03Button.y + _buttonUIPadding, "Load Palette 04", function():void { loadPalette(4); });
			_palette05Button = new PushButton( _uiContainer, 7, _palette04Button.y + _buttonUIPadding, "Load Palette 05", function():void { loadPalette(5); });
			_palette06Button = new PushButton( _uiContainer, 7, _palette05Button.y + _buttonUIPadding, "Load Palette 06", function():void { loadPalette(6); });
			_palette07Button = new PushButton( _uiContainer, 7, _palette06Button.y + _buttonUIPadding, "Load Palette 07", function():void { loadPalette(7); });
			_palette08Button = new PushButton( _uiContainer, 7, _palette07Button.y + _buttonUIPadding, "Load Palette 08", function():void { loadPalette(8); });
			_palette09Button = new PushButton( _uiContainer, 7, _palette08Button.y + _buttonUIPadding, "Load Palette 09", function():void { loadPalette(9); });
			_palette10Button = new PushButton( _uiContainer, 7, _palette09Button.y + _buttonUIPadding, "Load Palette 10", function():void { loadPalette(10); });
			_palette11Button = new PushButton( _uiContainer, 7, _palette10Button.y + _buttonUIPadding, "Load Palette 11", function():void { loadPalette(11); });
			_palette12Button = new PushButton( _uiContainer, 7, _palette11Button.y + _buttonUIPadding, "Load Palette 12", function():void { loadPalette(12); });
			_palette13Button = new PushButton( _uiContainer, 7, _palette12Button.y + _buttonUIPadding, "Load Palette 13", function():void { loadPalette(13); });
			
			_paletteButtons = new <PushButton>[_palette00Button, _palette01Button, _palette02Button, _palette03Button, _palette04Button, _palette05Button, _palette06Button, _palette07Button, _palette08Button, _palette09Button, _palette10Button, _palette11Button, _palette12Button, _palette13Button];
			
			for each( var paletteButton:PushButton in _paletteButtons ) { 
				paletteButton.enabled = false;
				paletteButton.visible = false;
			}
			
			drawUI(null);
		}
		
		private function writeLumpPLAYPAL():void
		{
			var rainbow:ByteArray = new ByteArray();
			var colorIndex:int = 256;
			var paletteIndex:int = 14;
			
			while( paletteIndex-- > 0 ) //14 palettes
			{ 
				while( colorIndex-- > 0 ) //256 colors per palette
				{ 
					rainbow.writeByte(Math.random() * 255); //r
					rainbow.writeByte(Math.random() * 255); //g
					rainbow.writeByte(Math.random() * 255); //b
				}
				
				colorIndex = 256;
			}
			
			_wadStream.writeLump(rainbow, "PLAYPAL");
		}
		
		protected function loadCompleteHandler(event:Event):void
		{
			trace("successfully loaded " + event.target.name);
			_data = event.target.data;
			
			_wadStream.parse(_data);
			
			for each( var paletteButton:PushButton in _paletteButtons ) { 
				paletteButton.enabled = true;
				paletteButton.visible = true;
			}
		}
		
		private function loadPalette(paletteNumber:uint):void
		{
			if( paletteNumber > 13 ) return;
			
			//14 color palettes, each 768-bytes (256 rgb triple)
			
			var color:uint, a:uint, r:uint, g:uint, b:uint;
			var cellWidth:uint = 16;
			var paletteWidth:uint = cellWidth * 16; //16x16 cells
			
			_paletteBMD = new BitmapData(paletteWidth, paletteWidth, true, 0);
			_testPalette = new Bitmap(_paletteBMD);
			_testPalette.y = 7;
			
			if( ! _outputContainer.contains(_testPalette) ) _outputContainer.addChild(_testPalette);
			_playpal = (_playpal) ? _playpal : _wadStream.getLump('PLAYPAL');
			
			_playpal.position = 768 * paletteNumber;
			
			for( var x:uint = 0; x < paletteWidth; x += cellWidth ) 
			{ 
				for( var y:uint = 0; y < paletteWidth; y += cellWidth ) 
				{ 
					a = 0xff;
					r = _playpal.readUnsignedByte();
					g = _playpal.readUnsignedByte();
					b = _playpal.readUnsignedByte();
					
					color = a << 24 | r << 16 | g << 8 | b;
					
					//trace("x: " + x + " y: " + y + " ... r: " + r.toString(16) + " g: " + g.toString(16) + " b: " + b.toString(16) + " == 0x" + color.toString(16) );
					_paletteBMD.fillRect(new Rectangle(x, y, cellWidth, cellWidth), color);
				}
			}
			
		}
	}
}