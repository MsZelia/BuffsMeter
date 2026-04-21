package Shared.AS3
{
   import Shared.GlobalFunc;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class BSButtonHintHoldProcessor extends EventDispatcher
   {
      
      private var m_ButtonHoldStartTimeout:int = -1;
      
      private var m_ButtonHolding:Boolean = false;
      
      private var m_CurrentHoldButton:BSButtonHintData = null;
      
      private var m_Owner:IMenu = null;
      
      public function BSButtonHintHoldProcessor(param1:IMenu)
      {
         super();
         this.m_Owner = param1;
      }
      
      public function reset() : *
      {
         this.stopButtonHold();
         this.m_CurrentHoldButton = null;
         this.m_ButtonHolding = false;
      }
      
      public function processButtonHold(param1:Object) : BSButtonHintData
      {
         var button:BSButtonHintData;
         var func:Function = null;
         var aData:Object = param1;
         if(!(this.m_Owner is IHoldHandler))
         {
            trace("ERROR: BSButtonHintHoldProcessor requires",this.m_Owner.name,"to implement IHoldHandler to process the completion of a hold.");
            return null;
         }
         button = aData.buttonsOrBar is Vector.<BSButtonHintData> ? this.findButtonHintDataForUserEvent(aData.buttonsOrBar,aData.eventName,false) : (aData.buttonsOrBar as BSButtonHintBar).FindButtonHintDataForUserEvent(aData.eventName,false);
         if(button != null && button.canHold)
         {
            if(Boolean(aData.pressed) && this.m_CurrentHoldButton == null)
            {
               this.m_CurrentHoldButton = button;
               if(this.m_ButtonHoldStartTimeout == -1)
               {
                  func = button.ButtonEnabled ? this.startButtonHold : function():*
                  {
                     m_ButtonHolding = true;
                  };
                  this.m_ButtonHoldStartTimeout = setTimeout(func,GlobalFunc.HOLD_METER_DELAY);
                  aData.handled = true;
               }
            }
            else if(!aData.pressed && this.m_CurrentHoldButton == button)
            {
               this.stopButtonHold();
               this.m_CurrentHoldButton = null;
               if(this.m_ButtonHolding)
               {
                  this.m_ButtonHolding = false;
                  aData.handled = true;
               }
               else
               {
                  button = aData.buttonsOrBar is Vector.<BSButtonHintData> ? this.findButtonHintDataForUserEvent(aData.buttonsOrBar,aData.eventName,true) : (aData.buttonsOrBar as BSButtonHintBar).FindButtonHintDataForUserEvent(aData.eventName,true);
               }
            }
            else
            {
               aData.handled = true;
            }
         }
         return button;
      }
      
      private function startButtonHold() : void
      {
         this.m_ButtonHolding = true;
         this.m_Owner.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function stopButtonHold() : *
      {
         if(this.m_ButtonHoldStartTimeout != -1)
         {
            clearTimeout(this.m_ButtonHoldStartTimeout);
            this.m_ButtonHoldStartTimeout = -1;
         }
         if(this.m_CurrentHoldButton)
         {
            this.m_CurrentHoldButton.holdPercent = 0;
         }
         this.m_Owner.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this.m_ButtonHolding && Boolean(this.m_CurrentHoldButton))
         {
            this.m_CurrentHoldButton.holdPercent = GlobalFunc.Clamp(this.m_CurrentHoldButton.holdPercent + GlobalFunc.HOLD_METER_TICK_AMOUNT,0,1);
            if(this.m_CurrentHoldButton.holdPercent >= 1)
            {
               (this.m_Owner as IHoldHandler).onButtonPressEvent(this.m_CurrentHoldButton.UserEvent,this.m_CurrentHoldButton.DispatchEvent,true);
               this.stopButtonHold();
            }
         }
      }
      
      public function findButtonHintDataForUserEvent(param1:Vector.<BSButtonHintData>, param2:String, param3:Boolean) : BSButtonHintData
      {
         var aButtons:Vector.<BSButtonHintData> = param1;
         var aUserEvent:String = param2;
         var abExcludeHoldButtons:Boolean = param3;
         var buttonData:BSButtonHintData = null;
         var sortByHold:Function = function(param1:BSButtonHintData, param2:BSButtonHintData):Number
         {
            if(param1.canHold && !param2.canHold)
            {
               return abExcludeHoldButtons ? 1 : -1;
            }
            if(!param1.canHold && param2.canHold)
            {
               return abExcludeHoldButtons ? -1 : 1;
            }
            return 0;
         };
         var sortedVec:Vector.<BSButtonHintData> = aButtons.concat().sort(sortByHold);
         var j:* = 0;
         while(j < aButtons.length)
         {
            if(sortedVec[j].UserEvent == aUserEvent && (!abExcludeHoldButtons || !sortedVec[j].canHold))
            {
               buttonData = sortedVec[j];
               break;
            }
            j++;
         }
         return buttonData;
      }
   }
}

