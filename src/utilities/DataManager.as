package utilities 
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.net.URLVariables;
	import utilities.PhpUtility;
	import flash.events.*;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class DataManager extends EventDispatcher
	{
		
		private var sqlConn:SQLConnection;
		private var dbFile:File;
		private var firstLoad:Boolean = true;
		private var COPY_COMPLETE:Boolean = true;
		private var sqlStat:SQLStatement;
		private var fs:FileStream;
		public var phpUtil:PhpUtility;
		public var accountsArray:Array = [];
		private var binFolder:File;
		public function DataManager() 
		{
			
		}
		
		public function CheckBaseStorage():void {
			var f:File = File.applicationStorageDirectory.resolvePath("CMH");
			var t:File = f.resolvePath("More.db");
			trace("AppStorage Directory binFolder= " + f.url);
			
				if (!t.exists) {		
					BinCopyBegin();
					trace("****BIN COPY BEGIN****");
				}else {				
					BeginHistoryCheck();
				}
		}
		
		public function BinCopyBegin():void {
			
			binFolder = File.applicationDirectory.resolvePath("CMH");
			
			trace("App Directory binFolder= " + binFolder.url);
			var binFolderCopy:File = File.applicationStorageDirectory.resolvePath("CMH");
		
			//trace("AppStorage Directory binFolder= " + binFolderCopy.nativePath);
			binFolder.addEventListener(Event.COMPLETE, onBinCopyComplete);
			binFolder.copyToAsync(binFolderCopy, true);
		}
		
		private function onBinCopyComplete(e:Event):void 
		{
			BeginHistoryCheck();
		}
		
				
		public function BeginHistoryCheck():void 
		{
			var folder:File = File.applicationStorageDirectory.resolvePath("CMH");
			dbFile = folder.resolvePath("More.db");
			connectToDB();			
		}
		
		private function connectToDB():void
		{
			sqlConn = new SQLConnection();
			sqlConn.addEventListener(SQLErrorEvent.ERROR, dbConnectionError);
			sqlConn.addEventListener(SQLEvent.OPEN, dbConnected);
			sqlConn.addEventListener(SQLEvent.CLOSE, dbClosed);
			
			sqlConn.openAsync(dbFile);
		}		
		
		//******** DB Connection Events **************//
		private function dbConnected(e:SQLEvent):void 
		{
			trace("Connected to Database");
			sqlConn.cacheSize = 4000;
			GetSettings();
			//GlobalVarContainer.MainBase.ShowAddUser();
		}
		
		private function dbClosed(e:SQLEvent):void 
		{
			trace("Database Connection Closed");
		}
		
		private function dbConnectionError(e:SQLErrorEvent):void 
		{
			trace("Connection Error Message: " + e.error.message);
			trace("Connection Error Details: " + e.error.details);
		}
		
		private function onFault(e:SQLErrorEvent):void {
			trace("CMH Controller Fault "+e.error.details);
		}
		
		//********************** GET ALL USERS ***********************//
		public function GetSettings():void {
			
				trace("Getting Settings");
				sqlStat = new SQLStatement();
				sqlStat.sqlConnection = sqlConn;
				
				var sql:String;
				sql = "";
				sql += "SELECT * FROM `Settings`";
				sqlStat.text = sql;			
					
				sqlStat.addEventListener(SQLEvent.RESULT, onGotAllSettings);
				sqlStat.addEventListener(SQLErrorEvent.ERROR, onFault);
				
				sqlStat.execute();	
			
		}
		
		private function onGotAllSettings(e:SQLEvent):void 
		{
			sqlStat.removeEventListener(SQLEvent.RESULT, onGotAllSettings);
			var statement:SQLStatement = e.target as SQLStatement;					
			
			var sqlResult:SQLResult = statement.getResult();
			var p:Object;
			if (sqlResult.data != null) {
				
					
					for each (var item:Object in sqlResult.data) {	
					//	trace("ID: " + item.User_ID);
						p = new Object();
						p.Tutorial = item.Tutorial;
						p.Age_Filter = item.Age_Filter;		
						p.Show_Ages = item.Show_Ages;				
					}				
					
					GlobalVarContainer.SHOW_TUTORIAL = (p.Tutorial == 1);
					if (p.Age_Filter == "" || p.Age_Filter == " "){
						GlobalVarContainer.AGE_RANGE = [];
					}else{
						GlobalVarContainer.AGE_RANGE = p.Age_Filter.split(",");
					}
					
					if (p.Show_Ages==1){
						GlobalVarContainer.SHOW_AGE_ICONS = true;
					}else{
						GlobalVarContainer.SHOW_AGE_ICONS = false;
					}
					trace("SETTINGS= TUT: " + GlobalVarContainer.SHOW_TUTORIAL + " /AGE: " + GlobalVarContainer.AGE_RANGE);
					
			}
			GlobalVarContainer.MainBase.loadContent();
			
		}	
		
		public function onSaveTutSettings(n:Boolean):void 
		{
			var sql:String;
			sql = "";
			
			if (n){
				sql += "UPDATE Settings SET `Tutorial` = 1 WHERE ID = 1";
				
			}else{
				sql += "UPDATE Settings SET `Tutorial` = 0 WHERE ID = 1";
			}
			sqlStat.text = sql;			
			//sqlStat.parameters["@NAME"] = uname;
			sqlStat.addEventListener(SQLEvent.RESULT, onTutSaved);
			sqlStat.addEventListener(SQLErrorEvent.ERROR, onFault);
			sqlStat.execute();
			
		}	
		
		private function onTutSaved(e:SQLEvent):void 
		{
			sqlStat.removeEventListener(SQLEvent.RESULT, onTutSaved);
			trace("TUT STATUS SAVED");
		}
		
		
		public function onSaveAgeSettings():void 
		{
			if(GlobalVarContainer.AGE_RANGE.length<1){
				var s:String = "";
			}else{
				s = GlobalVarContainer.AGE_RANGE.join(",");
			}
			
			var sql:String;
			sql = "";
			if(GlobalVarContainer.SHOW_AGE_ICONS){
				sql += "UPDATE Settings SET `Age_Filter` = '"+s+"', `Show_Ages` = 1 WHERE ID = 1";
			}else{				
				sql += "UPDATE Settings SET `Age_Filter` = '"+s+"', `Show_Ages` = 0 WHERE ID = 1";
			}
			sqlStat.text = sql;			
			//sqlStat.parameters["@NAME"] = uname;
			sqlStat.addEventListener(SQLEvent.RESULT, onAgeSaved);
			sqlStat.addEventListener(SQLErrorEvent.ERROR, onFault);
			sqlStat.execute();
			
		}	
		
		private function onAgeSaved(e:SQLEvent):void 
		{
			sqlStat.removeEventListener(SQLEvent.RESULT, onAgeSaved);
			trace("AGE FILTER STATUS SAVED");
		}
		
		//************ UTILITIES *************//
		public function GetDateFromTimestamp(ts:Number):String {
			var installDate:Date = new Date(ts); //timestamp_in_seconds*1000 - if you use a result of PHP time function, which returns it in seconds, and Flash uses milliseconds
				
				
			var D:Number = installDate.getDate();
			var M:Number = installDate.getMonth()+ 1; //because Returns the month (0 for January, 1 for February, and so on)
			var Y:Number = installDate.getFullYear();

			var theDate:String = (M + "/" + D + "/" + Y);
			return theDate;
		}
		
		
	}

}