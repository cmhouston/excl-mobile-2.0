package {

	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	/**
	 * @author Aymeric
	 */
	public class ImageWriterWorker extends Sprite {

		public var msgChannelMainToImageWriterWorker:MessageChannel;
		public var msgChannelImageWriterToMainWorker:MessageChannel;
		public var workerToMainStartup:MessageChannel;
		
		public var bytes:ByteArray;

		public function ImageWriterWorker() {

				trace("INIT THE WORKER FROM INSIDE");
			msgChannelMainToImageWriterWorker = Worker.current.getSharedProperty("mainToImageWriterWorker");
			msgChannelImageWriterToMainWorker = Worker.current.getSharedProperty("imageWriterWorkerToMain") as MessageChannel;
			
			if (msgChannelMainToImageWriterWorker) {
				
				msgChannelMainToImageWriterWorker.addEventListener(Event.CHANNEL_MESSAGE, messageFromMainWorker);
			
				bytes = Worker.current.getSharedProperty("imageBytes");
				
				trace("Getting Shared Property");
			}
			
			workerToMainStartup = Worker.current.getSharedProperty("workerToMainStartup");
			trace("WorkerToMain: " + workerToMainStartup);
			if(workerToMainStartup){
				workerToMainStartup.send(true);
			}
		}		
		
		private function messageFromMainWorker(evt:Event):void {
			
			if (msgChannelMainToImageWriterWorker.messageAvailable) {
				trace("Message from Worker");
				var obj:Object = msgChannelMainToImageWriterWorker.receive();
				
				bytes.position = 0;
				
				var bmpd:BitmapData = new BitmapData(obj.width, obj.height, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, bytes);
				
				var localFile:File = new File(obj.path);
				
				var extension:String = obj.path.substring(obj.path.lastIndexOf(".") + 1, obj.path.length);
				var bytesEncoded:ByteArray;
				
				if (extension == "jpg")
					bytesEncoded = bmpd.encode(bmpd.rect, new JPEGEncoderOptions(70));
				
				else if (extension == "png")
					bytesEncoded = bmpd.encode(bmpd.rect, new PNGEncoderOptions(true));
				
				else 
					throw "Unknow extension: " + extension;
				
				var stream:FileStream = new FileStream();
				stream.open(localFile, FileMode.WRITE);
				stream.writeBytes(bytesEncoded);
				stream.close();
				
				bytesEncoded.clear();
				
				msgChannelImageWriterToMainWorker.send("IMAGE_SAVED");
			}
		}
	}
}
