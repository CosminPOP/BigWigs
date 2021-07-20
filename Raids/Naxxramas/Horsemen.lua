----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("The Four Horsemen", "Naxxramas")
local thane = AceLibrary("Babble-Boss-2.2")["Thane Korth'azz"]
local mograine = AceLibrary("Babble-Boss-2.2")["Highlord Mograine"]
local zeliek = AceLibrary("Babble-Boss-2.2")["Sir Zeliek"]
local blaumeux = AceLibrary("Babble-Boss-2.2")["Lady Blaumeux"]


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function()
    return {
        cmd = "Horsemen",

        mark_cmd = "mark",
        mark_name = "Mark Alerts",
        mark_desc = "Warn for marks",

        shieldwall_cmd = "shieldwall",
        shieldwall_name = "Shieldwall Alerts",
        shieldwall_desc = "Warn for shieldwall",

        void_cmd = "void",
        void_name = "Void Zone Alerts",
        void_desc = "Warn on Lady Blaumeux casting Void Zone.",

        meteor_cmd = "meteor",
        meteor_name = "Meteor Alerts",
        meteor_desc = "Warn on Thane casting Meteor.",

        wrath_cmd = "wrath",
        wrath_name = "Holy Wrath Alerts",
        wrath_desc = "Warn on Zeliek casting Wrath.",

        markbar = "Mark %d",
        mark_warn = "Mark %d!",
        mark_warn_5 = "Mark %d in 5 sec",
        marktrigger1 = "afflicted by Mark of Zeliek",
        marktrigger2 = "afflicted by Mark of Korth'azz",
        marktrigger3 = "afflicted by Mark of Blaumeux",
        marktrigger4 = "afflicted by Mark of Mograine",

        voidtrigger = "Your life is mine!",
        voidwarn = "Void Zone Incoming",
        voidbar = "Void Zone",

        meteortrigger = "Thane Korth'azz's Meteor hits ",
        meteortrigger2 = "I like my meat extra crispy!",
        meteorwarn = "Meteor!",
        meteorbar = "Meteor",

        wrathtrigger = "Sir Zeliek's Holy Wrath hits ",
        wrathtrigger2 = "I have no choice but to obey!",
        wrathwarn = "Holy Wrath!",
        wrathbar = "Holy Wrath",

        startwarn = "The Four Horsemen Engaged! Mark in 20 sec",

        shieldwallbar = "%s - Shield Wall",
        shieldwalltrigger = "(.*) gains Shield Wall.",
        shieldwall_warn = "%s - Shield Wall for 20 sec",
        shieldwall_warn_over = "%s - Shield Wall GONE!",
    }
end)

L:RegisterTranslations("esES", function()
    return {
        --cmd = "Horsemen",

        --mark_cmd = "mark",
        mark_name = "Alerta de Marcas",
        mark_desc = "Avisa para Marcas",

        --shieldwall_cmd  = "shieldwall",
        shieldwall_name = "Alerta de Muro de escudo",
        shieldwall_desc = "Avisa para Muro de escudo",

        --void_cmd = "void",
        void_name = "Alerta de Zona de vacío",
        void_desc = "Avisa cuando Lady Blaumeux lance Zona de vacío.",

        --meteor_cmd = "meteor",
        meteor_name = "Alerta de Meteoro",
        meteor_desc = "Avisa cuando Thane lance Meteoro.",

        --wrath_cmd = "wrath",
        wrath_name = "Alerta de Cólera sagrada",
        wrath_desc = "Avisa cuando Zeliek lance Cólera sagrada.",

        markbar = "Marca de %d",
        mark_warn = "¡Marca de %d!",
        mark_warn_5 = "Marca de %d en 5 segundos",
        marktrigger1 = "sufre de Marca de Zeliek",
        marktrigger2 = "sufre de Marca de Korth'azz",
        marktrigger3 = "sufre de Marca de Blaumeux",
        marktrigger4 = "sufre de Marca de Mograine",

        voidtrigger = "Lady Blaumeux lanza Zona de vacío.",
        voidwarn = "Zona de vacío entrante",
        voidbar = "Zona de vacío",

        meteortrigger = "Meteoro de Thane Korth'azz golpea ",
        meteortrigger2 = "I like my meat extra crispy!",
        meteorwarn = "¡Meteoro!",
        meteorbar = "Meteoro",

        wrathtrigger = "Cólera sagrada de Sir Zeliek impacta ",
        wrathtrigger2 = "I have no choice but to obey!",
        wrathwarn = "¡Cólera sagrada!",
        wrathbar = "Cólera sagrada",

        startwarn = "Entrando en combate con Los Cuatro Caballoshombre! Marca en ~17 segundos",

        shieldwallbar = "%s - Muro de escudo",
        shieldwalltrigger = "(.*) gana Muro de escudo.",
        shieldwall_warn = "%s - Muro de escudo por 20 segundos",
        shieldwall_warn_over = "¡%s - Muro de escudo DESAPARECE!",
    }
end)
---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20005 -- To be overridden by the module!
module.enabletrigger = { thane, mograine, zeliek, blaumeux } -- string or table {boss, add1, add2}
--module.wipemobs = { L["add_name"] } -- adds which will be considered in CheckForEngage
module.toggleoptions = { "mark", "shieldwall", -1, "meteor", "void", "wrath", "bosskill" }


-- locals
local timer = {
    firstMark = 20,
    mark = 12,
    firstMeteor = 20,
    meteor = { 12, 15 },
    firstWrath = 20,
    wrath = { 10, 14 },
    firstVoid = 15,
    void = { 12, 15 },
    shieldwall = 20,
}
local icon = {
    mark = "Spell_Shadow_CurseOfAchimonde",
    meteor = "Spell_Fire_Fireball02",
    wrath = "Spell_Holy_Excorcism",
    void = "spell_shadow_antishadow",
    shieldwall = "Ability_Warrior_ShieldWall",
}
local syncName = {
    shieldwall = "HorsemenShieldWall" .. module.revision,
    mark = "HorsemenMark" .. module.revision,
    void = "HorsemenVoid" .. module.revision,
    wrath = "HorsemenWrath" .. module.revision,
    meteor = "HorsemenMeteor" .. module.revision,
}

local times = nil
local globalMarks = 0
local playerGroup = 0

local MOVE_SAFE_SPOT = "MOVE TO |cf75DE52fSAFE SPOT"
local MOVE_THANE = "MOVE TO |cff7b9a2fTHANE|r - STACK ON TANK"
local MOVE_MOGRAINE = "MOVE TO |cffb2422eMOGRAINE"

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
    self:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "MarkEvent")
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "MarkEvent")
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "MarkEvent")

    self:ThrottleSync(3, syncName.shieldwall)
    self:ThrottleSync(8, syncName.mark)
    self:ThrottleSync(5, syncName.void)
    self:ThrottleSync(5, syncName.wrath)
    self:ThrottleSync(5, syncName.meteor)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
    self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

    self.marks = 0
    self.deaths = 0

    globalMarks = 0

    times = {}
end

local fhAlert = CreateFrame("Frame", "fhAlert");

fhAlert:RegisterEvent("CHAT_MSG_ADDON")

fhAlert:SetPoint("CENTER", UIParent, "CENTER", 0, -100);

fhAlert.text = fhAlert:CreateFontString("$parentText", "OVERLAY");
fhAlert.text:Hide()
fhAlert.text:SetWidth(800);
fhAlert.text:SetHeight(108);
fhAlert.text:SetFont(STANDARD_TEXT_FONT, 50, "OUTLINE");
fhAlert.text:SetPoint("CENTER", UIParent, 0, 100);
fhAlert.text:SetJustifyV("MIDDLE");
fhAlert.text:SetJustifyH("CENTER");

local fh_alert = CreateFrame('Frame')
fh_alert:Hide()
function fh_alert_marks(message)
    fhAlert.text:SetText(message);
    DEFAULT_CHAT_FRAME:AddMessage(message)
    fh_alert:Show()
end

fhAlert.healerIndex = 0

fhAlert:SetScript("OnEvent", function()
    if event then
        if event == 'CHAT_MSG_ADDON' and arg1 == "TWABW" then
            local data = string.split(arg2, ' ')
            for _, d in data do
                for healerIndex = 1, 3 do
                    if string.find(d, '[' .. healerIndex .. ']' .. UnitName('player'), 1, true) then
                        fhAlert.healerIndex = healerIndex
                        DEFAULT_CHAT_FRAME:AddMessage("Healer index set to " .. healerIndex)
                        break
                    end
                end

            end
        end
    end
end)

-- called after boss is engaged
function module:OnEngage()
    self.marks = 0

    globalMarks = 0

    if self.db.profile.mark then
        self:Message(L["startwarn"], "Attention")
        self:Bar(string.format(L["markbar"], self.marks + 1), timer.firstMark, icon.mark)
        self:DelayedMessage(timer.firstMark - 5, string.format(L["mark_warn_5"], self.marks + 1), "Urgent")
    end
    if self.db.profile.meteor then
        self:Bar(L["meteorbar"], timer.firstMeteor, icon.meteor)
    end
    if self.db.profile.wrath then
        self:Bar(L["wrathbar"], timer.firstWrath, icon.wrath)
    end
    if self.db.profile.void then
        self:Bar(L["voidbar"], timer.firstVoid, icon.void)
    end

    for i = 0, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local n, _, group = GetRaidRosterInfo(i);
            if n == UnitName('player') then
                playerGroup = group
            end
        end
    end

    if playerGroup > 0 then
        if playerGroup == 3 then
            fh_alert_marks(MOVE_THANE)
        end
        if playerGroup == 4 then
            fh_alert_marks(MOVE_SAFE_SPOT)
        end
        if playerGroup == 5 then
            fh_alert_marks(MOVE_MOGRAINE)
        end
        if playerGroup == 6 then
            fh_alert_marks(MOVE_SAFE_SPOT)
        end
    end

end

fh_alert:SetScript("OnShow", function()
    this.startTime = GetTime()
    fhAlert.text:Show()
end)
fh_alert:SetScript("OnHide", function()
    fhAlert.text:Hide()
end)
fh_alert:SetScript("OnUpdate", function()
    local plus = 5
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then
        fh_alert:Hide()
    end
end)


-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers	    --
------------------------------

function module:MarkEvent(msg)
    if string.find(msg, L["marktrigger1"]) or string.find(msg, L["marktrigger2"]) or string.find(msg, L["marktrigger3"]) or string.find(msg, L["marktrigger4"]) then
        self:Sync(syncName.mark)
    end
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
    local _, _, mob = string.find(msg, L["shieldwalltrigger"])
    if mob then
        self:Sync(syncName.shieldwall .. " " .. mob)
    end
end

function module:CHAT_MSG_MONSTER_SAY(msg)
    if string.find(msg, L["voidtrigger"]) then
        self:Sync(syncName.void)
    elseif string.find(msg, L["meteortrigger2"]) then
        self:Sync(syncName.meteor)
    elseif string.find(msg, L["wrathtrigger2"]) then
        self:Sync(syncName.wrath)
    end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
    if msg == string.format(UNITDIESOTHER, thane) or
            msg == string.format(UNITDIESOTHER, zeliek) or
            msg == string.format(UNITDIESOTHER, mograine) or
            msg == string.format(UNITDIESOTHER, blaumeux) then

        self.deaths = self.deaths + 1
        if self.deaths == 4 then
            self:SendBossDeathSync()
        end
    end
end

------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
    --Print("sync= "..sync.." rest= "..rest.." nick= "..nick)
    if sync == syncName.mark then
        self:Mark()
    elseif sync == syncName.meteor then
        self:Meteor()
    elseif sync == syncName.wrath then
        self:Wrath()
    elseif sync == syncName.void then
        self:Void()
    elseif sync == syncName.shieldwall and rest then
        self:Shieldwall(rest)
    end
end

function horsemenIsRL()
    if not UnitInRaid('player') then
        return false
    end
    for i = 0, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local n, r = GetRaidRosterInfo(i);
            if n == UnitName('player') and r == 2 then
                return true
            end
        end
    end
    return false
end



------------------------------
--      Sync Handlers	    --
------------------------------

function module:Mark()
    self:RemoveBar(string.format(L["markbar"], self.marks))
    self.marks = self.marks + 1

    globalMarks = globalMarks + 1

    if horsemenIsRL() then
        SendChatMessage("HEALER [" .. globalMarks .. "] ROTATE", "RAID", DEFAULT_CHAT_FRAME.editBox.languageID);
    end
    if globalMarks == fhAlert.healerIndex then
        fh_alert_marks("|cf75DE52f- MOVE -")
        self:TriggerEvent("BigWigs_Sound", "BikeHorn")
    end

    if globalMarks == 3 then
        if fhAlert.healerIndex == 0 then
            self:TriggerEvent("BigWigs_Sound", "BikeHorn")
        end
        globalMarks = 0
    end

    if playerGroup > 0 then

        if self.marks == 0 or self.marks == 12 or self.marks == 24 or self.marks == 36 then
            if playerGroup == 3 then
                fh_alert_marks(MOVE_THANE)
            end
            if playerGroup == 4 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
            if playerGroup == 5 then
                fh_alert_marks(MOVE_MOGRAINE)
            end
            if playerGroup == 6 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
        end

        if self.marks == 3 or self.marks == 15 or self.marks == 27 or self.marks == 39 then
            if playerGroup == 3 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
            if playerGroup == 4 then
                fh_alert_marks(MOVE_THANE)
            end
            if playerGroup == 5 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
            if playerGroup == 6 then
                fh_alert_marks(MOVE_MOGRAINE)
            end
        end

        if self.marks == 6 or self.marks == 18 or self.marks == 30 or self.marks == 42 then
            if playerGroup == 3 then
                fh_alert_marks(MOVE_MOGRAINE)
            end
            if playerGroup == 4 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
            if playerGroup == 5 then
                fh_alert_marks(MOVE_THANE)
            end
            if playerGroup == 6 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
        end

        if self.marks == 9 or self.marks == 21 or self.marks == 33 or self.marks == 45 then
            if playerGroup == 3 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
            if playerGroup == 4 then
                fh_alert_marks(MOVE_MOGRAINE)
            end
            if playerGroup == 5 then
                fh_alert_marks(MOVE_SAFE_SPOT)
            end
            if playerGroup == 6 then
                fh_alert_marks(MOVE_THANE)
            end
        end
    end

    if self.db.profile.mark then
        self:Message(string.format(L["mark_warn"], self.marks), "Important")
        self:Bar(string.format(L["markbar"], self.marks + 1), timer.mark, icon.mark)
        self:DelayedMessage(timer.mark - 5, string.format(L["mark_warn_5"], self.marks + 1), "Urgent")
    end
end

function module:Meteor()
    if self.db.profile.meteor then
        self:Message(L["meteorwarn"], "Important")
        self:IntervalBar(L["meteorbar"], timer.meteor[1], timer.meteor[2], icon.meteor)
    end
end

function module:Wrath()
    if self.db.profile.wrath then
        self:Message(L["wrathwarn"], "Important")
        self:IntervalBar(L["wrathbar"], timer.wrath[1], timer.wrath[2], icon.wrath)
    end
end

function module:Void()
    if self.db.profile.void then
        self:Message(L["voidwarn"], "Important")
        self:IntervalBar(L["voidbar"], timer.void[1], timer.void[2], icon.void)
        if (UnitExists('target') and UnitName('target') == blaumeux) or
                (UnitExists('targettarget') and UnitName('targettarget') == blaumeux) then
            self:WarningSign(icon.void, 3)
        end
    end
end

function module:Shieldwall(mob)
    if mob and self.db.profile.shieldwall then
        self:Message(string.format(L["shieldwall_warn"], mob), "Attention")
        self:Bar(string.format(L["shieldwallbar"], mob), timer.shieldwall, icon.shieldwall)
        self:DelayedMessage(timer.shieldwall, string.format(L["shieldwall_warn_over"], mob), "Positive")
    end
end

--[[
1608234547688 1608234547.6880 Thu Dec 17 21:49:08 UTC 2020 Sir Zeliek Holy Wrath
1608234562266 1608234562.2660 Thu Dec 17 21:49:22 UTC 2020 Sir Zeliek Holy Wrath 14
1608234575203 1608234575.2030 Thu Dec 17 21:49:35 UTC 2020 Sir Zeliek Holy Wrath 13
1608234589813 1608234589.8130 Thu Dec 17 21:49:50 UTC 2020 Sir Zeliek Holy Wrath 15
1608234602781 1608234602.7810 Thu Dec 17 21:50:03 UTC 2020 Sir Zeliek Holy Wrath 13
1608234614125 1608234614.1250 Thu Dec 17 21:50:14 UTC 2020 Sir Zeliek Holy Wrath 11
1608234630313 1608234630.3130 Thu Dec 17 21:50:30 UTC 2020 Sir Zeliek Holy Wrath 16
1608234644875 1608234644.8750 Thu Dec 17 21:50:45 UTC 2020 Sir Zeliek Holy Wrath 15
1608234657844 1608234657.8440 Thu Dec 17 21:50:58 UTC 2020 Sir Zeliek Holy Wrath 13
1608234672391 1608234672.3910 Thu Dec 17 21:51:12 UTC 2020 Sir Zeliek Holy Wrath 14
1608234685328 1608234685.3280 Thu Dec 17 21:51:25 UTC 2020 Sir Zeliek Holy Wrath 13
1608234697110 1608234697.1100 Thu Dec 17 21:51:37 UTC 2020 Sir Zeliek Holy Wrath 12
1608234709625 1608234709.6250 Thu Dec 17 21:51:50 UTC 2020 Sir Zeliek Holy Wrath 13
1608234720969 1608234720.9690 Thu Dec 17 21:52:01 UTC 2020 Sir Zeliek Holy Wrath 11
1608234733891 1608234733.8910 Thu Dec 17 21:52:14 UTC 2020 Sir Zeliek Holy Wrath 13
1608234745266 1608234745.2660 Thu Dec 17 21:52:25 UTC 2020 Sir Zeliek Holy Wrath 11
1608234756578 1608234756.5780 Thu Dec 17 21:52:37 UTC 2020 Sir Zeliek Holy Wrath 12
1608234771141 1608234771.1410 Thu Dec 17 21:52:51 UTC 2020 Sir Zeliek Holy Wrath 14
1608234784110 1608234784.1100 Thu Dec 17 21:53:04 UTC 2020 Sir Zeliek Holy Wrath 13
1608234797078 1608234797.0780 Thu Dec 17 21:53:17 UTC 2020 Sir Zeliek Holy Wrath 13
1608234811656 1608234811.6560 Thu Dec 17 21:53:32 UTC 2020 Sir Zeliek Holy Wrath 15
1608234824625 1608234824.6250 Thu Dec 17 21:53:45 UTC 2020 Sir Zeliek Holy Wrath 13
1608234837625 1608234837.6250 Thu Dec 17 21:53:58 UTC 2020 Sir Zeliek Holy Wrath 13
1608234852219 1608234852.2190 Thu Dec 17 21:54:12 UTC 2020 Sir Zeliek Holy Wrath 14
1608234865172 1608234865.1720 Thu Dec 17 21:54:25 UTC 2020 Sir Zeliek Holy Wrath 13
1608234878125 1608234878.1250 Thu Dec 17 21:54:38 UTC 2020 Sir Zeliek Holy Wrath 13
1608234891078 1608234891.0780 Thu Dec 17 21:54:51 UTC 2020 Sir Zeliek Holy Wrath 13
1608234902406 1608234902.4060 Thu Dec 17 21:55:02 UTC 2020 Sir Zeliek Holy Wrath 11
1608234918641 1608234918.6410 Thu Dec 17 21:55:19 UTC 2020 Sir Zeliek Holy Wrath
1608234933219 1608234933.2190 Thu Dec 17 21:55:33 UTC 2020 Sir Zeliek Holy Wrath
1608234944578 1608234944.5780 Thu Dec 17 21:55:45 UTC 2020 Sir Zeliek Holy Wrath
1608234957500 1608234957.5000 Thu Dec 17 21:55:58 UTC 2020 Sir Zeliek Holy Wrath
1608234972047 1608234972.0470 Thu Dec 17 21:56:12 UTC 2020 Sir Zeliek Holy Wrath
1608234984969 1608234984.9690 Thu Dec 17 21:56:25 UTC 2020 Sir Zeliek Holy Wrath
1608234996281 1608234996.2810 Thu Dec 17 21:56:36 UTC 2020 Sir Zeliek Holy Wrath

]]--


function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end


-- tests
-- /run local m=BigWigs:GetModule("The Four Horsemen");m:Test()
function module:Test()

    local function mark()
        BigWigs:Print("module Test mark()")
        self:Sync(syncName.mark)
    end

    local function deactivate()
        BigWigs:Print("deactivate")
        self:Disable()
    end

    local time = 0
    -- immitate CheckForEngage + mark1
    self:SendEngageSync()
    BigWigs:Print("module Test started")

    --mark2
    time = time + timer.firstMark -- 20
    self:ScheduleEvent(self:ToString().."Test_mark2", mark, time, self)
    BigWigs:Print("module Test schedule mark(2) @ " .. time)

    --mark3
    time = time + timer.mark -- 32
    self:ScheduleEvent(self:ToString().."Test_mark3", mark, time, self)
    BigWigs:Print("module Test schedule mark(3) @ " .. time)

    --mark4
    time = time + timer.mark -- 44
    self:ScheduleEvent(self:ToString().."Test_mark4", mark, time, self)
    BigWigs:Print("module Test schedule mark(4) @ " .. time)

    --mark5
    time = time + timer.mark --56
    self:ScheduleEvent(self:ToString().."Test_mark5", mark, time, self)
    BigWigs:Print("module Test schedule mark(5) @ " .. time)

    --mark6
    time = time + timer.mark -- 68
    self:ScheduleEvent(self:ToString().."Test_mark6", mark, time, self)
    BigWigs:Print("module Test schedule mark(6) @ " .. time)

    --mark7
    time = time + timer.mark -- 80
    self:ScheduleEvent(self:ToString().."Test_mark7", mark, time, self)
    BigWigs:Print("module Test schedule mark(7) @ " .. time)

    --mark8
    time = time + timer.mark -- 92
    self:ScheduleEvent(self:ToString().."Test_mark8", mark, time, self)
    BigWigs:Print("module Test schedule mark(8) @ " .. time)

    --mark9
    time = time + timer.mark -- 104
    self:ScheduleEvent(self:ToString().."Test_mark9", mark, time, self)
    BigWigs:Print("module Test schedule mark(9) @ " .. time)

    --mark10
    time = time + timer.mark -- 116
    self:ScheduleEvent(self:ToString().."Test_mark10", mark, time, self)
    BigWigs:Print("module Test schedule mark(10) @ " .. time)

    --mark11
    time = time + timer.mark -- 128
    self:ScheduleEvent(self:ToString().."Test_mark11", mark, time, self)
    BigWigs:Print("module Test schedule mark(11) @ " .. time)

    --mark12
    time = time + timer.mark -- 140
    self:ScheduleEvent(self:ToString().."Test_mark12", mark, time, self)
    BigWigs:Print("module Test schedule mark(12) @ " .. time)

    --mark13
    time = time + timer.mark -- 152
    self:ScheduleEvent(self:ToString().."Test_mark13", mark, time, self)
    BigWigs:Print("module Test schedule mark(13) @ " .. time)

    --mark14
    time = time + timer.mark -- 164
    self:ScheduleEvent(self:ToString().."Test_mark14", mark, time, self)
    BigWigs:Print("module Test schedule mark(14) @ " .. time)

    --mark15
    time = time + timer.mark -- 176
    self:ScheduleEvent(self:ToString().."Test_mark15", mark, time, self)
    BigWigs:Print("module Test schedule mark(15) @ " .. time)

    --mark16
    time = time + timer.mark -- 188
    self:ScheduleEvent(self:ToString().."Test_mark16", mark, time, self)
    BigWigs:Print("module Test schedule mark(16) @ " .. time)


    -- reset after 4m
    time = 240
    BigWigs:Print(" deactivate after " .. time)
    self:ScheduleEvent(self:ToString().."Test_deactivate", deactivate, time, self)
end
