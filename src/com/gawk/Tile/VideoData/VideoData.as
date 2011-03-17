package com.gawk.Tile.VideoData {
	public class VideoData {
		
		protected var id:String;
		protected var filename:String;
		protected var memberId:int;
		
		public function VideoData(data:Object)	{
			this.setId(data.secureId);
			this.setFilename(data.filename);
			this.setMemberId(data.memberId);
		}
		
		public function setId(id:String):void {
			this.id = id;
		}
		
		public function setFilename(filename:String):void {
			this.filename = filename;
		}
		
		public function setMemberId(memberId:*):void {
			this.memberId = parseInt(memberId);
		}
		
		public function getId():String {
			return this.id;
		}
		
		public function getFilename():String {
			return this.filename;
		}
		
		public function getMemberId():int {
			return this.memberId;
		}
	}
}