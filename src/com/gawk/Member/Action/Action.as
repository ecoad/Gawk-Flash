package com.gawk.Member.Action {

	public class Action {
		
		protected var id:String;
		protected var memberId:int;
		protected var action:String;
		
		public function Action(data:Object)	{
			this.setId(data.videoId);
			if (data.memberId) {
				this.setMemberId(data.memberId);
			}
			this.setAction(data.action);
		}
		
		public function setId(id:String):void {
			this.id = id;
		}
		
		public function setMemberId(memberId:*):void {
			this.memberId = parseInt(memberId);
		}
		
		public function setAction(action:String):void {
			this.action = action;
		}
		
		public function getId():String {
			return this.id;
		}
		
		public function getMemberId():int {
			return this.memberId;
		}
		
		public function getAction():String {
			return this.action;
		}
	}
}