package com.gawk.URLLoader {
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class CustomURLLoader extends URLLoader {
		
		protected var serviceLocation:String;
		
		public function CustomURLLoader(serviceLocation:String) {
			this.serviceLocation = serviceLocation;
		}
		
		public function loadRequest(urlRequestMethod:String, variables:URLVariables):void {
			var request:URLRequest = new URLRequest(this.serviceLocation);
			request.method = urlRequestMethod;
			request.data = variables;
			
			super.load(request);
		}
	}
}