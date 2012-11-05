package com.desktop.doom
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class WADParser
	{
		public var lumps:Dictionary;
		
		private var _wad:ByteArray;
		
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
	}
}