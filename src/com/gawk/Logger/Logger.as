package com.gawk.Logger {
	import com.gawk.Engine.Engine;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	public class Logger	extends EventDispatcher {
		
		public static const LOG_ACTIVITY:int = 1;
		public static const LOG_ERROR:int = 2;
		
		protected var engine:Engine;
		
		protected var logLevels:Array = new Array();
		
		protected var logs:Array = new Array();
		
		public function Logger(engine:Engine) {
			this.engine = engine;
			this.logLevels[LOG_ACTIVITY] = "Activity";
			this.logLevels[LOG_ERROR] = "Error";
		}
		
		public function addLog(logLevel:int, log:String):void {
			var log:String = logLevels[logLevel] + ": " + log;
			//this.dispatchEvent(new LoggerEvent(LoggerEvent.LOG_ADDED, log));
			trace(log);
			ExternalInterface.call("console.log", log);
			
			logs.push(log);
			
			if (logLevel == LOG_ERROR) {
				//this.engine.sendLogs(logs);
			}
		}
	}
}