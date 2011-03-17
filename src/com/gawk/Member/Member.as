package com.gawk.Member {
	public class Member {
		
		public var secureId:String = "";
		public var firstName:String = "";
		public var lastName:String = "";
		public var alias:String = "";
		public var facebookId:int = 0;
		public var emailAddress:String = "";
		public var token:String = "";
		
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
		}
	}
}
