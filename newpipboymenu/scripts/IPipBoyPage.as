package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class IPipBoyPage extends MovieClip
   {
      
      private var m_CurrentTab:IPipBoyTab;
      
      private var m_CurrentTabIndex:uint = 0;
      
      private var m_PageData:Object;
      
      private var m_SharedData:Object;
      
      private var m_SelectedID:uint = 4294967295;
      
      private var m_Tabs:Vector.<IPipBoyTab> = new Vector.<IPipBoyTab>();
      
      protected var m_EventPrefix:String = "NULL::";
      
      public function IPipBoyPage()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      public function get CurrentTabIndex() : uint
      {
         return this.m_CurrentTabIndex;
      }
      
      public function set CurrentTabIndex(param1:uint) : *
      {
         if(this.m_CurrentTabIndex != param1)
         {
            this.m_CurrentTabIndex = param1;
         }
      }
      
      protected function get CurrentTab() : IPipBoyTab
      {
         return this.m_CurrentTab;
      }
      
      protected function set CurrentTab(param1:IPipBoyTab) : void
      {
         if(this.m_CurrentTab != param1)
         {
            this.m_CurrentTab = param1;
         }
      }
      
      public function get SharedData() : Object
      {
         return this.m_SharedData;
      }
      
      public function set SharedData(param1:Object) : void
      {
         this.m_SharedData = param1;
      }
      
      public function get PageData() : Object
      {
         return this.m_PageData;
      }
      
      public function set PageData(param1:Object) : void
      {
         this.m_PageData = param1;
      }
      
      public function get SelectedID() : uint
      {
         return this.m_CurrentTab != null ? this.m_CurrentTab.SelectedID : this.m_SelectedID;
      }
      
      public function set SelectedID(param1:uint) : *
      {
         this.m_SelectedID = param1;
      }
      
      public function get EventPrefix() : String
      {
         return this.m_EventPrefix;
      }
      
      public function AddTab(param1:IPipBoyTab) : void
      {
         if(this.m_Tabs.length == 0)
         {
            this.m_Tabs.push(null);
         }
         param1.SetVisibility(false);
         this.m_Tabs.push(param1);
      }
      
      public function SetVisibility(param1:Boolean) : void
      {
         this.SetTabVisibility(param1);
         var _loc2_:* = this.visible != param1;
         this.visible = param1;
         if(param1 && _loc2_)
         {
            this.OnEntry();
         }
      }
      
      protected function SetTabVisibility(param1:Boolean = true) : void
      {
         var _loc2_:uint = 0;
         while(_loc2_ < this.m_Tabs.length)
         {
            if(this.m_Tabs[_loc2_])
            {
               this.m_Tabs[_loc2_].SetVisibility(param1 && _loc2_ == this.m_CurrentTabIndex);
            }
            _loc2_++;
         }
      }
      
      public function CanSwitchTabs(param1:String, param2:int) : Boolean
      {
         var _loc3_:Boolean = true;
         if(this.m_Tabs.length != 0 && this.CurrentTab != null)
         {
            _loc3_ = this.CurrentTab.CanSwitchTabs(param1);
         }
         return _loc3_;
      }
      
      public function processProvider(param1:Object, param2:uint = 0) : void
      {
      }
      
      public function onAddedToStage(param1:Event) : void
      {
      }
      
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         return false;
      }
      
      public function SetPlatform(param1:uint, param2:Boolean, param3:uint, param4:uint) : void
      {
      }
      
      public function OnEntry() : void
      {
      }
      
      public function refreshCurrentTab() : void
      {
      }
      
      public function ProcessRightThumbstickInput(param1:uint) : Boolean
      {
         if(this.CurrentTab)
         {
            return this.CurrentTab.ProcessRightThumbstickInput(param1);
         }
         return false;
      }
   }
}

