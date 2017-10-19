package
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import utilities.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import flash.events.MouseEvent;
	
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	/*import flash.system.LoaderContext;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.setTimeout;*/
	
	import workers.Worker1;
	import flash.utils.ByteArray;
	import flash.system.WorkerState;
	
	// WorkerManager which will be taking care of all complicated stuff about AS Workers for you
	import com.myflashlabs.utils.worker.WorkerManager;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class Main extends Sprite 
	{
		/*[Embed(source = "../bin/workers/ImageWriterWorker.swf", mimeType = "application/octet-stream")]
		private static var WORKER_SWF:Class;*/
		
		private var sw:Number;
		private var sh:Number;
		private var STAGE_SIZE_SET:Boolean = false;
		private var mainInterface:MainInterface;
		private var homeCover:HomeCover = new HomeCover();
		public var dropMenu:DropMenu;
		public var dropCover:Btn_Black = new Btn_Black();
		private var tutPop:TutorialPopup;
		private var dbManager:DataManager;
		
		//Worker Code
		private var myWorker:WorkerManager;
		private var bitmapsToEncode:Array = [];
		private var WORKER_WORKING:Boolean = false;
        public var workerByteArrayShared:ByteArray = new ByteArray;
		
       /* public var worker:Worker;
        public var msgChannelMainToImageWriterWorker:MessageChannel;
		public var msgChannelImageWriterToMainWorker:MessageChannel;
		public var workerToMainStartup:MessageChannel;
        public var workerByteArrayShared:ByteArray;*/
		
		private var tracer:TraceText = new TraceText();
		private var IS_TRACING:Boolean = false;
		
		private var tutScreen:TutorialScreen;
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			GlobalVarContainer.MainBase = this;
			GlobalVarContainer.MainStage = stage;
			
			dropCover.alpha = 0;
			
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			stage.addEventListener(Event.RESIZE, onSetStageSize);
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			// init the Manager and pass the class you want to use as your Worker
			myWorker = new WorkerManager(workers.Worker1, loaderInfo.bytes, this);
			
			// listen to your worker state changes
			myWorker.addEventListener(Event.WORKER_STATE, onWorkerState);
			
			// fire up the Worker
			myWorker.start();
			
			
			//********** OLD WORKER CODE *************//
			/*var workerLoader:Loader = new Loader();
 
            //we specify a loader context for managing SWF loading on iOS.
            var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
 
            workerLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadWorker);
            workerLoader.load(new URLRequest("workers/ImageWriterWorker.swf"), loaderContext);*/
			
			
			
			//LoadWorker();
			
		}
		
		private function onSetStageSize(e:Event):void 
		{			
			sw = GlobalVarContainer.ScreenW = stage.stageWidth;
			sh = GlobalVarContainer.ScreenH = stage.stageHeight;
			dropCover.width = sw;
			GlobalVarContainer.HEADER_HEIGHT = sw / 640 * 80;
			dropCover.height = sh - GlobalVarContainer.HEADER_HEIGHT;
			
			if (!STAGE_SIZE_SET){
				STAGE_SIZE_SET = true;
				
				if (sh > 1200) GlobalVarContainer.XLARGE_DISPLAY = true;
				
				GlobalVarContainer.HEIGHT_SCALE = sh / GlobalVarContainer.BASE_HEIGHT;
				trace("************************** DIMENSIONS ************************");
				trace("SW: " + sw + " / SH: " + sh);
				GlobalVarContainer.MAIN_INTERFACE = mainInterface = new MainInterface();
				this.addChild(mainInterface);
				this.addChild(homeCover);
				var scw:Number =sw / homeCover.width;
				var sch:Number = sh / homeCover.height;
				var sc:Number;
				
				if (scw > sch) {
					sc = scw;
				}else {
					sc = sch;
				}
				homeCover.scaleX = homeCover.scaleY = sc;
				
				homeCover.x = sw  / 2 - homeCover.width / 2;
				homeCover.y = sh / 2 - homeCover.height / 2;
				
				init();
			}
			
			AppUtility.SizeAndCenter(homeCover, 640, 960);
			
			
		}
		
		private function init():void 
		{			
			GlobalVarContainer.CheckForMac();
			XMLUtil.addEventListener(XMLUtilityEvent.XML_LOADED, onXMLLoaded);
			if(GlobalVarContainer.MAC_OS){
				XMLUtil.LoadXML("bin/config.xml");
			}else{
				XMLUtil.LoadXML("config.xml");
			}
			
			if(IS_TRACING){
				addChild(tracer);
				tracer.title_txt.width = sw;
				tracer.y = 1136 - 140;
				if(myWorker)
				tracer.title_txt.htmlText = myWorker.state;
			}
			
			if(AppUtility.isMobile()&&GlobalVarContainer.SHARING_ENABLED)GoViral.create();
		}
		
		private function onXMLLoaded(e:XMLUtilityEvent):void 
		{
			XMLUtil.removeEventListener(XMLUtilityEvent.XML_LOADED, onXMLLoaded);
			GlobalVarContainer.ParseConfig(XMLUtil.myXML);
			
			
			
			GlobalVarContainer.DATA_MANAGER=dbManager = new DataManager();
			dbManager.CheckBaseStorage();
		}
		
		public function loadContent():void 
		{
			dropMenu = new DropMenu();
			XMLUtil.addEventListener(XMLUtilityEvent.XML_LOADED, onJSONLoaded);
			XMLUtil.LoadJSON(GlobalVarContainer.JSON_PATH);
		
		}
		
		private function onJSONLoaded(e:XMLUtilityEvent):void 
		{
			XMLUtil.removeEventListener(XMLUtilityEvent.XML_LOADED, onJSONLoaded);
			//trace(XMLUtil.myJSON);
			
			var obj:Object = XMLUtil.myJSON;
						
			
			GlobalVarContainer.ParseContent(obj); 
			
			mainInterface.InitHome();
			
		}
		 
		public function homeLoaded():void{
			TweenMax.to(homeCover, 1, {autoAlpha:0, ease:Strong.easeOut, onComplete:CheckTut});
						
		}
		
		private function CheckTut():void 
		{
			if (GlobalVarContainer.SHOW_TUTORIAL){
				ShowTutorial(0);
			}
		}
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
		public function ShowMenu():void{
			
			if (dropMenu.SHOWING_MENU){
				HideMenu();
			}else{
				this.addChild(dropCover);
				dropCover.addEventListener(MouseEvent.CLICK, onDropClick);
				this.addChild(dropMenu);
				dropCover.y = GlobalVarContainer.HEADER_HEIGHT;
				
				dropMenu.ShowMenu();
			}
		}
		
		private function onDropClick(e:MouseEvent):void 
		{
			dropCover.removeEventListener(MouseEvent.CLICK, onDropClick);
			HideMenu();
		}
		
		public function RemoveCoverEvent():void{			
			dropCover.removeEventListener(MouseEvent.CLICK, onDropClick);
		}
		
		public function HideMenu():void{
			dropCover.removeEventListener(MouseEvent.CLICK, onDropClick);
			dropMenu.HideMenu();
			
			if (this.getChildByName(dropCover.name)){
				removeChild(dropCover);
			}
		}
		
		public function HideCover():void{
			dropCover.removeEventListener(MouseEvent.CLICK, onDropClick);
			dropMenu.SHOWING_MENU = false;
			dropCover.alpha = 0;
			if (this.getChildByName(dropCover.name)){
				removeChild(dropCover);
			}
		}
		
		public function ShowTutorial(n:Number):void{
			if (!tutScreen){
				tutScreen = new TutorialScreen();
			}
			addChild(tutScreen);
			tutScreen.alpha = 0;
			
			tutScreen.LoadNotes(n);
			
			TweenMax.to(tutScreen, .6, {alpha:1, ease:Strong.easeOut});
			tutScreen.addEventListener(MoreEvent.CLOSE_POPUP, onCloseTutScreen);
		}
		
		private function onCloseTutScreen(e:MoreEvent):void 
		{
			tutScreen.addEventListener(MoreEvent.CLOSE_POPUP, onCloseTutScreen);
			removeChild(tutScreen);
			if (!GlobalVarContainer.SHOW_TUTORIAL){
				tutScreen = null;
				dropMenu.ChangeTutorialOn();
				dbManager.onSaveTutSettings(false);
			}
		}
		
		public function ShowTutPopup():void{
			dropMenu.SHOWING_MENU = false;
			this.addChild(dropCover);
			dropCover.alpha = .6;
			tutPop = new TutorialPopup();
			this.addChild(tutPop);
			tutPop.width = sw - 60;
			tutPop.scaleY = tutPop.scaleX;
			tutPop.x = sw / 2 - tutPop.width / 2;
			tutPop.y = sh / 2 - tutPop.height / 2;
			tutPop.btn_no.buttonMode = tutPop.btn_yes.buttonMode = true;
			tutPop.btn_no.addEventListener(MouseEvent.CLICK, onNoTutorial);
			tutPop.btn_yes.addEventListener(MouseEvent.CLICK, onYesTutorial);
		}
		
		private function onYesTutorial(e:MouseEvent):void 
		{
			GlobalVarContainer.SHOW_TUTORIAL = true;
			dbManager.onSaveTutSettings(true);
			dropMenu.ChangeTutorialOff();
			removeTutPop();
			mainInterface.GoMenuSelection(0);
		}
		
		private function onNoTutorial(e:MouseEvent):void 
		{			
			GlobalVarContainer.SHOW_TUTORIAL = false;
			removeTutPop();
		}
		
		private function removeTutPop():void{
			tutPop.btn_no.removeEventListener(MouseEvent.CLICK, onNoTutorial);
			tutPop.btn_yes.removeEventListener(MouseEvent.CLICK, onYesTutorial);
			if (this.getChildByName(tutPop.name)){
				this.removeChild(tutPop);
				tutPop = null;;
			}
			TweenMax.to(dropCover, .6, {alpha:0, ease:Strong.easeOut, onComplete:RemoveDropCover});
		}
		
		public function RemoveDropCover():void 
		{
			if (this.getChildByName(dropCover.name)) removeChild(dropCover);
			dropCover.alpha = 0;
			dropCover.height = sh-GlobalVarContainer.HEADER_HEIGHT;
		}
		
		public function ShowDropCover():void 
		{
			addChild(dropCover);
			dropCover.alpha = .8;
			dropCover.height = sh;
		}
		
		//************ WORKER FUNCTIONS ******************//
		private function onWorkerState(e:Event):void
		{
			trace("worker state = " + myWorker.state)
			
			// if the worker state is 'running', you can start communicating
			if (myWorker.state == WorkerState.RUNNING)
			{
				
				if(IS_TRACING){
					addChild(tracer);
					tracer.title_txt.htmlText = "Workers Ready";
				}
				// create your own commands in your worker class, Worker1, i.e "forLoop" in this sample and pass in as many parameters as you wish
				//myWorker.command("forLoop", onProgress, onResult, 10000);
				trace("Worker Ready to Work");
			}
		}
		
		public function AddBitmap(bmp:Bitmap,path:String):void{
			//trace("Adding Bitmap: " + path);
			bitmapsToEncode.push([bmp, path]);
			if (!WORKER_WORKING) processBitmapQueueToImageWriterWorker();
		}
		
		
		public function processBitmapQueueToImageWriterWorker():void {
			
			if (bitmapsToEncode.length < 1) {
				trace("queue finished");
				return;
			}
			WORKER_WORKING = true;
			var tab:Array = bitmapsToEncode.shift();
			
			var bitmap:Bitmap = tab[0];
			
						
			workerByteArrayShared.clear();
			bitmap.bitmapData.copyPixelsToByteArray(bitmap.bitmapData.rect, workerByteArrayShared);
			TestWorkerMssg("PROCESSING QEUE "+tab[1]);
			myWorker.command("SaveImage", onProgress, onResult, workerByteArrayShared, bitmap.width, bitmap.height, tab[1]);
		}
		
		/**
		 * this function can have as many parameters as you wish. 
		 * this is just a contract between the worker class and this delegate.
		 * What you need to notice though, is that it must return void.
		 */
		 public function TestWorkerMssg(s:String):void{
			 if(IS_TRACING){
				addChild(tracer);
				tracer.title_txt.htmlText = s;
			}
		 }
		private function onProgress($progress:String):void
		{
			if(IS_TRACING){
				addChild(tracer);
				tracer.title_txt.htmlText = $progress;
			}
			
		//	trace("Worker Image Save Complete " + $progress);
			//descTxt.title_txt.htmlText = String($progress);
			if (bitmapsToEncode.length < 1) WORKER_WORKING = false;
			processBitmapQueueToImageWriterWorker();
		}
		
		/**
		 * this function can have as many parameters as you wish. 
		 * this is just a contract between the worker class and this delegate.
		 * What you need to notice though, is that it must return void.
		 */
		private function onResult($result:Number):void
		{
			// terminate the worker when you're done with it.
			myWorker.terminate();
		}
				
		
	/*	private function LoadWorker(evt:Event):void{
			//var workerBytes:ByteArray = new WORKER_SWF() as ByteArray;
			
			 evt.target.removeEventListener(Event.COMPLETE, LoadWorker);
             
            var workerBytes:ByteArray = evt.target.bytes;
			
			worker = WorkerDomain.current.createWorker(workerBytes);
			trace("Worker: " + worker);
			
			 msgChannelMainToImageWriterWorker = Worker.current.createMessageChannel(worker);
			
			msgChannelImageWriterToMainWorker = worker.createMessageChannel(Worker.current);
			msgChannelImageWriterToMainWorker.addEventListener(Event.CHANNEL_MESSAGE, messagesFromImageWriterWorker);

			worker.setSharedProperty("mainToImageWriterWorker", msgChannelMainToImageWriterWorker);
			worker.setSharedProperty("imageWriterWorkerToMain", msgChannelImageWriterToMainWorker);
			
			workerToMainStartup = worker.createMessageChannel(Worker.current);
			workerToMainStartup.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMainStartup);
			worker.setSharedProperty("workerToMainStartup", workerToMainStartup);
		
           
            worker.start();
			trace("worker State: " + worker.state);
		}
		
		
        private function _onImageWriterWorkerLoaded(evt:Event):void {
             
            evt.target.removeEventListener(Event.COMPLETE, _onImageWriterWorkerLoaded);
             
            var workerBytes:ByteArray = evt.target.bytes;
            worker = WorkerDomain.current.createWorker(workerBytes, true);
            // we set the latest arguments to true, because we want to be able to save on disk via the Worker.
             
		
            msgChannelMainToImageWriterWorker = Worker.current.createMessageChannel(worker);
			
			msgChannelImageWriterToMainWorker = worker.createMessageChannel(Worker.current);
			msgChannelImageWriterToMainWorker.addEventListener(Event.CHANNEL_MESSAGE, messagesFromImageWriterWorker);

			worker.setSharedProperty("mainToImageWriterWorker", msgChannelMainToImageWriterWorker);
			worker.setSharedProperty("imageWriterWorkerToMain", msgChannelImageWriterToMainWorker);
			
			workerToMainStartup = worker.createMessageChannel(Worker.current);
			workerToMainStartup.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMainStartup);
			worker.setSharedProperty("workerToMainStartup", workerToMainStartup);
		
           
            worker.start();
			
			
		
			trace("worker State: " + worker.state);
		}
		
		private function onWorkerToMainStartup(ev:Event): void
		{
			trace("WORKER SUCCESS");
			var success:Boolean = workerToMainStartup.receive() as Boolean;
			if (!success)
			{
				// ... handle worker startup failure case
			}
			
		}
		public function AddBitmap(bmp:Bitmap,path:String):void{
			trace("Adding Bitmap: " + path);
			bitmapsToEncode.push([bmp, path]);
			if (!WORKER_WORKING) processBitmapQueueToImageWriterWorker();
		}
		
		
		public function processBitmapQueueToImageWriterWorker():void {
			
			if (bitmapsToEncode.length < 1) {
				trace("queue finished");
				return;
			}
			WORKER_WORKING = true;
			var tab:Array = bitmapsToEncode.shift();
			
			var bitmap:Bitmap = tab[0];
			
			trace("Processing Bitmap: " + worker.state);
			
			workerByteArrayShared.clear();
			trace("Clearing: " + workerByteArrayShared);
			bitmap.bitmapData.copyPixelsToByteArray(bitmap.bitmapData.rect, workerByteArrayShared);
					
			trace("SENDING TO WORKER: " + msgChannelMainToImageWriterWorker);
			msgChannelMainToImageWriterWorker.send({width:bitmap.width, height:bitmap.height, path:tab[1]});
		}

		public function messagesFromImageWriterWorker(evt:Event):void {
			trace("Getting MEssage from Image Writer Worker");
			if (msgChannelImageWriterToMainWorker.messageAvailable) {
				
				if (msgChannelImageWriterToMainWorker.receive() == "IMAGE_SAVED") {
					if (bitmapsToEncode.length < 1) WORKER_WORKING = false;
					processBitmapQueueToImageWriterWorker();
				}
			}
		}*/
		
	}
}