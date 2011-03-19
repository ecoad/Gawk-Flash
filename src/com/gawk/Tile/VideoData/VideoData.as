package com.gawk.Tile.VideoData {
	import com.gawk.Member.Member;
	
	public class VideoData {
		
		protected var secureId:String;
		protected var filename:String;
		protected var memberSecureId:String;
		protected var member:Member;
		
		public function VideoData(data:Object)	{
			this.setSecureId(data.secureId);
			this.setFilename(data.filename);
			this.setMemberSecureId(data.member);
			this.setMember(data.member);
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
		
		public function setMember(memberData:Object):void {
			this.member = new Member(memberData);
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
		
		public function getMember():Member {
			return this.member;
		}
	}
}