package
{
   import utils.*;
   
   public class BuffsMeterConfig
   {
      
      private static var _config:Object;
      
      public static const STATE_HIDDEN:String = "hidden";
      
      public static const STATE_SHOWN:String = "shown";
      
      public static const DEFAULT_FORMAT:String = "{duration} | {text}";
      
      public static const DEFAULT_EXPIRED_BUFF_FORMAT:String = "Expired: {text} ({timeInMinutes}m)";
      
      public static const DEFAULT_SUB_EFFECT_FORMAT:String = "   {text}";
      
      public static const DEFAULT_CHECKLIST_FORMAT:String = "Not active: {text}";
      
      public static const DEFAULT_RAID_XP_FORMAT:String = "Raid XP: {xp}";
      
      public static const DEFAULT_HUD_MODE_FORMAT:String = "HUDMode: {HUDMode}";
      
      public static const DEFAULT_RENDER_TIME_FORMAT:String = "RenderTime: {time}ms";
      
      public static const DEFAULT_ELAPSED_TIME_FORMAT:String = "ElapsedTime: {time}";
      
      public static const DEFAULT_LAST_UPDATE_FORMAT:String = "LastUpdate: {time} ago";
      
      public static const DEFAULT_LAST_CONFIG_UPDATE_FORMAT:String = "ConfigUpdated: {time} ago";
      
      public static const DEFAULT_LAST_DATA_PROCESSING_FORMAT:String = "DataProcessing: {time}ms";
      
      public static const DEFAULT_TIME_12_FORMAT:String = "Time: {time}";
      
      public static const DEFAULT_TIME_24_FORMAT:String = "Time: {time}";
      
      public static const DEFAULT_XP_BAR_FORMAT:String = "{text} [{currentLevel}] {currentValue}/{thresholdValue} {progress}% ({lastChangeValue})";
      
      public static const DEFAULT_SCORE_BAR_FORMAT:String = "SCORE [{currentRank}] {currentValue}/{thresholdValue} +{currentBoost}%";
      
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
         config.format = Boolean(config.format) ? config.format : DEFAULT_FORMAT;
         config.sortBy = Boolean(config.sortBy) ? config.sortBy.toLowerCase() : "default";
         config.reverseSort = Parser.parseBoolean(config.reverseSort,false);
         config.toggleVisibilityHotkey = Buttons.parseValue(config.toggleVisibilityHotkey);
         config.forceHideHotkey = Buttons.parseValue(config.forceHideHotkey);
         config.toggleChecklistHotkey = Buttons.parseValue(config.toggleChecklistHotkey);
         config.checklistHiddenByDefault = Parser.parseBoolean(config.checklistHiddenByDefault,false);
         if(!config.formats)
         {
            config.formats = {};
            config.formats.subEffect = DEFAULT_SUB_EFFECT_FORMAT;
            config.formats.expiredBuff = DEFAULT_EXPIRED_BUFF_FORMAT;
            config.formats.checklist = DEFAULT_CHECKLIST_FORMAT;
            config.formats.showRaidXP = DEFAULT_RAID_XP_FORMAT;
            config.formats.showHUDMode = DEFAULT_HUD_MODE_FORMAT;
            config.formats.showRenderTime = DEFAULT_RENDER_TIME_FORMAT;
            config.formats.showElapsedTime = DEFAULT_ELAPSED_TIME_FORMAT;
            config.formats.showLastUpdate = DEFAULT_LAST_UPDATE_FORMAT;
            config.formats.showLastConfigUpdate = DEFAULT_LAST_CONFIG_UPDATE_FORMAT;
            config.formats.showLastDataProcessTime = DEFAULT_LAST_DATA_PROCESSING_FORMAT;
            config.formats.showTime12 = DEFAULT_TIME_12_FORMAT;
            config.formats.showTime24 = DEFAULT_TIME_24_FORMAT;
         }
         else
         {
            if(!config.formats.subEffect)
            {
               config.formats.subEffect = DEFAULT_SUB_EFFECT_FORMAT;
            }
            if(!config.formats.expiredBuff)
            {
               config.formats.expiredBuff = DEFAULT_EXPIRED_BUFF_FORMAT;
            }
            if(!config.formats.checklist)
            {
               config.formats.checklist = DEFAULT_CHECKLIST_FORMAT;
            }
            if(!config.formats.showRaidXP)
            {
               config.formats.showRaidXP = DEFAULT_RAID_XP_FORMAT;
            }
            if(!config.formats.showHUDMode)
            {
               config.formats.showHUDMode = DEFAULT_HUD_MODE_FORMAT;
            }
            if(!config.formats.showRenderTime)
            {
               config.formats.showRenderTime = DEFAULT_RENDER_TIME_FORMAT;
            }
            if(!config.formats.showElapsedTime)
            {
               config.formats.showElapsedTime = DEFAULT_ELAPSED_TIME_FORMAT;
            }
            if(!config.formats.showLastUpdate)
            {
               config.formats.showLastUpdate = DEFAULT_LAST_UPDATE_FORMAT;
            }
            if(!config.formats.showLastConfigUpdate)
            {
               config.formats.showLastConfigUpdate = DEFAULT_LAST_CONFIG_UPDATE_FORMAT;
            }
            if(!config.formats.showLastDataProcessTime)
            {
               config.formats.showLastDataProcessTime = DEFAULT_LAST_DATA_PROCESSING_FORMAT;
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
            config.durationBar.maxDuration = 600;
         }
         else
         {
            config.durationBar.enabled = Parser.parseBoolean(config.durationBar.enabled,true);
            config.durationBar.alignVertical = Boolean(config.durationBar.alignVertical) ? config.durationBar.alignVertical.toLowerCase() : "bottom";
            config.durationBar.alignHorizontal = Boolean(config.durationBar.alignHorizontal) ? config.durationBar.alignHorizontal.toLowerCase() : "left";
            config.durationBar.height = Parser.parseNumber(config.durationBar.height,4);
            config.durationBar.maxDuration = Parser.parseNumber(config.durationBar.maxDuration,600);
         }
         if(!config.xpBar)
         {
            config.xpBar = {};
            config.xpBar.enabled = true;
            config.xpBar.text = DEFAULT_XP_BAR_FORMAT;
            config.xpBar.alignVertical = "bottom";
            config.xpBar.alignHorizontal = "left";
            config.xpBar.height = 4;
         }
         else
         {
            config.xpBar.enabled = Parser.parseBoolean(config.xpBar.enabled,true);
            config.xpBar.text = Boolean(config.xpBar.text) ? config.xpBar.text : DEFAULT_XP_BAR_FORMAT;
            config.xpBar.alignVertical = Boolean(config.xpBar.alignVertical) ? config.xpBar.alignVertical.toLowerCase() : "bottom";
            config.xpBar.alignHorizontal = Boolean(config.xpBar.alignHorizontal) ? config.xpBar.alignHorizontal.toLowerCase() : "left";
            config.xpBar.height = Parser.parseNumber(config.xpBar.height,4);
         }
         if(!config.scoreBar)
         {
            config.scoreBar = {};
            config.scoreBar.enabled = true;
            config.scoreBar.text = DEFAULT_SCORE_BAR_FORMAT;
            config.scoreBar.alignVertical = "bottom";
            config.scoreBar.alignHorizontal = "left";
            config.scoreBar.height = 4;
         }
         else
         {
            config.scoreBar.enabled = Parser.parseBoolean(config.scoreBar.enabled,true);
            config.scoreBar.text = Boolean(config.scoreBar.text) ? config.scoreBar.text : DEFAULT_SCORE_BAR_FORMAT;
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
            config.displayData = ["showBuffs"];
         }
         else if(config.displayData.indexOf("showBuffs") == -1)
         {
            config.displayData.push("showBuffs");
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
         if(!config.customChecklistColors)
         {
            config.customChecklistColors = {};
         }
         else
         {
            for(color in config.customChecklistColors)
            {
               config.customChecklistColors[color] = Parser.parseNumber(config.customChecklistColors[color],config.customColors.showChecklist || config.textColor);
            }
         }
         if(!config.customSubEffectColors)
         {
            config.customSubEffectColors = {};
         }
         else
         {
            for(color in config.customSubEffectColors)
            {
               config.customSubEffectColors[color] = Parser.parseNumber(config.customSubEffectColors[color],config.textColor);
            }
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
         if(!config.shownSubEffects)
         {
            config.shownSubEffects = [];
         }
         else
         {
            for(i in config.shownSubEffects)
            {
               config.shownSubEffects[i] = config.shownSubEffects[i].toLowerCase();
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
         if(!config.checklistCompareMode)
         {
            config.checklistCompareMode = 2;
         }
         else if(config.checklistCompareMode.toLowerCase() == "starts")
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

