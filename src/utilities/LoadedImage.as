package utilities
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader; 
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.ProgressEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class LoadedImage extends Sprite
	{
		private var imageBack:MovieClip = new MovieClip();
		private var image:Bitmap;
		private var imageLoader:Loader;
		private var imagePath:String;
		private var rect:MovieClip;		
		private var hasLoader:Boolean;
		public var Perc:Number;
		public var AbortCnt:Number=0;
		private var abortID:uint;
		private var NUM:Number=0;
		
		public function LoadedImage(img:String, wloader:Boolean = true ) 
		{
			hasLoader = wloader;
			//loadImage(img);
			//trace("LOADING DAILY ICON: " + img);
			imagePath = img;
			
		}
		
		
		
		public function loadImage():void
		{
		
				imageLoader= new Loader();
				 var request:URLRequest= new URLRequest(imagePath);
				imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
				imageLoader.load(request);
				
				abortID = setTimeout(abortLoader, 6000);

				// abort the abort when loaded


		}
		
		private	function abortLoader():void {
			AbortCnt++;
			try {
				imageLoader.close();
				if (AbortCnt < 8) {
					loadImage();
					trace("Loader Aborted "+AbortCnt+"!!!");
				}else{				
					this.dispatchEvent(new LoadedImageEvent(LoadedImageEvent.LOADER_TIMEOUT));
					trace("Loader TIMED OUT!!!!");
				}
			}catch (error:Error) {
				trace("Loader cannot close");
				}
		}
		private function abortAbort():void{
			clearTimeout(abortID);
		}
		
		private function loadProgress(event:ProgressEvent):void {
			var percentLoaded:Number = Math.round(event.bytesLoaded/event.bytesTotal *100);
			Perc = percentLoaded;
			this.dispatchEvent(new LoadedImageEvent(LoadedImageEvent.SHOW_PROGRESS));
		}
		
		public function ReloadImage(s:String):void {
			removeChild(image);
			image = null;
			imagePath = s;
			loadImage();
		}
		
		private function onLoadComplete(e:Event):void {
			abortAbort();
			image = new Bitmap(e.target.content.bitmapData);
			image.smoothing = true;
			this.addChild(image);			
			this.dispatchEvent(new LoadedImageEvent(LoadedImageEvent.LOADED_IMAGE_COMPLETE));
			imageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		
		}
		
		public function DestroyBitmap():void {
				image.bitmapData.dispose();
		}
		
		public function GetBitMapData():BitmapData{
			return image.bitmapData;
		}
	}
	
}