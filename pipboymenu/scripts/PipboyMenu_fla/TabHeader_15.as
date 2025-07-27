package PipboyMenu_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol35")]
   public dynamic class TabHeader_15 extends MovieClip
   {
      
      public var AlphaHolder:MovieClip;
      
      public function TabHeader_15()
      {
         super();
         addFrameScript(0,this.frame1,4,this.frame5);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame5() : *
      {
         gotoAndStop(1);
      }
   }
}

