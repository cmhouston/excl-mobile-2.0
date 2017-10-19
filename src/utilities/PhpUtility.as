package utilities 
{
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.events.EventDispatcher;
	import flash.events.*;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class PhpUtility extends Sprite
	{
		public static var myXML:XML;
		public static var loader:URLLoader;
		public static var uloader:URLLoader;
		public static var Path:String = "http://excl.dreamhosters.com/prod/wp-content/plugins/json-rest-api/lib/";
		public static var fileToLoad:String;
		private static var dispatcher:EventDispatcher = new EventDispatcher();
		
		
		public static function LoadXML(a:String):void {
			var variables:URLVariables = new URLVariables();
			variables.id = "";
			  
			var ran:Number = Math.floor(Math.random() * 10000000);
			var request:URLRequest = new URLRequest( Path + a+"?ran=" + ran );		
			request.method  = URLRequestMethod.POST;
			request.data = variables;
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, loadCompleteHandler );
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError);

			loader.load( request );
		}
		
		public static function LoadJSON():void{
			var ran:Number = Math.floor(Math.random() * 10000000);
			var request:URLRequest = new URLRequest( "http://excl.dreamhosters.com/prod/wp-json/v01/excl/museum/81" + "?ran=" + ran );		
			request.method  = URLRequestMethod.POST;
			
			
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, loadCompleteHandler );
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError);

			loader.load( request );
			
		}
		
		public static function PostComment(id:Number, obj:Object):void{
			var ran:Number = Math.floor(Math.random() * 10000000);
			var request:URLRequest = new URLRequest( GlobalVarContainer.JSON_PATH +"/posts/" + id + "/comments" + "?ran=" + ran );		
			request.data = JSON.stringify(obj);
			request.method  = URLRequestMethod.POST;
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, sendCompleteHandler );

			loader.load( request );
			
		}
		
		public static function ShareWithFriend(variables:URLVariables):void {
			var ran:Number = Math.floor(Math.random() * 10000000);
			var request:URLRequest = new URLRequest( Path + "sendmail.php?ran=" + ran );		
			request.method  = URLRequestMethod.POST;
			request.data = variables;
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, loadCompleteHandler );
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError);

			loader.load( request );
		}
		
		private static function sendCompleteHandler(e:Event):void 
		{
			loader.removeEventListener( Event.COMPLETE, sendCompleteHandler );
			var phpXML:XML = new XML( loader.data );
			myXML = phpXML;

			dispatcher.dispatchEvent(new PhpUtilityEvent(PhpUtilityEvent.PXML_LOADED));
		}
		
		private static function catchIOError(event:IOErrorEvent):void {
			trace("Error caught: " + event.type);
			LoadXML(fileToLoad);

		}
		
				
		private static function checkCompleteHandler(e:Event):void 
		{			
			trace("Existing Checked");
			loader.removeEventListener( Event.COMPLETE, checkCompleteHandler );
			var phpXML:XML = new XML( loader.data );
			myXML = phpXML;

			dispatcher.dispatchEvent(new PhpUtilityEvent(PhpUtilityEvent.PXML_LOADED));
		}
		
		//***************************************** ******************//
				
		private static function updateCompleteHandler( event:Event ):void
		{		
			uloader.removeEventListener( Event.COMPLETE, updateCompleteHandler );
			var phpXML:XML = new XML( uloader.data );
			myXML = phpXML;

			dispatcher.dispatchEvent(new PhpUtilityEvent(PhpUtilityEvent.UPDATE_LOADED));
		}
		
		//***************************************** ******************//
				
		private static function loadCompleteHandler( event:Event ):void
		{		
			loader.removeEventListener( Event.COMPLETE, loadCompleteHandler );
		//	trace(loader.data);
			var phpXML:XML = new XML( loader.data );
			myXML = phpXML;

			dispatcher.dispatchEvent(new PhpUtilityEvent(PhpUtilityEvent.PXML_LOADED));
		}
		
		
		private static function onResetCompleteHandler( event:Event ):void
		{		
			loader.removeEventListener( Event.COMPLETE, onResetCompleteHandler );

			var phpXML:XML = new XML( loader.data );
			myXML = phpXML;

			dispatcher.dispatchEvent(new PhpUtilityEvent(PhpUtilityEvent.SUB_LOADED));
		}
		
		//Static Class Event Utilities
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		public static function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
		}
		public static function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		
		
		
	}
	
}