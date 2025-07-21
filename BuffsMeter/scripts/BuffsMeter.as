package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import com.brokenfunction.json.JsonDecoderAsync;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import mx.utils.Base64Decoder;
   import scaleform.gfx.*;
   import utils.*;
   
   public class BuffsMeter extends MovieClip
   {
      
      public static const MOD_NAME:String = "BuffsMeter";
      
      public static const MOD_VERSION:String = "1.2.8";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      public static const CONFIG_FILE:String = "../BuffsMeter.json";
      
      public static const EFFECTS_FILE:String = "../BuffData.ini";
      
      public static const CONFIG_RELOAD_TIME:uint = 9950;
      
      public static const BUFFS_RELOAD_TIME:uint = 4950;
      
      public static const EFFECT_WORN_OFF_LOCALIZED:Array = [" has worn off"," ne fait plus effet"," se ha agotado"," se agotó"," wirkt nicht mehr"," - Effetto esaurito"," - efekty wygasły"," passou."," больше не действует","の効果が切れました"," 효과가 사라졌습니다.","的效力耗尽了。","的效力耗盡了。"];
      
      public static const EFFECT_NERD_RAGE_LOCALIZED:Array = ["Nerd Rage","Rage de nerd","Rabia de los sabiondos","Rabia nerd","Nerdwut","Furia nerd","Szał kujona","Fúria Nerd","Бешенство ботаника","범생이의 역습","忍无可忍","忍無可忍"];
      
      public static const EFFECT_TEAM_BONUS_LOCALIZED:Array = ["team bonus","bonus d\'équipe","bonificación de equipo","teambonus","bonus squadra",["premia","drużyny"],"bônus de equipe",["Бонус","команды"],"チームボーナス","팀 보너스","队伍加成","隊伍加成"];
      
      public static const ABBREVIATION_HOUR_LOCALIZED:Array = ["hr","h","H","St.","ч","시간"];
      
      public static const ABBREVIATION_MINUTE_LOCALIZED:Array = ["Min.","m","M","м","분","分鐘","分"];
      
      private static const DATA_SEPARATOR:String = "separator";
      
      private static const DATA_EMPTY_SPACE:String = "emptyspace";
      
      private static const DATA_TEXT:String = "text";
      
      private static const DATA_GROUP:String = "group";
      
      private static const DATA_DEBUFF:String = "debuffs";
      
      private static const DATA_EXPIRED:String = "expired";
      
      private static const DATA_WARNING:String = "warning";
      
      private static const SORT_BY_CUSTOM:String = "custom";
      
      private static const SORT_BY_PROPERTY:String = "property";
      
      private static const SORT_BY_DURATION:String = "duration";
      
      private static const SORT_BY_DURATION_REMAINING:String = "durationRemaining";
      
      private static const STRING_TEXT:String = "{text}";
      
      private static const STRING_TYPE:String = "{type}";
      
      private static const STRING_DURATION:String = "{duration}";
      
      private static const STRING_DURATION_FULL:String = "{durationFull}";
      
      private static const STRING_DURATION_IN_SECONDS:String = "{durationInSeconds}";
      
      private static const STRING_DURATION_IN_MINUTES:String = "{durationInMinutes}";
      
      private static const STRING_TIME:String = "{time}";
      
      private static const STRING_TIME_IN_SECONDS:String = "{timeInSeconds}";
      
      private static const STRING_TIME_IN_MINUTES:String = "{timeInMinutes}";
      
      private static const STRING_PROGRESS:String = "{progress}";
      
      private static const STRING_LAST_CHANGE_VALUE:String = "{lastChangeValue}";
      
      private static const STRING_CURRENT_VALUE:String = "{currentValue}";
      
      private static const STRING_THRESHOLD_VALUE:String = "{thresholdValue}";
      
      private static const STRING_CURRENT_LEVEL:String = "{currentLevel}";
      
      private static const STRING_CURRENT_RANK:String = "{currentRank}";
      
      private static const STRING_CURRENT_BOOST:String = "{currentBoost}";
      
      private static const FORMAT_EXPIRED_BUFF:String = "expiredBuff";
      
      private static const FORMAT_SUBEFFECT:String = "subEffect";
      
      private static const FORMAT_CHECKLIST:String = "checklist";
      
      private static const MAX_EXPIRED_BUFFS:int = 9;
      
      private static const MAIN_MENU:String = "MainMenu";
      
      private static const LOADING:String = "Loading";
      
      private static const BUFF_MSG_SYNC:String = "syncPipBuffData:";
      
      private static const HUDTOOLS_MENU_TOGGLE_CHECKLIST:String = MOD_NAME + "_TOGGLE_CHECKLIST";
      
      private static const HUDTOOLS_MENU_TOGGLE_VISIBILITY:String = MOD_NAME + "_TOGGLE_VISIBILITY";
      
      private static const HUDTOOLS_MENU_HIDE:String = MOD_NAME + "_HIDE";
       
      
      private var _lastUpdateTime:Number = 0;
      
      private var _lastUpdateTimeDelta:Number = 0;
      
      private var _lastConfigUpdateTime:Number = 0;
      
      private var _lastProcessEventsTime:Number = 0;
      
      private var _isProcessEvents:Boolean = false;
      
      private var _serverTime:Number = 0;
      
      private var _daysElapsed:int = 0;
      
      private var topLevel:* = null;
      
      private var HPMeter:* = null;
      
      private var XPMeter:* = null;
      
      private var HUDModeData:*;
      
      private var PublicTeamsData:*;
      
      private var PartyMenuList:*;
      
      private var AccountInfoData:*;
      
      private var CharacterInfoData:*;
      
      private var HUDMessageProvider:*;
      
      private var SeasonWidgetData:*;
      
      private var dummy_tf:TextField;
      
      private var textFormat:TextFormat;
      
      private var displayTimer:Timer;
      
      private var configTimer:Timer;
      
      private var buffsTimer:Timer;
      
      private var lastConfig:String;
      
      private var yOffset:Number = 0;
      
      public var BuffData:Object;
      
      private var lastBuffData:String = null;
      
      private var lastBuffMsgData:String = null;
      
      private var expiredBuffs:Vector.<Object>;
      
      private var lastRenderTime:Number = 0;
      
      private var effects_tf:Array;
      
      private var effects_index:int = 0;
      
      private var separators:Array;
      
      private var _effects:Array;
      
      private var isSortReversed:Boolean = false;
      
      private var isHudMenu:Boolean = false;
      
      private var isInMainMenu:Boolean = true;
      
      private var isPipboyMenu:Boolean = false;
      
      private var toggleVisibility:Boolean = false;
      
      private var checklistVisibility:Boolean = true;
      
      private var forceHide:Boolean = false;
      
      private var isLoading:Boolean = false;
      
      private var lastLoadingTimeStart:Number = 0;
      
      private var lastLoadingTimeEnd:Number = 0;
      
      private var loadingTimeComp:Number = 0;
      
      private var loadingCheckTimer:Timer;
      
      private var hudTools:SharedHUDTools;
      
      public function BuffsMeter()
      {
         this.effects_tf = [];
         this.separators = [];
         this.expiredBuffs = new Vector.<Object>();
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
         this.HUDMessageProvider = BSUIDataManager.GetDataFromClient("HUDMessageProvider");
         this.HUDModeData = BSUIDataManager.GetDataFromClient("HUDModeData");
         this.CharacterInfoData = BSUIDataManager.GetDataFromClient("CharacterInfoData");
         this.AccountInfoData = BSUIDataManager.GetDataFromClient("AccountInfoData");
         this.PublicTeamsData = BSUIDataManager.GetDataFromClient("PublicTeamsData");
         this.PartyMenuList = BSUIDataManager.GetDataFromClient("PartyMenuList");
         this.SeasonWidgetData = BSUIDataManager.GetDataFromClient("SeasonWidgetData");
         if(false)
         {
            BSUIDataManager.Subscribe("MessageEvents",this.onMessageEvent);
         }
         this.configTimer = new Timer(CONFIG_RELOAD_TIME);
         this.configTimer.addEventListener(TimerEvent.TIMER,this.loadConfig,false,0,true);
         this.configTimer.start();
         this.buffsTimer = new Timer(BUFFS_RELOAD_TIME);
         this.buffsTimer.addEventListener(TimerEvent.TIMER,this.loadEffects,false,0,true);
         this.buffsTimer.start();
         this.loadConfig();
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
      }
      
      public static function indexOfCaseInsensitiveStringStarts(arr:Array, searchingFor:String, fromIndex:uint = 0) : int
      {
         var lowercaseSearchString:String = searchingFor.toLowerCase();
         var arrayLength:uint = arr.length;
         var index:uint = fromIndex;
         while(index < arrayLength)
         {
            var element:* = arr[index];
            if(element is String && lowercaseSearchString.indexOf(element.toLowerCase()) == 0)
            {
               return index;
            }
            index++;
         }
         return -1;
      }
      
      public function onReceiveMessage(sender:String, msg:String) : void
      {
         ShowHUDMessage("Received message from " + sender + ": len " + msg.length);
         if(sender == "BuffsMeter_Pipboy")
         {
            var syncLen:int = BUFF_MSG_SYNC.length;
            if(msg.substr(0,syncLen) == BUFF_MSG_SYNC)
            {
               msg = msg.substr(syncLen);
               parseSyncMessage(msg);
            }
         }
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == "HUDMenu")
            {
               this.isHudMenu = true;
               this.isPipboyMenu = false;
               this.isInMainMenu = false;
               if(this.topLevel.LeftMeters_mc != null && this.topLevel.LeftMeters_mc.HPMeter_mc != null)
               {
                  this.HPMeter = this.topLevel.LeftMeters_mc.HPMeter_mc;
               }
               if(this.topLevel.HUDNotificationsGroup_mc != null && this.topLevel.HUDNotificationsGroup_mc.XPMeter_mc != null)
               {
                  this.XPMeter = this.topLevel.HUDNotificationsGroup_mc.XPMeter_mc;
               }
               this.initLoadingCompCheck();
               this.hudTools = new SharedHUDTools(MOD_NAME);
               this.hudTools.RegisterMenu(this.onBuildMenu,this.onSelectMenu);
               this.hudTools.Register(this.onReceiveMessage);
            }
            else if(this.topLevel.numChildren > 0)
            {
               if(getQualifiedClassName(this.topLevel.getChildAt(0)) == "PipboyMenu")
               {
                  this.topLevel = this.topLevel.getChildAt(0);
                  this.isHudMenu = false;
                  this.isPipboyMenu = true;
                  this.isInMainMenu = false;
                  stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
               }
               else if(getQualifiedClassName(this.topLevel.getChildAt(0)) == "OverlayMenu")
               {
                  this.topLevel = this.topLevel.getChildAt(0);
                  this.isHudMenu = false;
                  this.isPipboyMenu = false;
                  this.isInMainMenu = true;
                  BSUIDataManager.Subscribe("MenuStackData",this.updateIsMainMenu);
                  BSUIDataManager.Subscribe("HUDModeData",this.onHUDModeUpdate);
                  var comment:String = "Only key down (and not key up) registers in overlay menu. Why? I do not know.";
                  stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
               }
            }
            trace(MOD_NAME + " added to stage: " + getQualifiedClassName(this.topLevel));
         }
         else
         {
            trace(MOD_NAME + " not added to stage: " + getQualifiedClassName(this.topLevel));
            ShowHUDMessage("Not added to stage: " + getQualifiedClassName(this.topLevel));
         }
      }
      
      public function removedFromStageHandler(param1:Event) : *
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         if(stage)
         {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
         }
         if(this.configTimer)
         {
            this.configTimer.removeEventListener(TimerEvent.TIMER,this.loadConfig);
         }
         if(this.displayTimer)
         {
            this.displayTimer.removeEventListener(TimerEvent.TIMER,display);
         }
         if(this.buffsTimer)
         {
            this.buffsTimer.removeEventListener(TimerEvent.TIMER,this.loadEffects);
         }
         if(this.hudtools)
         {
            this.hudtools.Shutdown();
         }
      }
      
      public function onBuildMenu(parentItem:String = null) : *
      {
         try
         {
            if(parentItem == MOD_NAME)
            {
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_TOGGLE_CHECKLIST,"Toggle Checklist",true,false,250);
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_TOGGLE_VISIBILITY,"Toggle Visible",true,false,250);
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_HIDE,"Force Hide",true,false,250);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSelectMenu(selectItem:String) : *
      {
         if(selectItem == HUDTOOLS_MENU_TOGGLE_CHECKLIST)
         {
            this.checklistVisibility = !this.checklistVisibility;
         }
         else if(selectItem == HUDTOOLS_MENU_TOGGLE_VISIBILITY)
         {
            this.toggleVisibility = !this.toggleVisibility;
         }
         else if(selectItem == HUDTOOLS_MENU_HIDE)
         {
            this.forceHide = !this.forceHide;
         }
      }
      
      public function keyDownHandler(event:Event) : void
      {
         if(!config || !effects_tf)
         {
            return;
         }
         if(config.debugKeys)
         {
            displayMessage("keyDown: " + event.keyCode);
         }
         if(event.keyCode == config.toggleVisibilityHotkey)
         {
            this.toggleVisibility = !this.toggleVisibility;
         }
         if(event.keyCode == config.toggleChecklistHotkey)
         {
            this.checklistVisibility = !this.checklistVisibility;
         }
         if(event.keyCode == config.forceHideHotkey)
         {
            this.forceHide = !this.forceHide;
         }
      }
      
      private function updateIsMainMenu(event:FromClientDataEvent) : void
      {
         this.isInMainMenu = event.data && event.data.menuStackA && event.data.menuStackA.some(function(x:*):*
         {
            return x.menuName == MAIN_MENU;
         });
      }
      
      private function onHUDModeUpdate(event:*) : void
      {
         if(event == null || event.data == null)
         {
            return;
         }
         var prevLoading:Boolean = this.isLoading;
         this.isLoading = event.data.hudMode == LOADING;
         if(this.isLoading)
         {
            if(!prevLoading)
            {
               this.lastLoadingTimeStart = getTimer();
            }
         }
         else if(prevLoading)
         {
            this.lastLoadingTimeEnd = getTimer();
            if(this._lastProcessEventsTime > this.lastLoadingTimeStart)
            {
               this.loadingTimeComp += (this.lastLoadingTimeEnd - this._lastProcessEventsTime) / 1000;
            }
            else
            {
               this.loadingTimeComp += (this.lastLoadingTimeEnd - this.lastLoadingTimeStart) / 1000;
            }
         }
      }
      
      private function initLoadingCompCheck() : void
      {
         this.loadingCheckTimer = new Timer(20);
         this.loadingCheckTimer.addEventListener(TimerEvent.TIMER,function():void
         {
            onHUDModeUpdate(HUDModeData);
         },false,0,true);
         this.loadingCheckTimer.start();
      }
      
      private function clearHUDMessages() : void
      {
         if(this.isHudMenu)
         {
            var messages_mc:* = topLevel.HUDNotificationsGroup_mc.Messages_mc;
            var len:int = int(messages_mc.ShownMessageArray.length);
            var i:int = 0;
            while(i < len)
            {
               if(messages_mc.ShownMessageArray[i].data.messageID == id)
               {
                  messages_mc.ShownMessageArray[i].FadeOut();
                  break;
               }
               i++;
            }
         }
      }
      
      private function parseSyncMessage(msg:String) : void
      {
         var b64decoder:Base64Decoder = new Base64Decoder();
         b64decoder.decode(msg);
         var baZlib:ByteArray = b64decoder.toByteArray();
         baZlib.uncompress("zlib");
         var messageTextUncompressed:String = baZlib.readObject();
         messageTextUncompressed = messageTextUncompressed.replace(/\"x\":/g,"\"text\":").replace(/\"n\":/g,"\"iconText\":").replace(/\"y\":/g,"\"type\":").replace(/\"f\":/g,"\"effects\":").replace(/\"v\":/g,"\"value\":").replace(/\"d\":/g,"\"duration\":").replace(/\"p\":/g,"\"showAsPercent\":").replace(/\"i\":/g,"\"initTime\":").replace(/\"c\":/g,"\"setAsCustomDesc\":").replace(/\"k\":/g,"\"keywordSortIndex\":").replace(/\"m\":/g,"\"PlusMinus\":");
         if(this.lastBuffMsgData != messageTextUncompressed)
         {
            var jsonData:Object = new JSONDecoder(messageTextUncompressed,true).getValue();
            if(jsonData && jsonData.time && jsonData.serverTime && jsonData.activeEffects)
            {
               BuffData = jsonData;
               ServerTime = jsonData.serverTime;
               processEvents();
               isSortReversed = false;
               loadingTimeComp = 0;
               lastBuffMsgData = messageTextUncompressed;
            }
         }
      }
      
      private function onMessageEvent(event:FromClientDataEvent) : void
      {
         var messageData:*;
         var wornOffIndex:int;
         var wornOffItem:String;
         var syncLen:int;
         var messageText:String;
         var messageTextUncompressed:String;
         var messageIndex:int = 0;
         var errorCode:String = "init";
         try
         {
            if(config == null || !config.enableManualPipBuffDataSync || this.HUDMessageProvider.data.messages == null)
            {
               return;
            }
            while(messageIndex < this.HUDMessageProvider.data.messages.length)
            {
               errorCode = "messageData";
               messageData = this.HUDMessageProvider.data.messages[messageIndex];
               errorCode = "syncLen";
               syncLen = BUFF_MSG_SYNC.length;
               if(messageData != null && messageData.messageText != null && messageData.messageText.substr(0,syncLen) == BUFF_MSG_SYNC)
               {
                  errorCode = "messageText.substr";
                  messageText = messageData.messageText.substr(BUFF_MSG_SYNC.length);
                  errorCode = "parseSyncMessage";
                  parseSyncMessage(messageText);
               }
               if(false)
               {
                  wornOffIndex = this.getIsWornOffIndex(messageData.messageText);
                  if(wornOffIndex != -1)
                  {
                     wornOffItem = String(messageData.messageText.substring(0,wornOffIndex));
                     if(isValidEffectText(wornOffItem))
                     {
                        this.addExpiredBuff(wornOffItem);
                     }
                     if(this.BuffData && this.BuffData.activeEffects)
                     {
                        this.BuffData.activeEffects = this.BuffData.activeEffects.filter(function(element:*, index:int, array:Array):Boolean
                        {
                           return element.text.indexOf(wornOffItem) == -1;
                        });
                     }
                  }
               }
               messageIndex++;
            }
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error onMessageEvent: " + errorCode + ", " + e);
         }
      }
      
      public function loadConfig() : void
      {
         var loaderComplete:Function;
         var ioErrorHandler:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            if(config && Boolean(config.disableRealTimeEdit))
            {
               return;
            }
            loaderComplete = function(param1:Event):void
            {
               var jsonData:Object;
               try
               {
                  if(lastConfig != loader.data)
                  {
                     jsonData = new JSONDecoder(loader.data,true).getValue();
                     BuffsMeterConfig.init(jsonData);
                     if(isPipboyMenu && config.pipboyConfig)
                     {
                        for(p in config.pipboyConfig)
                        {
                           config[p] = config.pipboyConfig[p];
                        }
                     }
                     initTextField();
                     initTimers();
                     _lastConfigUpdateTime = getTimer();
                     if(BuffData && BuffData.activeEffects)
                     {
                        processEvents();
                     }
                     lastConfig = loader.data;
                  }
               }
               catch(e:Error)
               {
                  ShowHUDMessage("Error parsing config: " + e);
               }
            };
            ioErrorHandler = function(param1:*):void
            {
               ShowHUDMessage("Error loading config: " + param1.text);
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete,false,0,true);
            loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error loading config: " + e);
         }
      }
      
      public function loadEffects() : void
      {
         var loaderComplete:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            if(this.isPipboyMenu)
            {
               return;
            }
            loaderComplete = function(param1:Event):void
            {
               var jsonData:Object;
               var decoder:JsonDecoderAsync;
               try
               {
                  if(lastBuffData != loader.data)
                  {
                     decoder = new JsonDecoderAsync(loader.data,false);
                     if(!decoder.process())
                     {
                        ShowHUDMessage("JSONDecoderAsync error: " + decoder.result);
                        return;
                     }
                     jsonData = decoder.result;
                     if(jsonData && jsonData.time && jsonData.serverTime && jsonData.activeEffects)
                     {
                        if(lastBuffData == null && jsonData.time + 15000 < new Date().time)
                        {
                           return;
                        }
                        BuffData = jsonData;
                        ServerTime = jsonData.serverTime;
                        processEvents();
                        isSortReversed = false;
                        loadingTimeComp = 0;
                        lastBuffData = loader.data;
                     }
                  }
               }
               catch(e:Error)
               {
                  ShowHUDMessage("Error loading buffs from file: " + e);
               }
            };
            url = new URLRequest(EFFECTS_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete,false,0,true);
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error loading effects: " + e);
         }
      }
      
      private function initTextField() : void
      {
         this.dummy_tf = new TextField();
         this.formatMessage();
      }
      
      private function initTimers() : void
      {
         if(this.displayTimer)
         {
            displayTimer.removeEventListener(TimerEvent.TIMER,display);
         }
         this.displayTimer = new Timer(config.refresh);
         this.displayTimer.addEventListener(TimerEvent.TIMER,display,false,0,true);
         this.displayTimer.start();
      }
      
      public function get config() : Object
      {
         return BuffsMeterConfig.get();
      }
      
      public function get elapsedTime() : Number
      {
         return getTimer() / 1000;
      }
      
      public function get timeSinceLastUpdate() : Number
      {
         return (getTimer() - this._lastUpdateTime + this._lastUpdateTimeDelta) / 1000;
      }
      
      public function get timeSinceLastConfigUpdate() : Number
      {
         return (getTimer() - this._lastConfigUpdateTime) / 1000;
      }
      
      public function get ServerTime() : Number
      {
         return this._serverTime + this.timeSinceLastUpdate * 20;
      }
      
      public function set ServerTime(value:Number) : void
      {
         this._daysElapsed = Math.floor(this.ServerTime / 86400);
         if(this._serverTime == 0 && this._daysElapsed == 0)
         {
            this._daysElapsed = 1;
         }
         this._serverTime = this._daysElapsed * 86400 + value * 3600;
         this._lastUpdateTime = getTimer();
         this._lastUpdateTimeDelta = new Date().time - this.BuffData.time;
      }
      
      public function addExpiredBuff(text:String) : void
      {
         this.expiredBuffs = this.expiredBuffs.filter(function(expired:Object):Boolean
         {
            return expired.text != text;
         });
         if(this.expiredBuffs.length > MAX_EXPIRED_BUFFS)
         {
            this.expiredBuffs.splice(0,this.expiredBuffs.length - MAX_EXPIRED_BUFFS);
         }
         this.expiredBuffs.push({
            "text":text,
            "time":getTimer()
         });
      }
      
      public function get requiredLevelUpXP() : int
      {
         return Math.min(this.CharacterInfoData.data.level,999) * 160 + 40;
      }
      
      public function formatMessage() : void
      {
         this.dummy_tf.text = MOD_VERSION;
         this.dummy_tf.x = config.x;
         this.dummy_tf.y = config.y;
         this.dummy_tf.width = config.width;
         this.dummy_tf.background = false;
         TextFieldEx.setTextAutoSize(this.dummy_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         this.dummy_tf.autoSize = TextFieldAutoSize.LEFT;
         this.dummy_tf.wordWrap = false;
         this.dummy_tf.multiline = true;
         this.dummy_tf.visible = true;
         this.textFormat = new TextFormat(config.textFont,config.textSize,config.textColor);
         this.textFormat.align = config.textAlign;
         this.dummy_tf.defaultTextFormat = this.textFormat;
         this.dummy_tf.setTextFormat(this.textFormat);
         this.dummy_tf.filters = [new DropShadowFilter(2,45,0,1,1,1,1,BitmapFilterQuality.HIGH)];
         this.alpha = config.alpha;
         this.blendMode = config.blendMode;
         resetMessages(true);
      }
      
      public function resetMessages(setFormat:Boolean = false) : void
      {
         this.separators = [];
         this.effects_index = 0;
         this.yOffset = 0;
         this.graphics.clear();
         for each(effect_tf in effects_tf)
         {
            if(effect_tf != null)
            {
               effect_tf.visible = false;
               if(setFormat)
               {
                  effect_tf.defaultTextFormat = this.textFormat;
                  effect_tf.setTextFormat(this.textFormat);
                  effect_tf.filters = Boolean(config.textShadow) ? this.dummy_tf.filters : [];
                  effect_tf.blendMode = config.textBlendMode;
               }
               else
               {
                  effect_tf.textColor = config.textColor;
               }
            }
         }
      }
      
      public function createTextfield() : TextField
      {
         tf = new TextField();
         tf.multiline = false;
         tf.wordWrap = false;
         tf.defaultTextFormat = this.textFormat;
         TextFieldEx.setTextAutoSize(tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         tf.setTextFormat(this.textFormat);
         if(config)
         {
            tf.filters = Boolean(config.textShadow) ? this.dummy_tf.filters : [];
            tf.blendMode = config.textBlendMode;
         }
         addChild(tf);
         return tf;
      }
      
      public function applyConfig(tf:TextField) : void
      {
         tf.x = config.x;
         tf.background = false;
         tf.width = config.width;
         tf.height = this.dummy_tf.height;
         if(effects_index == 0)
         {
            tf.y = config.y;
         }
         else
         {
            tf.y = LastDisplayEffect.y + LastDisplayEffect.height + config.ySpacing + yOffset;
            yOffset = 0;
         }
         tf.visible = true;
      }
      
      public function displayMessage(text:String) : void
      {
         if(effects_tf.length < effects_index || effects_tf[effects_index] == null)
         {
            effects_tf[effects_index] = createTextfield();
         }
         applyConfig(effects_tf[effects_index]);
         effects_tf[effects_index].text = text;
         effects_index++;
      }
      
      public function drawBackground() : void
      {
         if(config.background)
         {
            this.graphics.beginFill(config.backgroundColor,config.backgroundAlpha);
            this.graphics.drawRect(config.x,config.y,config.width,LastDisplayEffect.y + LastDisplayEffect.height - config.y);
            this.graphics.endFill();
         }
         if(config.anchor == "bottom")
         {
            this.y = -(LastDisplayEffect.y + LastDisplayEffect.height - config.y);
         }
         else if(this.y != 0)
         {
            this.y = 0;
         }
      }
      
      public function drawEffectDurationBar(effect:Object) : void
      {
         if(config.durationBar.enabled)
         {
            var lastEff:Object = effects_tf[effect.id];
            var duration:Number = Math.min(effect.duration,effect.durationMax);
            var barWidth:Number = duration / effect.durationMax * config.width;
            switch(config.durationBar.alignVertical)
            {
               case "top":
                  var barY:Number = Number(lastEff.y);
                  break;
               case "center":
                  barY = lastEff.y + lastEff.height / 2 - config.durationBar.height / 2;
                  break;
               case "bottom":
               default:
                  barY = lastEff.y + lastEff.height - config.durationBar.height;
            }
            switch(config.durationBar.alignHorizontal)
            {
               case "right":
                  var barX:Number = lastEff.x + config.width - barWidth;
                  break;
               case "center":
                  barX = lastEff.x + config.width / 2 - barWidth / 2;
                  break;
               case "left":
               default:
                  barX = Number(lastEff.x);
            }
            if(duration < config.warningBelowDuration)
            {
               var barColor:Number = getCustomColor("durationBarWarning");
            }
            else
            {
               barColor = getCustomColor("durationBar");
            }
            this.graphics.beginFill(barColor);
            this.graphics.drawRect(barX,barY,barWidth,config.durationBar.height);
            this.graphics.endFill();
         }
      }
      
      public function drawXPBar(xpBar:Object) : void
      {
         if(xpBar != null && config.xpBar.enabled)
         {
            var lastEff:Object = effects_tf[xpBar.id];
            var barWidth:Number = xpBar.progress * config.width;
            switch(config.xpBar.alignVertical)
            {
               case "top":
                  var barY:Number = Number(lastEff.y);
                  break;
               case "center":
                  barY = lastEff.y + lastEff.height / 2 - config.xpBar.height / 2;
                  break;
               case "bottom":
               default:
                  barY = lastEff.y + lastEff.height - config.xpBar.height;
            }
            switch(config.xpBar.alignHorizontal)
            {
               case "right":
                  var barX:Number = lastEff.x + config.width - barWidth;
                  break;
               case "center":
                  barX = lastEff.x + config.width / 2 - barWidth / 2;
                  break;
               case "left":
               default:
                  barX = Number(lastEff.x);
            }
            var barColor:Number = getCustomColor("xpBar");
            this.graphics.beginFill(barColor);
            this.graphics.drawRect(barX,barY,barWidth,config.xpBar.height);
            this.graphics.endFill();
         }
      }
      
      public function drawBar(bar:Object, barConfig:Object, barColorName:String) : void
      {
         if(bar != null && barConfig.enabled)
         {
            var lastEff:Object = effects_tf[bar.id];
            var barWidth:Number = bar.progress * config.width;
            switch(barConfig.alignVertical)
            {
               case "top":
                  var barY:Number = Number(lastEff.y);
                  break;
               case "center":
                  barY = lastEff.y + lastEff.height / 2 - barConfig.height / 2;
                  break;
               case "bottom":
               default:
                  barY = lastEff.y + lastEff.height - barConfig.height;
            }
            switch(barConfig.alignHorizontal)
            {
               case "right":
                  var barX:Number = lastEff.x + config.width - barWidth;
                  break;
               case "center":
                  barX = lastEff.x + config.width / 2 - barWidth / 2;
                  break;
               case "left":
               default:
                  barX = Number(lastEff.x);
            }
            var barColor:Number = getCustomColor(barColorName);
            this.graphics.beginFill(barColor);
            this.graphics.drawRect(barX,barY,barWidth,barConfig.height);
            this.graphics.endFill();
         }
      }
      
      public function get LastDisplayEffect() : TextField
      {
         if(effects_index == 0)
         {
            return effects_tf[effects_index];
         }
         return effects_tf[effects_index - 1];
      }
      
      public function customSort(objA:Object, objB:Object) : int
      {
         var indexA:int = int.MAX_VALUE;
         var indexB:int = int.MAX_VALUE;
         var textA:String = (objA.text + objA.type).toLowerCase();
         var textB:String = (objB.text + objB.type).toLowerCase();
         config.sortOrder.forEach(function(phrase:String, index:int, array:Array):void
         {
            if(textA.indexOf(phrase) != -1 && index < indexA)
            {
               indexA = index;
            }
            if(textB.indexOf(phrase) != -1 && index < indexB)
            {
               indexB = index;
            }
         });
         if(indexA < indexB)
         {
            return -1;
         }
         if(indexA > indexB)
         {
            return 1;
         }
         return textA.localeCompare(textB);
      }
      
      public function getCustomColor(name:String) : Number
      {
         if(config.customColors[name] != null)
         {
            return config.customColors[name];
         }
         return config.textColor;
      }
      
      public function applyColor(name:String) : Boolean
      {
         if(config.customColors[name] != null)
         {
            LastDisplayEffect.textColor = config.customColors[name];
            return true;
         }
         return false;
      }
      
      public function applyEffectColor(name:String) : Boolean
      {
         var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(config.customEffectColors.keys,name));
         if(index != -1)
         {
            LastDisplayEffect.textColor = config.customEffectColors[config.customEffectColors.keys[index]];
            return true;
         }
         return false;
      }
      
      public function addSeparator(data:String) : void
      {
         var t1:Number = Number(getTimer());
         if(data == null || data.length == 0)
         {
            return;
         }
         data = data.replace(" ","");
         var parts:Array = data.split(":");
         var color:Number = Number(config.textColor);
         if(parts.length > 1)
         {
            var height:Number = Number(Parser.parseNumber(parts[1],0));
            if(parts.length > 2)
            {
               color = Number(Parser.parseNumber(parts[2],getCustomColor(parts[2])));
            }
            if(effects_index == 0)
            {
               var y:Number = Number(config.y);
            }
            else
            {
               y = LastDisplayEffect.y + LastDisplayEffect.height + config.ySpacing / 2 + yOffset;
            }
            yOffset += height;
            separators.push({
               "y":y,
               "height":height,
               "color":color
            });
         }
         if(config.tdisplayGroup)
         {
            displayMessage("addSeparator: " + (getTimer() - t1) + "ms");
         }
      }
      
      public function addEmptySpace(data:String) : void
      {
         var t1:Number = Number(getTimer());
         if(data == null || data.length == 0)
         {
            return;
         }
         var parts:Array = data.split(":");
         var space:Number = Number(Parser.parseNumber(parts[1],0));
         yOffset += space;
         if(config.tdisplayGroup)
         {
            displayMessage("addEmptySpace: " + (getTimer() - t1) + "ms");
         }
      }
      
      public function addCustomText(data:String) : void
      {
         var t1:Number = Number(getTimer());
         if(data == null || data.length == 0)
         {
            return;
         }
         data = StringUtil.replace(data,"/:","_COLON_");
         var parts:Array = data.split(":");
         if(parts.length == 3)
         {
            var color:Number = Number(Parser.parseNumber(parts[1],getCustomColor(parts[1])));
            var text:String = parts[2];
            text = StringUtil.replace(text,"_COLON_",":");
            displayMessage(text);
            LastDisplayEffect.textColor = color;
         }
      }
      
      public function sortEffects(effects:Array, isInit:Boolean = false) : Array
      {
         var defaultSort:Boolean = false;
         switch(config.sortBy)
         {
            case SORT_BY_CUSTOM:
               if(isInit)
               {
                  effects.sort(customSort);
               }
               break;
            case SORT_BY_PROPERTY:
               var sortOptions:Array = new Array(config.sortOrder.length);
               var p:int = 0;
               while(p < config.sortOrder.length)
               {
                  if(config.sortOrder[p] == SORT_BY_DURATION_REMAINING || config.sortOrder[p] == SORT_BY_DURATION)
                  {
                     sortOptions[p] = Array.NUMERIC | Array.DESCENDING;
                  }
                  else
                  {
                     sortOptions[p] = Array.CASEINSENSITIVE;
                  }
                  p++;
               }
               effects = effects.sortOn(config.sortOrder,sortOptions);
               break;
            default:
               defaultSort = true;
         }
         if(!defaultSort && config.reverseSort || config.reverseSort ^ isSortReversed)
         {
            effects.reverse();
            isSortReversed = !isSortReversed;
         }
         return effects;
      }
      
      public function processEvents() : void
      {
         var i:int;
         var t1:*;
         var errorCode:String = "processEvents";
         try
         {
            if(this.BuffData && this.BuffData.activeEffects)
            {
               i = 0;
               t1 = getTimer();
               while(i < this.BuffData.activeEffects.length)
               {
                  errorCode = "type";
                  this.BuffData.activeEffects[i].type = String(this.BuffData.activeEffects[i].type.toLowerCase().replace("icon",""));
                  errorCode = "isDebuff";
                  this.BuffData.activeEffects[i].isDebuff = this.isTextInList(this.BuffData.activeEffects[i].text,!!config ? config.debuffs : []);
                  errorCode = "textDuration";
                  this.BuffData.activeEffects[i].textDuration = getTimeFromName(this.BuffData.activeEffects[i].text);
                  errorCode = "duration";
                  if(this.BuffData.activeEffects[i].effects[0].duration == null)
                  {
                     this.BuffData.activeEffects[i].effects[0].duration = 0;
                  }
                  errorCode = "isPermanentEffect";
                  this.BuffData.activeEffects[i].isPermanentEffect = this.BuffData.activeEffects[i].effects[0].duration == 0;
                  errorCode = "isPermanentEffect2";
                  if(!this.BuffData.activeEffects[i].isPermanentEffect && this.BuffData.activeEffects[i].text.lastIndexOf("(") != -1)
                  {
                     this.BuffData.activeEffects[i].effectText = String(this.BuffData.activeEffects[i].text.slice(0,this.BuffData.activeEffects[i].text.lastIndexOf("(") - 1));
                  }
                  else
                  {
                     this.BuffData.activeEffects[i].effectText = this.BuffData.activeEffects[i].text;
                  }
                  errorCode = "isValid";
                  this.BuffData.activeEffects[i].isValid = this.isValidEffect(this.BuffData.activeEffects[i].type,this.BuffData.activeEffects[i].effectText);
                  errorCode = "SubEffects";
                  this.BuffData.activeEffects[i].SubEffects = [];
                  errorCode = "effects";
                  for each(effect in this.BuffData.activeEffects[i].effects)
                  {
                     this.BuffData.activeEffects[i].SubEffects.push({
                        "text":(Boolean(effect.usesCustomDesc) ? effect.text : effect.text + (effect.value > 0 ? " +" : " ") + (effect.value % 1 == 0 ? effect.value : effect.value.toFixed(2)) + (Boolean(effect.showAsPercent) ? "%" : "")),
                        "durationRemaining":-1
                     });
                  }
                  i++;
               }
               if(config && config.sortBy == SORT_BY_CUSTOM)
               {
                  this.BuffData.activeEffects = sortEffects(this.BuffData.activeEffects,true);
               }
               errorCode = "lastProcessEventsTime";
               this._lastProcessEventsTime = getTimer() - t1;
               errorCode = "isProcessEvents";
               this._isProcessEvents = true;
            }
         }
         catch(e:Error)
         {
            throw new Error(errorCode + ": " + e);
         }
      }
      
      public function showBGSChildren() : void
      {
         if(!this.topLevel)
         {
            return;
         }
         for(c in this.topLevel.BGSCodeObj)
         {
            displayMessage(c + ":" + this.topLevel.BGSCodeObj[c]);
         }
      }
      
      public function showHUDChildren() : void
      {
         if(!this.topLevel)
         {
            return;
         }
         var i:int = 0;
         while(i < this.topLevel.numChildren)
         {
            if(this.topLevel.getChildAt(i) is Loader)
            {
               displayMessage(i + ":" + getQualifiedClassName(this.topLevel.getChildAt(i).content));
            }
            else
            {
               displayMessage(i + ":" + getQualifiedClassName(this.topLevel.getChildAt(i)));
            }
            i++;
         }
      }
      
      public function display() : void
      {
         var updated:Boolean;
         var i:int;
         var j:int;
         var time:Number;
         var date:Date;
         var effectInitTime:Number;
         var effectDuration:Number;
         var effectDurationRemaining:Number;
         var maxEffectDurationRemaining:Number;
         var maxEffectDuration:Number;
         var effectDurationBars:Array;
         var xpBar:Object;
         var scoreBar:Object;
         var teamBonus:int;
         var parts:Array;
         var sub:Object;
         var t2:Number;
         var _timeSinceLastUpdate:Number;
         var expiredBuffsIndex:* = 1;
         var t1:* = getTimer();
         var errorCode:String = "init";
         try
         {
            if(this.isInMainMenu)
            {
               this.BuffData = null;
            }
            errorCode = "visible";
            this.visible = !this.forceHide && this.isValidHUDMode() ^ this.toggleVisibility;
            if(!this.visible)
            {
               return;
            }
            errorCode = "rst";
            this.resetMessages();
            errorCode = "dbg";
            if(config.displayData.indexOf("debug") != -1)
            {
               displayMessage("topLevel: " + getQualifiedClassName(this.topLevel));
               displayMessage("isHudMenu: " + this.isHudMenu);
               displayMessage("isPipboyMenu: " + this.isPipboyMenu);
               displayMessage("isInMainMenu: " + this.isInMainMenu);
               displayMessage("isProcessEvents: " + this._isProcessEvents);
               displayMessage("BuffData: " + this.BuffData);
               if(this.BuffData != null)
               {
                  displayMessage("BuffData.activeEffects: " + this.BuffData.activeEffects);
                  if(this.BuffData.activeEffects != null)
                  {
                     displayMessage("BuffData.activeEffects.l: " + this.BuffData.activeEffects.length);
                  }
               }
            }
            errorCode = "sfe";
            if((this.BuffData == null || this.BuffData.activeEffects == null) && this.isHudMenu && !this.isSFEDefined() && !config.enableManualPipBuffDataSync)
            {
               displayMessage(FULL_MOD_NAME);
               displayMessage("SFE not found, ManualSync off");
               LastDisplayEffect.textColor = 16711680;
               if(!config.hideSFEMessage)
               {
                  displayMessage("Make sure SFE dxgi.dll is in game");
                  displayMessage("folder and not in data folder");
                  displayMessage("");
                  displayMessage("If game was recently updated, you");
                  displayMessage("will have to wait for SFE update");
                  displayMessage("");
                  displayMessage("Download latest version of SFE:");
                  displayMessage("www.nexusmods.com/fallout76");
                  displayMessage("/mods/287");
                  displayMessage("");
                  displayMessage("To hide this message, edit config:");
                  displayMessage("\"hideSFEMessage\": true");
               }
               drawBackground();
               return;
            }
            errorCode = "buffData";
            if(this.BuffData == null || this.BuffData.activeEffects == null)
            {
               displayMessage(FULL_MOD_NAME + (this.isHudMenu ? "" : (this.isPipboyMenu ? " (pipMenu)" : " (overlay)")));
               displayMessage("Effects not found, open your pipboy");
               LastDisplayEffect.textColor = 16711680;
               drawBackground();
               return;
            }
            errorCode = "displayData";
            if(config.displayData && config.displayData.length > 0)
            {
               date = new Date();
               time = this.ServerTime % 43200 / 60;
               for each(add in config.displayData)
               {
                  if(add == "showHUDChildren")
                  {
                     showHUDChildren();
                  }
                  else if(add == "showBGSChildren")
                  {
                     showBGSChildren();
                  }
                  else if(add == "showIsLoading")
                  {
                     displayMessage("isLoading: " + this.isLoading + ", last: " + this.lastLoadingTimeStart + " - " + this.lastLoadingTimeEnd);
                     displayMessage("loadComp: " + this.loadingTimeComp);
                  }
                  else if(add == "showVersion")
                  {
                     displayMessage(FULL_MOD_NAME + (this.isHudMenu ? "" : (this.isPipboyMenu ? " (pipMenu)" : " (overlay)")));
                     applyColor(add);
                  }
                  else if(add == "showLastUpdate")
                  {
                     displayMessage("LastUpdate: " + GlobalFunc.FormatTimeString(this.timeSinceLastUpdate) + " ago");
                     applyColor(add);
                  }
                  else if(add == "showLastConfigUpdate")
                  {
                     displayMessage("ConfigUpdate: " + GlobalFunc.FormatTimeString(this.timeSinceLastConfigUpdate) + " ago");
                     applyColor(add);
                  }
                  else if(add == "showLastDataProcessTime")
                  {
                     displayMessage("DataProcessing: " + this._lastProcessEventsTime + "ms");
                     applyColor(add);
                  }
                  else if(add == "showElapsedTime")
                  {
                     displayMessage("ElapsedTime: " + GlobalFunc.FormatTimeString(this.elapsedTime));
                     applyColor(add);
                  }
                  else if(add == "showServerTick")
                  {
                     displayMessage("ServerTick: " + this.ServerTime.toFixed(0));
                     applyColor(add);
                  }
                  else if(add == "showServerTime")
                  {
                     displayMessage("ServerTime: " + GlobalFunc.FormatTimeString(this.ServerTime));
                     applyColor(add);
                  }
                  else if(add == "showLastExpiredBuff")
                  {
                     if(this.expiredBuffs.length - expiredBuffsIndex >= 0)
                     {
                        displayMessage(formatExpiredBuff(this.expiredBuffs[this.expiredBuffs.length - expiredBuffsIndex],expiredBuffsIndex));
                        applyColor(add + expiredBuffsIndex);
                        expiredBuffsIndex++;
                     }
                  }
                  else if(add == "showHUDMode")
                  {
                     displayMessage("HUDMode: " + (!this.isInMainMenu ? this.HUDModeData.data.hudMode : MAIN_MENU));
                     applyColor(add);
                  }
                  else if(add == "showRenderTime")
                  {
                     displayMessage("RenderTime: " + this.lastRenderTime + "ms");
                     applyColor(add);
                  }
                  else if(add == "showServerTime12")
                  {
                     displayMessage("ServerTime: " + GlobalFunc.FormatTimeString(time < 60 ? time + 720 : time) + (this.ServerTime % 86400 > 43200 ? " PM" : " AM"));
                     applyColor(add);
                  }
                  else if(add == "showServerTime24")
                  {
                     displayMessage("ServerTime: " + GlobalFunc.FormatTimeString(this.ServerTime % 86400 / 60));
                     applyColor(add);
                  }
                  else if(add == "showTime12")
                  {
                     displayMessage("Time: " + (date.hours == 0 ? 12 : date.hours % 12) + ":" + (date.minutes < 10 ? "0" + date.minutes : date.minutes) + (date.hours > 12 ? " PM" : " AM"));
                     applyColor(add);
                  }
                  else if(add == "showTime24")
                  {
                     displayMessage("Time: " + date.hours + ":" + (date.minutes < 10 ? "0" + date.minutes : date.minutes));
                     applyColor(add);
                  }
                  else if(add == "showChecklist")
                  {
                     errorCode = "Checklist";
                     if(Boolean(checklistVisibility))
                     {
                        if(config.checklistCompareMode == 0)
                        {
                           errorCode = "Checklist 0";
                           for each(checkName in config.checklist)
                           {
                              if(!this.BuffData.activeEffects.some(function(buff:Object):Boolean
                              {
                                 if(buff.isValid)
                                 {
                                    return ArrayUtil.indexOfCaseInsensitiveStringStarts(checkName,buff.effectText) != -1;
                                 }
                                 return false;
                              }))
                              {
                                 displayMessage(config.formats[FORMAT_CHECKLIST].replace(STRING_TEXT,checkName.length == 0 || config.checklistDisplay[checkName[0]] == null ? checkName : config.checklistDisplay[checkName[0]]));
                                 applyColor(add);
                              }
                           }
                        }
                        else if(config.checklistCompareMode == 1)
                        {
                           errorCode = "Checklist 1";
                           for each(checkName in config.checklist)
                           {
                              if(!this.BuffData.activeEffects.some(function(buff:Object):Boolean
                              {
                                 if(buff.isValid)
                                 {
                                    return checkName.indexOf(buff.effectText.toLowerCase()) != -1;
                                 }
                                 return false;
                              }))
                              {
                                 displayMessage(config.formats[FORMAT_CHECKLIST].replace(STRING_TEXT,checkName.length == 0 || config.checklistDisplay[checkName[0]] == null ? checkName : config.checklistDisplay[checkName[0]]));
                                 applyColor(add);
                              }
                           }
                        }
                        else
                        {
                           errorCode = "Checklist 2";
                           for each(checkName in config.checklist)
                           {
                              if(!this.BuffData.activeEffects.some(function(buff:Object):Boolean
                              {
                                 if(buff.isValid)
                                 {
                                    return ArrayUtil.indexOfCaseInsensitiveString(checkName,buff.effectText) != -1;
                                 }
                                 return false;
                              }))
                              {
                                 displayMessage(config.formats[FORMAT_CHECKLIST].replace(STRING_TEXT,checkName.length == 0 || config.checklistDisplay[checkName[0]] == null ? checkName : config.checklistDisplay[checkName[0]]));
                                 applyColor(add);
                              }
                           }
                        }
                     }
                  }
                  else if(add == "showXPBar")
                  {
                     if(this.XPMeter)
                     {
                        displayMessage(formatXPBarText());
                        applyColor(add);
                        if(config.xpBar.enabled)
                        {
                           xpBar = {
                              "id":effects_index - 1,
                              "progress":this.XPMeter.LevelUPBar.Percent
                           };
                        }
                     }
                  }
                  else if(add == "showScoreBar")
                  {
                     if(this.SeasonWidgetData.data && this.SeasonWidgetData.data.currentRank)
                     {
                        displayMessage(formatScoreBarText());
                        applyColor(add);
                        if(config.scoreBar.enabled)
                        {
                           scoreBar = {
                              "id":effects_index - 1,
                              "progress":this.SeasonWidgetData.data.currentRank.nValuePosition / this.SeasonWidgetData.data.currentRank.nValueThreshold
                           };
                        }
                     }
                  }
                  else if(add.indexOf(DATA_TEXT) == 0)
                  {
                     addCustomText(add);
                  }
               }
            }
            errorCode = "timeSinceLastUpdate";
            _timeSinceLastUpdate = this.timeSinceLastUpdate;
            i = 0;
            while(i < this.BuffData.activeEffects.length)
            {
               if(this.BuffData.activeEffects[i].isValid)
               {
                  effectDuration = Number(this.BuffData.activeEffects[i].textDuration);
                  effectDurationRemaining = effectDuration - _timeSinceLastUpdate + this.loadingTimeComp;
                  maxEffectDurationRemaining = int.MIN_VALUE;
                  maxEffectDuration = 0;
                  if(!this.BuffData.activeEffects[i].isPermanentEffect)
                  {
                     maxEffectDurationRemaining = effectDurationRemaining;
                  }
                  j = 0;
                  while(j < this.BuffData.activeEffects[i].effects.length)
                  {
                     if(!this.BuffData.activeEffects[i].isPermanentEffect)
                     {
                        effectInitTime = Number(this.BuffData.activeEffects[i].effects[j].initTime);
                        effectDuration = !isNaN(this.BuffData.activeEffects[i].effects[j].duration) ? this.BuffData.activeEffects[i].effects[j].duration * 20 : 0;
                        maxEffectDuration = Math.max(maxEffectDuration,effectDuration);
                        effectDurationRemaining = (effectInitTime + effectDuration - ServerTime) / 20 + this.loadingTimeComp;
                        if(GlobalFunc.CloseToNumber(maxEffectDurationRemaining,effectDurationRemaining,61))
                        {
                           if(GlobalFunc.CloseToNumber(effectDurationRemaining,0,61))
                           {
                              maxEffectDurationRemaining = Math.min(maxEffectDurationRemaining,effectDurationRemaining);
                           }
                           else
                           {
                              maxEffectDurationRemaining = effectDurationRemaining;
                           }
                        }
                        this.BuffData.activeEffects[i].SubEffects[j].durationRemaining = effectDurationRemaining;
                     }
                     else
                     {
                        this.BuffData.activeEffects[i].SubEffects[j].durationRemaining = -1;
                     }
                     j++;
                  }
                  this.BuffData.activeEffects[i].duration = maxEffectDuration;
                  this.BuffData.activeEffects[i].durationRemaining = maxEffectDurationRemaining;
               }
               else
               {
                  this.BuffData.activeEffects[i].durationRemaining = -1;
                  this.BuffData.activeEffects[i].duration = 0;
               }
               i++;
            }
            errorCode = "sort";
            effectDurationBars = [];
            this.BuffData.activeEffects = sortEffects(this.BuffData.activeEffects);
            errorCode = "display";
            i = 0;
            while(i < this.BuffData.activeEffects.length)
            {
               if(this.BuffData.activeEffects[i].isValid)
               {
                  if(this.BuffData.activeEffects[i].isPermanentEffect)
                  {
                     if(!config.hidePermanentEffects)
                     {
                        displayMessage(formatEffect(this.BuffData.activeEffects[i]));
                        if(this.BuffData.activeEffects[i].isDebuff)
                        {
                           LastDisplayEffect.textColor = getCustomColor(DATA_DEBUFF);
                        }
                        else
                        {
                           applyEffectColor(this.BuffData.activeEffects[i].effectText);
                        }
                     }
                  }
                  else if(this.BuffData.activeEffects[i].durationRemaining < 1)
                  {
                     displayMessage(formatEffect(this.BuffData.activeEffects[i]));
                     LastDisplayEffect.textColor = getCustomColor(DATA_EXPIRED);
                  }
                  else if(config.hideEffectsAboveDuration == 0 || config.hideEffectsAboveDuration > 0 && this.BuffData.activeEffects[i].durationRemaining <= config.hideEffectsAboveDuration)
                  {
                     displayMessage(formatEffect(this.BuffData.activeEffects[i]));
                     if(this.BuffData.activeEffects[i].durationRemaining < config.warningBelowDuration)
                     {
                        LastDisplayEffect.textColor = getCustomColor(DATA_WARNING);
                     }
                     else if(this.BuffData.activeEffects[i].isDebuff)
                     {
                        LastDisplayEffect.textColor = getCustomColor(DATA_DEBUFF);
                     }
                     else
                     {
                        applyEffectColor(this.BuffData.activeEffects[i].effectText);
                     }
                     effectDurationBars.push({
                        "id":effects_index - 1,
                        "duration":this.BuffData.activeEffects[i].durationRemaining,
                        "durationMax":this.BuffData.activeEffects[i].duration / 20
                     });
                  }
                  if(config.showSubEffects && !isHiddenSubEffectFor(this.BuffData.activeEffects[i].type,this.BuffData.activeEffects[i].effectText))
                  {
                     for each(sub in this.BuffData.activeEffects[i].SubEffects)
                     {
                        if(!isHiddenSubEffect(sub.text))
                        {
                           if(!this.BuffData.activeEffects[i].isPermanentEffect)
                           {
                              if(config.showExpiredSubEffects || sub.durationRemaining >= config.hideEffectsBelowDuration)
                              {
                                 displayMessage(formatSubEffect(sub.text,Math.max(sub.durationRemaining,0)));
                                 if(sub.durationRemaining < 0)
                                 {
                                    LastDisplayEffect.textColor = getCustomColor(DATA_EXPIRED);
                                 }
                                 else if(sub.durationRemaining < config.warningBelowDuration)
                                 {
                                    LastDisplayEffect.textColor = getCustomColor(DATA_WARNING);
                                 }
                              }
                           }
                           else
                           {
                              displayMessage(formatSubEffect(sub.text,-1));
                           }
                        }
                     }
                  }
               }
               if(!this.BuffData.activeEffects[i].isPermanentEffect && this.BuffData.activeEffects[i].durationRemaining < config.hideEffectsBelowDuration)
               {
                  this.addExpiredBuff(BuffData.activeEffects[i].effectText);
                  this.BuffData.activeEffects.splice(i,1);
               }
               else
               {
                  i++;
               }
            }
            errorCode = "bg";
            drawBackground();
            errorCode = "dur";
            effectDurationBars.forEach(drawEffectDurationBar);
            errorCode = "xpbar";
            drawBar(xpBar,config.xpBar,"xpBar");
            errorCode = "scoreBar";
            drawBar(scoreBar,config.scoreBar,"scoreBar");
            this.lastRenderTime = getTimer() - t1;
         }
         catch(error:Error)
         {
            displayMessage("Error displaying effects - " + errorCode + ": " + error);
         }
      }
      
      public function formatTimeString(time:Number) : String
      {
         var remainingTime:Number = 0;
         var nDays:Number = Math.floor(time / 86400);
         remainingTime = time % 86400;
         var nHours:Number = Math.floor(remainingTime / 3600);
         remainingTime = time % 3600;
         var nMinutes:Number = Math.floor(remainingTime / 60);
         remainingTime = time % 60;
         var nSeconds:Number = Math.floor(remainingTime);
         var isValueSet:Boolean = false;
         var timeString:* = "";
         if(nDays > 0)
         {
            timeString = GlobalFunc.PadNumber(nDays,2) + ":";
         }
         timeString += GlobalFunc.PadNumber(nHours,2) + ":";
         timeString += GlobalFunc.PadNumber(nMinutes,2) + ":";
         return timeString + GlobalFunc.PadNumber(nSeconds,2);
      }
      
      public function formatXPBarText() : String
      {
         return config.xpBar.text.replace(STRING_TEXT,this.XPMeter.xptext.text).replace(STRING_CURRENT_LEVEL,this.CharacterInfoData.data.level).replace(STRING_CURRENT_VALUE,int(this.requiredLevelUpXP * this.XPMeter.LevelUPBar.Percent)).replace(STRING_THRESHOLD_VALUE,this.requiredLevelUpXP).replace(STRING_PROGRESS,(100 * this.XPMeter.LevelUPBar.Percent).toFixed(1)).replace(STRING_LAST_CHANGE_VALUE,this.XPMeter.PlusSign.text + this.XPMeter.NumberText.text);
      }
      
      public function formatScoreBarText() : String
      {
         return config.scoreBar.text.replace(STRING_CURRENT_VALUE,this.SeasonWidgetData.data.currentRank.nValuePosition).replace(STRING_THRESHOLD_VALUE,this.SeasonWidgetData.data.currentRank.nValueThreshold).replace(STRING_PROGRESS,(100 * (this.SeasonWidgetData.data.currentRank.nValuePosition / this.SeasonWidgetData.data.currentRank.nValueThreshold)).toFixed(1)).replace(STRING_CURRENT_RANK,this.SeasonWidgetData.data.currentRank.nRankNumber).replace(STRING_CURRENT_BOOST,this.SeasonWidgetData.data.uBoostAmount);
      }
      
      public function formatEffect(effect:Object) : String
      {
         if(!effect)
         {
            return "ERROR: null formatEffect0";
         }
         if(effect.isPermanentEffect)
         {
            return StringUtil.trim(config.format.replace(STRING_TEXT,effect.effectText).replace(STRING_TYPE,effect.type).replace(STRING_DURATION,"").replace(STRING_DURATION_FULL,"").replace(STRING_DURATION_IN_SECONDS,"").replace(STRING_DURATION_IN_MINUTES,""));
         }
         var duration:Number = Math.max(effect.durationRemaining,0);
         return config.format.replace(STRING_TEXT,effect.effectText).replace(STRING_TYPE,effect.type).replace(STRING_DURATION,GlobalFunc.FormatTimeString(duration)).replace(STRING_DURATION_FULL,formatTimeString(duration)).replace(STRING_DURATION_IN_SECONDS,Math.floor(duration) + "s").replace(STRING_DURATION_IN_MINUTES,(duration < 60 ? "<" : "") + Math.ceil(duration / 60) + "m");
      }
      
      public function formatEffectWithText(effect:Object, text:String) : String
      {
         if(!effect)
         {
            return "ERROR: null formatEffect1";
         }
         if(effect.isPermanentEffect)
         {
            return StringUtil.trim(config.format.replace(STRING_TEXT,text).replace(STRING_TYPE,effect.type).replace(STRING_DURATION,"").replace(STRING_DURATION_FULL,"").replace(STRING_DURATION_IN_SECONDS,"").replace(STRING_DURATION_IN_MINUTES,""));
         }
         var duration:Number = Math.max(effect.durationRemaining,0);
         return config.format.replace(STRING_TEXT,text).replace(STRING_TYPE,effect.type).replace(STRING_DURATION,GlobalFunc.FormatTimeString(duration)).replace(STRING_DURATION_FULL,formatTimeString(duration)).replace(STRING_DURATION_IN_SECONDS,Math.floor(duration) + "s").replace(STRING_DURATION_IN_MINUTES,(duration < 60 ? "<" : "") + Math.ceil(duration / 60) + "m");
      }
      
      public function formatSubEffect(text:String, duration:Number) : String
      {
         if(duration < 0)
         {
            return config.formats[FORMAT_SUBEFFECT].replace(STRING_TEXT,text).replace(STRING_DURATION,"").replace(STRING_DURATION_FULL,"").replace(STRING_DURATION_IN_SECONDS,"").replace(STRING_DURATION_IN_MINUTES,"");
         }
         return config.formats[FORMAT_SUBEFFECT].replace(STRING_TEXT,text).replace(STRING_DURATION,GlobalFunc.FormatTimeString(duration)).replace(STRING_DURATION_FULL,formatTimeString(duration)).replace(STRING_DURATION_IN_SECONDS,Math.floor(duration) + "s").replace(STRING_DURATION_IN_MINUTES,(duration < 60 ? "<" : "") + Math.ceil(duration / 60) + "m");
      }
      
      public function formatExpiredBuff(buff:Object, index:int) : String
      {
         if(!buff)
         {
            return "ERROR: null formatExpiredBuff " + index;
         }
         var time:Number = (getTimer() - buff.time) / 1000;
         return config.formats[FORMAT_EXPIRED_BUFF].replace(STRING_TEXT,buff.text).replace(STRING_TIME,GlobalFunc.FormatTimeString(time)).replace(STRING_TIME_IN_SECONDS,Math.floor(time)).replace(STRING_TIME_IN_MINUTES,Math.floor(time / 60));
      }
      
      public function getRandomColor() : String
      {
         var color:String = "00000" + Math.floor(Math.random() * 16777215).toString(16).toLowerCase();
         return color.substring(color.length - 6);
      }
      
      public function getIsWornOffIndex(message:String) : int
      {
         var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(EFFECT_WORN_OFF_LOCALIZED,message));
         if(index != -1)
         {
            return index;
         }
         return -1;
      }
      
      public function isTextInList(text:String, list:Array) : Boolean
      {
         var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(list,text));
         return index != -1;
      }
      
      public function isNerdRage(message:String) : Boolean
      {
         if(this.HPMeter && this.HPMeter.MeterBar_mc)
         {
            var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(EFFECT_NERD_RAGE_LOCALIZED,message));
            return index != -1;
         }
         return false;
      }
      
      public function isTeamBonus(message:String) : Boolean
      {
         var allMatch:Boolean = false;
         var msg:String = message.toLowerCase();
         for each(teamBonus in EFFECT_TEAM_BONUS_LOCALIZED)
         {
            if(teamBonus is String)
            {
               if(msg.indexOf(teamBonus) != -1)
               {
                  return true;
               }
            }
            else
            {
               allMatch = true;
               for each(part in teamBonus)
               {
                  if(msg.indexOf(part) == -1)
                  {
                     allMatch = false;
                  }
               }
               if(allMatch)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getTeamBonus() : int
      {
         var teamBonus:int = 0;
         if(this.PartyMenuList.data && this.PartyMenuList.data.teamType != 0)
         {
            var accountName:String = Boolean(this.AccountInfoData.data) ? this.AccountInfoData.data.name : "-";
            var bondTime:Number = 300;
            for each(member in this.PartyMenuList.data.members)
            {
               if(member.isVisible && member.level > 0 && member.currentBondTime >= bondTime || accountName == member.name)
               {
                  teamBonus++;
               }
            }
         }
         return teamBonus;
      }
      
      public function isValidEffect(type:String, text:String) : Boolean
      {
         if(!config)
         {
            return true;
         }
         if(config.hideTypes.length > 0)
         {
            var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(config.hideTypes,type));
            if(index != -1)
            {
               return false;
            }
         }
         if(config.showTypes.length > 0)
         {
            index = int(ArrayUtil.indexOfCaseInsensitiveString(config.showTypes,type));
            if(index != -1)
            {
               return true;
            }
         }
         var isStateHidden:Boolean = config.hideEffectsState == BuffsMeterConfig.STATE_HIDDEN;
         index = int(ArrayUtil.indexOfCaseInsensitiveString(config.hideEffects,text));
         if(isStateHidden)
         {
            return index == -1;
         }
         return index != -1;
      }
      
      public function isValidEffectType(type:String) : Boolean
      {
         if(!config)
         {
            return true;
         }
         var isStateHidden:Boolean = config.hideTypesState == BuffsMeterConfig.STATE_HIDDEN;
         if(config.hideTypes.length > 0)
         {
            var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(config.hideTypes,type));
            if(isStateHidden)
            {
               return index == -1;
            }
            return index != -1;
         }
         return isStateHidden;
      }
      
      public function isValidEffectText(text:String) : Boolean
      {
         if(!config)
         {
            return true;
         }
         var isStateHidden:Boolean = config.hideEffectsState == BuffsMeterConfig.STATE_HIDDEN;
         if(config.hideEffects.length > 0)
         {
            var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(config.hideEffects,text));
            if(isStateHidden)
            {
               return index == -1;
            }
            return index != -1;
         }
         return isStateHidden;
      }
      
      public function isHiddenSubEffect(name:String) : Boolean
      {
         var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(config.hideSubEffects,name));
         if(index != -1)
         {
            return true;
         }
         return false;
      }
      
      public function isHiddenSubEffectFor(type:String, name:String) : Boolean
      {
         var index:int = int(ArrayUtil.indexOfCaseInsensitiveString(config.hideSubEffectsFor,name + "|" + type));
         return index != -1;
      }
      
      public function getSubEffectDescription(effect:Object) : String
      {
         if(effect.usesCustomDesc)
         {
            return effect.text;
         }
         return effect.text + (effect.value > 0 ? " +" : " ") + (effect.value % 1 == 0 ? effect.value : effect.value.toFixed(2)) + (Boolean(effect.showAsPercent) ? "%" : "");
      }
      
      public function getTimeFromName(name:String) : int
      {
         if(name.lastIndexOf("(") != -1)
         {
            var parts:Array = name.split("(");
            var s_time:String = String(parts[parts.length - 1]);
            s_time = s_time.substring(0,s_time.indexOf(")")).replace("<","").replace(" ","");
            for each(minuteAbbr in ABBREVIATION_MINUTE_LOCALIZED)
            {
               s_time = s_time.replace(minuteAbbr,"");
            }
            for each(hourAbbr in ABBREVIATION_HOUR_LOCALIZED)
            {
               parts = s_time.split(hourAbbr);
               if(parts.length > 1)
               {
                  break;
               }
            }
            var hours:int = 0;
            var minutes:int = 0;
            if(parts.length > 1)
            {
               hours = int(parseInt(parts[0]));
               minutes = int(parseInt(parts[1]));
            }
            else
            {
               minutes = int(parseInt(parts[0]));
            }
            return (hours * 60 + minutes) * 60;
         }
         return -1;
      }
      
      public function isValidHUDMode() : Boolean
      {
         if(config)
         {
            if(config.HUDModesState == BuffsMeterConfig.STATE_HIDDEN)
            {
               return this.isInMainMenu ? config.HUDModes.indexOf(MAIN_MENU) == -1 : config.HUDModes.indexOf(this.HUDModeData.data.hudMode) == -1;
            }
            return this.isInMainMenu ? config.HUDModes.indexOf(MAIN_MENU) != -1 : config.HUDModes.indexOf(this.HUDModeData.data.hudMode) != -1;
         }
         return true;
      }
      
      public function isSFEDefined() : Boolean
      {
         return this.topLevel && this.topLevel.__SFCodeObj != null && this.topLevel.__SFCodeObj.call != null;
      }
   }
}
