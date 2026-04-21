package
{
   import flash.display.MovieClip;
   
   public class IPipBoyTab extends MovieClip
   {
      
      private var m_TabIndex:uint = 0;
      
      private var m_SelectedID:uint = 4294967295;
      
      public function IPipBoyTab()
      {
         super();
      }
      
      public function get SelectedID() : uint
      {
         return this.m_SelectedID;
      }
      
      public function get TabIndex() : uint
      {
         return this.m_TabIndex;
      }
      
      public function set TabIndex(param1:uint) : void
      {
         if(this.m_TabIndex != param1)
         {
            this.m_TabIndex = param1;
         }
      }
      
      public function SetPlatform(param1:uint, param2:Boolean, param3:uint, param4:uint) : void
      {
      }
      
      public function processProvider(param1:Object) : void
      {
      }
      
      public function ProcessUserEvent(param1:String) : Boolean
      {
         return false;
      }
      
      public function SetVisibility(param1:Boolean) : void
      {
         if(this.visible != param1)
         {
            if(param1)
            {
               this.OnEntry();
            }
            else
            {
               this.OnExit();
            }
            this.visible = param1;
         }
      }
      
      public function CanSwitchTabs(param1:String) : Boolean
      {
         return true;
      }
      
      public function OnEntry() : void
      {
      }
      
      public function OnExit() : void
      {
      }
      
      public function ProcessRightThumbstickInput(param1:uint) : Boolean
      {
         return false;
      }
   }
}

