package com.gawk.Member.VideoAction {

	public class MemberVideoRatingAction {
		
		protected var videoSecureId:String;
		protected var memberId:int;
		protected var positiveRating:Boolean;
		
		public function MemberVideoRatingAction()	{
		}
		
		public function setVideoSecureId(videoSecureId:String):void {
			this.videoSecureId = videoSecureId;
		}
		
		public function setMemberId(memberId:*):void {
			this.memberId = parseInt(memberId);
		}
		
		public function setPositiveRating(positiveRating:Boolean):void {
			this.positiveRating = positiveRating;
		}
		
		public function getVideoSecureId():String {
			return this.videoSecureId;
		}
		
		public function getMemberId():int {
			return this.memberId;
		}
		
		public function isPositiveRating():Boolean {
			return this.positiveRating;
		}
	}
}