package utilities 
{
	import flash.filesystem.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.LoaderContext;
	import nid.image.encoder.JPEGEncoder;
	
	//Worker Imports
    import flash.system.MessageChannel;
    import flash.system.Worker;
    import flash.system.WorkerDomain;
    import flash.utils.ByteArray;
	
	import flash.system.ImageDecodingPolicy;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class CachedImage extends Sprite
	{
		private var image2Load:String;
		private var cacheKey:String;
		private var imageLoader:Loader;
		private var HAS_CACHE:Boolean = false;
		private var ImgHeight:Number = 0;
		private var ImgWidth:Number = 0;
		private var image:Bitmap;
		private var black:Btn_Black;
				
		public function CachedImage(s:String, h:Number, w:Number) 
		{
			ImgHeight = h;
			ImgWidth = w;
			var a:Array = s.split("/");
			var len:Number = a.length;
			
			cacheKey = a[len - 3] + "_" + a[len - 2] + "_" + a[len - 1];
			
			HAS_CACHE = HasCache(cacheKey);
			
			
			
			if (HAS_CACHE){
			//	trace("HAS CACHE: " + cacheKey);
				image2Load = cacheKey;
				loadImage();				
			}else{
			//	trace("DOWNLOAD TO CACHE: " + cacheKey);
				DownloadImage(s);
			}
		}
		
		private function HasCache(CacheKey:String):Boolean {
			var f:File = File.cacheDirectory.resolvePath("cache/" + CacheKey);
		//	trace("CACHE: " + f.url);
			return f.exists;
			
			f = null;
		}
		
		public function loadImage():void
		{
				var loaderContext:LoaderContext = new LoaderContext(); 
				loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD 
				var imgFile:File = File.cacheDirectory.resolvePath("cache/" + cacheKey);
			//	trace("Getting from cache: " + imgFile.url);
				var imgPath:String = new File(imgFile.nativePath).url;
				imageLoader= new Loader();
				 var request:URLRequest= new URLRequest(imgPath);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
				imageLoader.load(request);
				
		}
		
		
		private function onLoadComplete(e:Event):void {
		
			image = new Bitmap(e.target.content.bitmapData);
			image.smoothing = true;
			this.addChild(image);			
			this.dispatchEvent(new LoadedImageEvent(LoadedImageEvent.LOADED_IMAGE_COMPLETE));
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			/*black = new Btn_Black();
			addChild(black);
			black.x = image.width / 2 - black.width / 2;
			black.y = image.height / 2 - black.height / 2;*/
		}
		
		
		
		public function DownloadImage(s:String):void
		{		
				imageLoader= new Loader();
				 var request:URLRequest= new URLRequest(s);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDownloadComplete, false, 0, true);
				imageLoader.load(request);
				
		}
		
		private function onDownloadComplete(e:Event):void 
		{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			image = new Bitmap(e.target.content.bitmapData);
			image.smoothing = true;
			
			if(ImgHeight>0){
				image.height = ImgHeight;
				image.scaleX = image.scaleY;
				ImgWidth = image.width;
			}else{
				image.width = ImgWidth;
				image.scaleY = image.scaleX;
				ImgHeight = image.height;
			}
			var mc:MovieClip = new MovieClip();
			this.addChild(mc);	
			mc.addChild(image);	
			
		/*	ImageSaver.addEventListener(MoreEvent.SAVE_COMPLETE, onSaveComplete);
			ImageSaver.SaveImage(mc, cacheKey);*/
			
			
			var bitmapData:BitmapData = new BitmapData(mc.width, mc.height);
			bitmapData.draw(mc);
			var bmp:Bitmap = new Bitmap(bitmapData);
			
			//var imageFolder:File =File.cacheDirectory.resolvePath("cache");
			//imageFolder.createDirectory();
			//GlobalVarContainer.MainBase.TestWorkerMssg(imageFolder.url);
			//var img2Save:File = File.cacheDirectory.resolvePath("cache/" + cacheKey);
			GlobalVarContainer.MainBase.AddBitmap(bmp, cacheKey);
			//GlobalVarContainer.MainBase.TestWorkerMssg(cacheKey);
			
			//GlobalVarContainer.MainBase.AddBitmap(bmp, cacheKey);
			this.dispatchEvent(new LoadedImageEvent(LoadedImageEvent.LOADED_IMAGE_COMPLETE));
			
		}
		
		private function onSaveComplete(e:MoreEvent):void 
		{
			ImageSaver.removeEventListener(MoreEvent.SAVE_COMPLETE, onSaveComplete);
			this.dispatchEvent(new LoadedImageEvent(LoadedImageEvent.LOADED_IMAGE_COMPLETE));
		}
	}

}