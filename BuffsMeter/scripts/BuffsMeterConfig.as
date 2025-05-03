package
{
   import utils.Parser;
   
   public class BuffsMeterConfig
   {
      
      public static const STATE_HIDDEN:String = "hidden";
      
      public static const STATE_SHOWN:String = "shown";
      
      private static var _config:Object;
       
      
      public function BuffsMeterConfig()
      {
         super();
      }
      
      public static function get() : Object
      {
         return _config;
      }
      
      public static function init(jsonObject:*) : Object
      {
         var config:* = jsonObject;
         config.x = Parser.parseNumber(config.x,0);
         config.y = Parser.parseNumber(config.y,0);
         config.anchor = Boolean(config.anchor) ? config.anchor.toLowerCase() : "top";
         config.ySpacing = Parser.parseNumber(config.ySpacing,0);
         config.width = Parser.parseNumber(config.width,250);
         config.textSize = Parser.parseNumber(config.textSize,18);
         config.textFont = Boolean(config.textFont) ? config.textFont : "$ChowderHead";
         config.textAlign = Boolean(config.textAlign) ? config.textAlign.toLowerCase() : "left";
         config.textColor = Parser.parseNumber(config.textColor,16777215);
         config.textShadow = Parser.parseBoolean(config.textShadow,true);
         config.background = Parser.parseBoolean(config.background,false);
         config.backgroundColor = Parser.parseNumber(config.backgroundColor,0);
         config.alpha = Parser.parseNumber(config.alpha,1);
         config.backgroundAlpha = Parser.parseNumber(config.backgroundAlpha,0.5);
         config.blendMode = Boolean(config.blendMode) ? config.blendMode.toLowerCase() : "normal";
         config.textBlendMode = Boolean(config.textBlendMode) ? config.textBlendMode.toLowerCase() : "normal";
         config.refresh = Parser.parseNumber(config.refresh,1000);
         config.hidePermanentEffects = Boolean(config.hidePermanentEffects);
         config.hideEffectsBelowDuration = Parser.parseNumber(config.hideEffectsBelowDuration,-15);
         config.hideEffectsAboveDuration = Parser.parseNumber(config.hideEffectsAboveDuration,0);
         config.warningBelowDuration = Parser.parseNumber(config.warningBelowDuration,30);
         config.showSubEffects = Parser.parseBoolean(config.showSubEffects,true);
         config.showExpiredSubEffects = Parser.parseBoolean(config.showExpiredSubEffects,false);
         config.format = Boolean(config.format) ? config.format : "{duration} {text}";
         config.sortBy = Boolean(config.sortBy) ? config.sortBy.toLowerCase() : "default";
         config.reverseSort = Parser.parseBoolean(config.reverseSort,false);
         config.toggleVisibilityHotkey = Parser.parsePositiveNumber(config.toggleVisibilityHotkey,0);
         config.forceHideHotkey = Parser.parsePositiveNumber(config.forceHideHotkey,0);
         if(!config.formats)
         {
            config.formats = {};
            config.formats.subEffect = "   {text} {duration}";
            config.formats.expiredBuff = "Expired: {text} {time}ago";
            config.formats.checklist = "Not active: {text}";
         }
         else
         {
            if(!config.formats.subEffect)
            {
               config.formats.subEffect = "   {text} {duration}";
            }
            if(!config.formats.expiredBuff)
            {
               config.formats.expiredBuff = "Expired: {text} {time}ago";
            }
            if(!config.formats.checklist)
            {
               config.formats.checklist = "Not active: {text}";
            }
         }
         if(!config.sortOrder)
         {
            config.sortOrder = [];
         }
         else if(config.sortBy == "custom")
         {
            for(i in config.sortOrder)
            {
               config.sortOrder[i] = config.sortOrder[i].toLowerCase();
            }
         }
         if(!config.durationBar)
         {
            config.durationBar = {};
            config.durationBar.enabled = true;
            config.durationBar.alignVertical = "bottom";
            config.durationBar.alignHorizontal = "left";
            config.durationBar.height = 4;
         }
         else
         {
            config.durationBar.enabled = Parser.parseBoolean(config.durationBar.enabled,true);
            config.durationBar.alignVertical = Boolean(config.durationBar.alignVertical) ? config.durationBar.alignVertical.toLowerCase() : "bottom";
            config.durationBar.alignHorizontal = Boolean(config.durationBar.alignHorizontal) ? config.durationBar.alignHorizontal.toLowerCase() : "left";
            config.durationBar.height = Parser.parseNumber(config.durationBar.height,4);
         }
         if(!config.xpBar)
         {
            config.xpBar = {};
            config.xpBar.enabled = true;
            config.xpBar.text = "{text} {progress}% ({lastChangeValue})";
            config.xpBar.alignVertical = "bottom";
            config.xpBar.alignHorizontal = "left";
            config.xpBar.height = 4;
         }
         else
         {
            config.xpBar.enabled = Parser.parseBoolean(config.xpBar.enabled,true);
            config.xpBar.text = Boolean(config.xpBar.text) ? config.xpBar.text : "{text} {progress}% ({lastChangeValue})";
            config.xpBar.alignVertical = Boolean(config.xpBar.alignVertical) ? config.xpBar.alignVertical.toLowerCase() : "bottom";
            config.xpBar.alignHorizontal = Boolean(config.xpBar.alignHorizontal) ? config.xpBar.alignHorizontal.toLowerCase() : "left";
            config.xpBar.height = Parser.parseNumber(config.xpBar.height,4);
         }
         if(!config.scoreBar)
         {
            config.scoreBar = {};
            config.scoreBar.enabled = true;
            config.scoreBar.text = "SCORE [{currentRank}] {currentValue}/{thresholdValue} +{currentBoost}%";
            config.scoreBar.alignVertical = "bottom";
            config.scoreBar.alignHorizontal = "left";
            config.scoreBar.height = 4;
         }
         else
         {
            config.scoreBar.enabled = Parser.parseBoolean(config.scoreBar.enabled,true);
            config.scoreBar.text = Boolean(config.scoreBar.text) ? config.scoreBar.text : "SCORE [{currentRank}] {currentValue}/{thresholdValue} +{currentBoost}%";
            config.scoreBar.alignVertical = Boolean(config.scoreBar.alignVertical) ? config.scoreBar.alignVertical.toLowerCase() : "bottom";
            config.scoreBar.alignHorizontal = Boolean(config.scoreBar.alignHorizontal) ? config.scoreBar.alignHorizontal.toLowerCase() : "left";
            config.scoreBar.height = Parser.parseNumber(config.scoreBar.height,4);
         }
         if(!config.sortOrder)
         {
            config.sortOrder = [];
         }
         if(!config.displayData)
         {
            config.displayData = [];
         }
         if(!config.customGroups)
         {
            config.customGroups = {};
         }
         else
         {
            for(group in config.customGroups)
            {
               for(item in config.customGroups[group])
               {
                  config.customGroups[group][item] = config.customGroups[group][item].toLowerCase();
               }
            }
         }
         if(!config.customColors)
         {
            config.customColors = {};
            config.customColors.warning = 16777011;
            config.customColors.expired = 16724855;
            config.customColors.xpBar = 39168;
            config.customColors.durationBar = 39168;
            config.customColors.durationBarWarning = 10027161;
         }
         else
         {
            for(color in config.customColors)
            {
               config.customColors[color] = Parser.parseNumber(config.customColors[color],config.textColor);
            }
         }
         if(!config.customEffectColors)
         {
            config.customEffectColors = {};
            config.customEffectColors.keys = [];
         }
         else
         {
            var keys:Array = [];
            for(color in config.customEffectColors)
            {
               config.customEffectColors[color] = Parser.parseNumber(config.customEffectColors[color],config.textColor);
               keys.push(color);
            }
            config.customEffectColors.keys = keys;
         }
         if(!config.hideTypes)
         {
            config.hideTypes = [];
         }
         else
         {
            for(i in config.hideTypes)
            {
               config.hideTypes[i] = config.hideTypes[i].toLowerCase().replace("icon","");
            }
         }
         if(!config.showTypes)
         {
            config.showTypes = [];
         }
         else
         {
            for(i in config.showTypes)
            {
               config.showTypes[i] = config.showTypes[i].toLowerCase().replace("icon","");
            }
         }
         config.hideEffectsState = getState(config.hideEffectsState);
         if(!config.hideEffects)
         {
            config.hideEffects = [];
         }
         else
         {
            for(i in config.hideEffects)
            {
               config.hideEffects[i] = config.hideEffects[i].toLowerCase();
            }
         }
         if(!config.hideSubEffects)
         {
            config.hideSubEffects = [];
         }
         else
         {
            for(i in config.hideSubEffects)
            {
               config.hideSubEffects[i] = config.hideSubEffects[i].toLowerCase();
            }
         }
         if(!config.hideSubEffectsFor)
         {
            config.hideSubEffectsFor = [];
         }
         else
         {
            for(i in config.hideSubEffectsFor)
            {
               config.hideSubEffectsFor[i] = config.hideSubEffectsFor[i].toLowerCase();
            }
         }
         if(!config.debuffs)
         {
            config.debuffs = [];
         }
         else
         {
            for(i in config.debuffs)
            {
               config.debuffs[i] = config.debuffs[i].toLowerCase();
            }
         }
         if(config.checklistCompareMode.toLowerCase() == "starts")
         {
            config.checklistCompareMode = 0;
         }
         else if(config.checklistCompareMode.toLowerCase() == "exact")
         {
            config.checklistCompareMode = 1;
         }
         else
         {
            config.checklistCompareMode = 2;
         }
         if(!config.checklist)
         {
            config.checklist = [];
            config.checklistDisplay = {};
         }
         else
         {
            config.checklistDisplay = {};
            for(i in config.checklist)
            {
               var checklistItem:* = config.checklist[i];
               if(checklistItem is String)
               {
                  config.checklist[i] = [].concat(checklistItem.toLowerCase());
                  config.checklistDisplay[config.checklist[i][0]] = checklistItem;
               }
               else if(checklistItem is Array && checklistItem.length > 0)
               {
                  checklistItem = checklistItem[0];
                  for(j in config.checklist[i])
                  {
                     config.checklist[i][j] = config.checklist[i][j].toLowerCase();
                  }
                  config.checklistDisplay[config.checklist[i][0]] = checklistItem;
               }
               else
               {
                  config.checklist[i] = [];
               }
            }
         }
         config.HUDModesState = getState(config.HUDModesState);
         if(!config.HUDModes)
         {
            config.HUDModes = [];
         }
         _config = config;
         return _config;
      }
      
      private static function getState(data:Object) : String
      {
         if(!data)
         {
            return STATE_HIDDEN;
         }
         if(data.toLowerCase() == STATE_SHOWN)
         {
            return STATE_SHOWN;
         }
         return STATE_HIDDEN;
      }
   }
}
