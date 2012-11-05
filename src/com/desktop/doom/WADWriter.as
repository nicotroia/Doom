package com.desktop.doom
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class WADWriter
	{
		private const HEADER_LENGTH:int = 12;
		
		private var _desktopDir:File;
		private var _file:File;
		private var _stream:FileStream;
		private var _pwad:ByteArray;
		private var _header:ByteArray;
		private var _lumps:ByteArray;
		private var _lumpInfo:Vector.<Array>;
		private var _directory:ByteArray;
		
		public function createPWAD():void
		{
			trace("Create PWAD");
			
			_desktopDir = File.desktopDirectory;
			_file = _desktopDir.resolvePath("pwad_output" + File.separator + "pwad_" + (new Date().time).toString() + ".WAD" );
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
				_directory.writeInt(lumpOffset); //1. (long) file offset to start of lump
				_directory.writeInt(lumpInfo[0]); //2. (long) size of lump
				_directory.writeUTFBytes(lumpInfo[1]); //3. (string8) ASCII string name
				_directory.writeBytes(padString8(lumpInfo[1])); //additional padding
				
				lumpOffset += lumpInfo[0]; 
			}
		}
		
		private function padString8(input:String):ByteArray
		{
			var p:ByteArray = new ByteArray();
			var len:int = (8 - input.length);
			
			if( len > 0 ) { 
				while( len-- > 0 ) { 
					p.writeByte(0);
				}
			}
			
			return p;
		}
	}
}