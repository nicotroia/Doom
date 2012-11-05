package com.desktop.doom
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class WADStream
	{
		private const HEADER_LENGTH:int = 12;
		
		public var lumps:Dictionary;
		
		private var _wad:ByteArray;		
		private var _pwad:ByteArray;
		private var _file:File;
		private var _stream:FileStream;
		private var _lumpInfo:Vector.<Array>;
		private var _header:ByteArray;
		private var _lumps:ByteArray;
		private var _directory:ByteArray;
		
		public function parse(wad:ByteArray):Boolean
		{
			_wad = wad;
			lumps = new Dictionary();
			
			trace("Parsing WAD...");
			
			_wad.endian = Endian.LITTLE_ENDIAN;
			
			var type:String = _wad.readUTFBytes(4); //4-byte ascii string
			trace("", "type:", type); //IWAD
			
			var numberOfLumps:int = _wad.readInt(); //4-byte signed int 
			trace("", "lumps:", numberOfLumps); //2306
			
			var infoTableOffset:int = _wad.readInt(); //4-byte signed int
			trace("", "info table offset:", infoTableOffset); //12371396
			
			_wad.position = infoTableOffset;
			
			//trace("", "INFO TABLE: ");
			
			for( var i:uint = 0; i < numberOfLumps; i++ ) 
			{ 
				var lumpOffset:int = _wad.readInt(); //4-byte signed int
				var lumpSize:int = _wad.readInt(); //4-byte signed int
				var lumpName:String = _wad.readUTFBytes(8); //8-byte ascii string
				
				//_wad.position -= 8; trace(_wad.readUTFBytes(8));	
				
				lumps[lumpName] = [lumpOffset, lumpSize];
				
				//trace("", "Entry " + i + ": ... \t " + lumpName + " ... \t" + lumpSize +" b ... \t", "@ "+ lumpOffset);
			}
			
			return true;
		}
		
		public function getLump(lumpName:String):ByteArray
		{			
			if( ! lumps[lumpName] ) { trace(":( Cannot find lump: " + lumpName); return null; }
			
			var targetLump:ByteArray = new ByteArray();
			var lumpOffset:int = lumps[lumpName][0];
			var lumpSize:int = lumps[lumpName][1];
			
			trace("+ Getting Lump: " + lumpName + " ... " + lumpSize + "b");
			
			_wad.position = lumpOffset;
			_wad.readBytes(targetLump, 0, lumpSize);
			
			return targetLump;
		}
		
		public function createPWAD():void
		{
			trace("Create PWAD");
			
			_file = File.desktopDirectory.resolvePath("pwad_output" + File.separator + "pwad_" + (new Date().time).toString() + ".WAD" );
			if( ! _file.parent.exists ) _file.parent.createDirectory();
			_stream = new FileStream();
			_lumpInfo = new Vector.<Array>();
			
			_pwad = new ByteArray();
			_pwad.endian = Endian.LITTLE_ENDIAN;
			
			//12-byte header
			_header = new ByteArray();
			_header.endian = Endian.LITTLE_ENDIAN;
			
			_header.writeUTFBytes("PWAD"); //4-byte "type"
			_header.writeInt(1); //4-byte (long) number of lumps
			
			//1+ lumps
			_lumps = new ByteArray();
			_lumps.endian = Endian.LITTLE_ENDIAN;
			
			writeLumpPLAYPAL();
			
			_header.writeInt(HEADER_LENGTH + _lumps.length); //4-byte (long) directory start offset
			
			//Info table (names, offsets, sizes of lumps)
			_directory = new ByteArray();
			_directory.endian = Endian.LITTLE_ENDIAN;
			
			writeDirectory();
			
			//combine _header + _lumps + _directory
			_pwad.writeBytes(_header);
			_pwad.writeBytes(_lumps);
			_pwad.writeBytes(_directory);
			
			trace(" total size: " + _pwad.length + "b");
			
			//Write PWAD to file.
			_stream.open(_file, FileMode.WRITE);
			_stream.writeBytes(_pwad);
			_stream.close();
			
			trace("Write SUCCESS");
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
			
			_lumps.writeBytes(rainbow);
			
			_lumpInfo.push([rainbow.length, "PLAYPAL"]);
		}
		
		private function writeDirectory():void
		{
			//Directory has one 16-byte entry for every lump
			
			var lumpOffset:uint = HEADER_LENGTH;
			
			for each(var lumpInfo:Array in _lumpInfo) 
			{ 
				_directory.writeInt( lumpOffset ); //1. (long) file offset to start of lump
				_directory.writeInt( lumpInfo[0] ); //2. (long) size of lump
				_directory.writeBytes( padString8(lumpInfo[1]) ); //3. (string8) ASCII string name
				
				lumpOffset += lumpInfo[0]; 
			}
		}
		
		private function padString8(input:String):ByteArray
		{
			var p:ByteArray = new ByteArray();
			var len:int = (8 - p.length);
			
			p.writeUTFBytes(input);
			
			if( len > 0 ) { 
				while( len-- > 0 ) { 
					p.writeByte(0);
				}
			}
			
			return p;
		}
		
	}
}