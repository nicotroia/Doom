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
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	[SWF(width="480", height="500")]
	public class Doom extends Sprite
	{
		//private var _appDirectory:File;
		//private var _wadDirectory:File;
		//private var _doomWAD:File;
		private var _wadLocation:URLRequest;
		private var _loader:URLLoader;
		private var _data:ByteArray;
		private var _wadParser:WADParser;
		
		//lumps
		private var _playpal:ByteArray;
		
		//UI
		private var _uiContainer:Sprite;
		private var _outputContainer:Sprite;
		private var _textArea:TextArea;
		private var _startButton:PushButton;
		private var _paletteButtonDict:Dictionary;
		private var _paletteButtons:Vector.<PushButton>;
		
		private var _testPalette:Bitmap;
		private var _paletteBMD:BitmapData;
		
		private var _buttonUIPadding:uint = 28; 
		
		public function Doom()
		{
			stage.align = StageAlign.TOP_LEFT
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			trace("hello doom");
			_wadLocation = new URLRequest("assets/wad/DOOM.WAD");
			_wadParser = new WADParser();
			_uiContainer = new Sprite();
			_outputContainer = new Sprite();
			_outputContainer.x = 125;
			
			addChild( _uiContainer );
			addChild( _outputContainer );
			
			/*
			//AIR ONLY
			_appDirectory = File.applicationDirectory;
			_wadDirectory = _appDirectory.resolvePath("assets"+File.separator+"wad");
			_doomWAD = _wadDirectory.resolvePath("DOOM.WAD");			
			_doomWAD.addEventListener(Event.COMPLETE, loadCompleteHandler);
			*/
			
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, 0, true);
			_loader.addEventListener(Event.COMPLETE, loadCompleteHandler, false, 0, true);
			
			initPaletteLumpUI();
			
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
		}
		
		protected function loaderProgressHandler(event:ProgressEvent):void
		{
			trace(event.bytesLoaded/event.bytesTotal);
		}
		
		protected function stageResizeHandler(event:Event):void
		{
			drawUI(event);
		}
		
		private function drawUI(event:Event = null):void
		{
			if( _textArea ) _textArea.width = stage.stageWidth - 42;
			if( _textArea ) _textArea.height = stage.stageHeight - 85;
		}
		
		private function initPaletteLumpUI():void
		{
			_paletteButtons = new Vector.<PushButton>();
			
			_startButton = new PushButton(_uiContainer, 7, 7, "Load DOOM.WAD", function():void { 
				_loader.load(_wadLocation);
				//_doomWAD.load(); //AIR only
				_startButton.enabled = false;
			});
			
			_paletteButtonDict = new Dictionary();
			
			for( var i:uint = 0; i < 14; i++ ) { 
				var startX:uint = 7;
				var startY:uint = (i == 0) ? (_startButton.y + _buttonUIPadding) : (_paletteButtons[(i-1)].y + _buttonUIPadding);
				var label:String = "Palette " + ((i > 9) ? i.toString() : "0"+i.toString());
				var pb:PushButton = new PushButton(_uiContainer, startX, startY, label, loadPalette);
				
				_paletteButtonDict[pb] = i;
				_paletteButtons.push(pb);
			}
			
			for each( var paletteButton:PushButton in _paletteButtons ) { 
				paletteButton.enabled = false;
			}
			
			drawUI(null);
		}
		
		protected function loadCompleteHandler(event:Event):void
		{
			_loader.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
			_loader.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			
			trace("successfully loaded " + _wadLocation.url);
			
			_data = _loader.data;
			
			_wadParser.parse(_data);
			
			for each( var paletteButton:PushButton in _paletteButtons ) { 
				paletteButton.enabled = true;
			}
		}
		
		private function loadPalette(event:Event = null):void
		{
			var paletteNumber:uint = _paletteButtonDict[event.target];
			//if( paletteNumber > 13 ) return;
			
			//14 color palettes, each 768-bytes (256 rgb triple)
			
			var color:uint, a:uint, r:uint, g:uint, b:uint;
			var cellWidth:uint = 16;
			var paletteWidth:uint = cellWidth * 16; //16x16 cells
			
			_paletteBMD = new BitmapData(paletteWidth, paletteWidth, true, 0);
			_testPalette = new Bitmap(_paletteBMD);
			_testPalette.y = 7;
			
			if( ! _outputContainer.contains(_testPalette) ) _outputContainer.addChild(_testPalette);
			_playpal = (_playpal) ? _playpal : _wadParser.getLump('PLAYPAL');
			
			_playpal.position = 768 * paletteNumber;
			
			for( var x:uint = 0; x < paletteWidth; x += cellWidth ) { 
				
				for( var y:uint = 0; y < paletteWidth; y += cellWidth ) { 
					
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