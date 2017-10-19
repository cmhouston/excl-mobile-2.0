package  utilities
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.events.*;
	import flash.net.*;
	import flash.media.StageWebView;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.system.Security;
	/**
	 * ...
	 * @author Darius P
	 */
	public class BrowserWindow extends Browser_Window
	{
		private var webview:StageWebView = new StageWebView();
		private var rect:Rectangle;
		private var sw				:Number = GlobalVarContainer.ScreenW;
		private var sh				:Number = GlobalVarContainer.ScreenH;
		private var page			:String;
		
		public function BrowserWindow( s:String )
		{
			
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			btn_close.addEventListener( MouseEvent.CLICK, onClose );
			hback.width = sw;
			btn_close.scaleX = btn_close.scaleY=hback.scaleY = hback.scaleX;
			btn_close.x = sw - btn_close.width - 20 * btn_close.scaleX;
			btn_close.y = hback.height / 2 - btn_close.height / 2;
			back.width = sw;
			back.height = sh;
			
			/*btn_close.height = 20;
			btn_close.scaleX = btn_close.scaleY;
			btn_close.x = sw - btn_close.width - 20;*/
			page = s;
				
			webview.stage = GlobalVarContainer.MainStage;
			
			rect = new Rectangle(0, hback.height, sw, sh - hback.height);
			
			webview.viewPort = rect;
			/*<video width="320" height="240" controls>
			  <source src="movie.mp4" type="video/mp4">
			  <source src="movie.ogg" type="video/ogg">
			Your browser does not support the video tag.
			</video>
*/			
		//	Security.allowDomain("www.youtube.com");
		//	Security.loadPolicyFile("https://www.youtube.com/crossdomain.xml");
			if (s.indexOf("youtube") >-1){
				var link:String = s.split("v=")[1];
				s = 'https://www.youtube.com/embed/'+link+'?rel=0&modestbranding=1&autoplay=1&showinfo=0';
			}
			
			//webview.loadString(s);
			webview.loadURL(s);
			webview.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChanging);
			
			// var req:URLRequest = new URLRequest(page);
		
		}
		
		private function locationChanging(e:LocationChangeEvent):void 
		{
			e.preventDefault();
		}
		
		private function onClose( event:MouseEvent ):void
		{
			btn_close.removeEventListener( MouseEvent.CLICK, onClose );
			unload();
			this.dispatchEvent( new MoreEvent( MoreEvent.CLOSE_BROWSER ) );
		}
		
	
		
		private function onWebViewError( error:ErrorEvent ):void
		{
			trace( error );
		}
		
	
		
		public function unload():void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
			if( webview != null )
			{
				webview.viewPort = null;
				webview.dispose();
				webview = null;
			};
		}
		
		private function onInit():void
		{
			trace( "**************************************ZINC INT**********************************************" );
		}
		
	}
}