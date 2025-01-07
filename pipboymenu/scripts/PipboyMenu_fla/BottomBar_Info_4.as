package PipboyMenu_fla
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol70")]
   public dynamic class BottomBar_Info_4 extends MovieClip
   {
       
      
      public var AP_tf:TextField;
      
      public var Caps_tf:TextField;
      
      public var DMGDRWidget_mc:BB_DMGDRWidget;
      
      public var Date_tf:TextField;
      
      public var HPMeter:Pipboy_Meter;
      
      public var HP_tf:TextField;
      
      public var LVL_tf:TextField;
      
      public var Location_tf:TextField;
      
      public var Time_tf:TextField;
      
      public var Weight_tf:TextField;
      
      public var XPMeter_mc:Pipboy_Meter;
      
      public function BottomBar_Info_4()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}
