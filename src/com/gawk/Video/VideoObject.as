package com.gawk.Video {
	import com.gawk.Member.Member;
	
	public class VideoObject {
		public var secureId:String = "";
		public var filename:String = "";
		public var wallSecureId:String = "";
		public var memberSecureId:String = "";
		public var member:Member = null;
		public var hash:String = "";
		public var uploadSource:String = "";
		public var approved:Boolean = false;
		public var rating:int = 0;
		public var dateCreated:String = "";
		public var dateCreatedTime:int;
		
		public function VideoObject(videoData:Object = null) {
			
			this.member = new Member();
			
			if (videoData) {
				this.mapData(videoData);
			}
		}
		
		public function mapData(videoData:Object):void {
			if (videoData.secureId) {
				this.secureId = videoData.secureId;
			}
			
			if (videoData.filename) {
				this.filename = videoData.filename;
			}
			
			if (videoData.wallSecureId) {
				this.wallSecureId = videoData.wallSecureId;
			}
			if (videoData.memberSecureId) {
				this.memberSecureId = videoData.memberSecureId;
			}
			
			if (videoData.member) {
				this.member = new Member(videoData.member);
			}
		}
		
		public function toObject(withMemberObject:Boolean = false):Object {
			var object:Object = new Object;
			object.secureId = this.secureId;
			object.approved = this.approved;
			object.dateCreated = this.dateCreated;
			object.filename = this.filename;
			object.hash = this.hash;
			if (withMemberObject) {
				object.member = this.member.toObject();
			}
			object.rating = this.rating;
			object.uploadSource = this.uploadSource;
			object.wallSecureId = this.wallSecureId;
			object.memberSecureId = this.memberSecureId;
			
			return object;
		}
	}
}
