package com.gawk.Member {
	public class Member {
		
		public var secureId:String = "";
		public var firstName:String = "";
		public var lastName:String = "";
		public var alias:String = "";
		public var facebookId:int = 0;
		public var emailAddress:String = "";
		public var token:String = "";
		public var profileVideoSecureId:String = "";
		public var profileVideoLocation:String = "";
		
		public function Member(memberData:Object = null) {
			if (memberData) {
				this.mapData(memberData);
			}
		}
		
		public function mapData(memberData:Object):void {
			if (memberData.firstName) {
				this.firstName = memberData.firstName;
			}
			
			if (memberData.lastName) {
				this.lastName = memberData.lastName;
			}
			
			if (memberData.alias) {
				this.alias = memberData.alias;
			}
			
			if (memberData.emailAddress) {
				this.emailAddress = memberData.emailAddress;
			}
			
			if (memberData.secureId) {
				this.secureId = memberData.secureId;
			}
			
			if (memberData.facebookId) {
				this.facebookId = memberData.facebookId;
			}
			
			if (memberData.profileVideoSecureId) {
				this.profileVideoSecureId = memberData.profileVideoSecureId;
			}
			
			if (memberData.profileVideoLocation) {
				this.profileVideoLocation = memberData.profileVideoLocation;
			}
			
			if (memberData.token) {
				this.token = memberData.token;
			}
		}
		
		public function toObject():Object {
			var object:Object = new Object;
			object.alias = this.alias;
			object.emailAddress = this.emailAddress;
			object.facebookId = this.facebookId;
			object.firstName = this.firstName;
			object.lastName = this.lastName;
			object.profileVideoLocation = this.profileVideoLocation;
			object.profileVideoSecureId = this.profileVideoSecureId;
			object.secureId = this.secureId;
			object.token = this.token;
			
			return object;
		}
	}
}
