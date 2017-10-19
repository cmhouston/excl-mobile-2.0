package workers
{
	import com.myflashlabs.utils.worker.WorkerBase;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.filesystem.FileMode;
	import flash.events.Event;
	import nid.image.encoder.JPEGEncoder;
	import nid.image.encoder.PNGEncoder;
	/**
	 * ...
	 * @author MyFlashLab Team - 1/28/2016 11:00 PM
	 */
	public class Worker1 extends WorkerBase
	{
		
		public function Worker1()
		{
		
		}
		
		// these methods must be public because they are called from the main thread.
		public function forLoop($myParam:int):void 
		{
			var thisCommand:Function = arguments.callee;
			
			for (var i:int = 0; i < $myParam; i++)
			{
				// call this method to send progress to your delegate
				sendProgress(thisCommand, String(i));
			}
			
			// call this method as the final message from the worker. When this is called, you cannot send anymore "sendProgress"
			//sendResult(thisCommand, $myParam);
		}
		
		// these methods must be public because they are called from the main thread.
		public function SaveImage($bytes:ByteArray, $w:Number, $h:Number, $path:String  ):void 
		{
			trace("***************!!!!!!!!!!!!!!!!!!!!!!!!**************");
			trace("WORKER SAVING: " + $path);
			
			var thisCommand:Function = arguments.callee;
			
				var bmpd:BitmapData = new BitmapData($w, $h, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, $bytes);
				
				var img2Save:File = File.cacheDirectory.resolvePath("cache/" + $path);
				
				//var localFile:File = new File($path);
				
				var extension:String = $path.substring($path.lastIndexOf(".") + 1, $path.length);
				
				var bytesEncoded:ByteArray;
				
				if (extension == "jpg"){
					//bytesEncoded = bmpd.encode(bmpd.rect, new JPEGEncoderOptions(80));
				
					var jpgEncoder:JPEGEncoder = new JPEGEncoder();
					bytesEncoded = jpgEncoder.encode(bmpd, 72);
			
				}else if (extension == "png"){
					//bytesEncoded = bmpd.encode(bmpd.rect, new PNGEncoderOptions(true));
					
					//var pngEncoder:PNGEncoder = new PNGEncoder();
					bytesEncoded =PNGEncoder.encode(bmpd, 72);
					//bytesEncoded = pngEncoder.encode(bmpd, 72);
				
				}else{
					throw "Unknow extension: " + extension;
				}
					
					
				
					
				var fs:FileStream = new FileStream();

				try{

				 //open file in write mode

				 fs.openAsync(img2Save,FileMode.WRITE);
				 fs.addEventListener(Event.CLOSE, function():void{sendProgress(thisCommand, $path)});
				 //write bytes from the byte array
				
				 fs.writeBytes(bytesEncoded);

				 //close the file

				 fs.close();

				}catch(e:Error){

				 trace(e.message);

				}
				
				bytesEncoded.clear();
				
				
				/*var stream:FileStream = new FileStream();
				stream.open(localFile, FileMode.WRITE);
				stream.writeBytes(bytesEncoded);
				stream.close();
				
				bytesEncoded.clear();
				
				sendProgress(thisCommand, $path);*/
			
		}
		
	
	}
}