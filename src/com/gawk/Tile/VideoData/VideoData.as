package com.gawk.Tile.VideoData {
	public class VideoData {
		
		protected var secureId:String;
		protected var filename:String;
		protected var memberSecureId:String;
		
		public function VideoData(data:Object)	{
			this.setSecureId(data.secureId);
			this.setFilename(data.filename);
			this.setMemberSecureId(data.memberSecureId);
		}
		
		public function setSecureId(secureId:String):void {
			this.secureId = secureId;
		}
		
		public function setFilename(filename:String):void {
			this.filename = filename;
		}
		
		public function setMemberSecureId(memberSecureId:*):void {
			this.memberSecureId = memberSecureId;
		}
		
		public function getSecureId():String {
			return this.secureId;
		}
		
		public function getFilename():String {
			return this.filename;
		}
		
		public function getMemberSecureId():String {
			return this.memberSecureId;
		}
	}
}