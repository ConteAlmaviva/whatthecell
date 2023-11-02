--[[
* Ashita - Copyright (c) 2014 - 2016 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'Almavivaconte';
_addon.name     = 'WhatTheCell';
_addon.version  = '0.0.2';

require 'common'

ashita                  = ashita or { };
ashita.ffxi             = ashita.ffxi or { };
ashita.ffxi.vanatime    = ashita.ffxi.vanatime or { };

-- Scan for patterns..
ashita.ffxi.vanatime.pointer = ashita.memory.findpattern('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0x34, 0);

-- Signature validation..
if (ashita.ffxi.vanatime.pointer == 0) then
    error('vanatime.lua -- signature validation failed!');
end

local cells = {
    [5365] = {id=5365,name="Incus Cell",effect="Weapons/Shields",need=true},
    [5371] = {id=5371,name="Undulatus Cell",effect="Ranged/Ammo",need=true},
    [5366] = {id=5366,name="Castellanus Cell",effect="Head/Neck",need=true},
    [5367] = {id=5370,name="Cumulus Cell",effect="Body",need=true},
    [5368] = {id=5368,name="Radiatus Cell",effect="Hand",need=true},
    [5372] = {id=5372,name="Virga Cell",effect="Earring/Ring",need=true},
    [5370] = {id=5370,name="Cirrocumulus Cell",effect="Back/Waist",need=true},
    [5369] = {id=5369,name="Stratus Cell",effect="Leg/Feet",need=true},
    [5375] = {id=5375,name="Praecipitatio Cell",effect="Magic",need=true},
    [5373] = {id=5373,name="Duplicatus Cell",effect="Subjob",need=true},
    [5374] = {id=5374,name="Opacus Cell",effect="JA/WS",need=true},
    [5383] = {id=5383,name="Humilus Cell",effect="HP",need=true},
    [5384] = {id=5384,name="Spissatus Cell",effect="MP",need=true},
    [5376] = {id=5376,name="Pannus Cell",effect="STR",need=true},
    [5377] = {id=5377,name="Fractus Cell",effect="DEX",need=true},
    [5378] = {id=5378,name="Congestus Cell",effect="VIT",need=true},
    [5379] = {id=5379,name="Nimbus Cell",effect="AGI",need=true},
    [5380] = {id=5380,name="Velum Cell",effect="INT",need=true},
    [5381] = {id=5381,name="Pileus Cell",effect="MND",need=true},
    [5382] = {id=5382,name="Mediocris Cell",effect="CHR",need=true},
}

local WhatTheCell_config =
{
    font =
    {
        family      = 'Arial',
        size        = 7,
        color       = 0xFFFFFFFF,
        position    = { 640, 360 },
        bgcolor     = 0xC8000000,
        bgvisible   = true
    },
};

local basePathos = {
    5365,
    5371,
    5366,
    5367,
    5368,
    5372,
    5369,
    5375,
    5373,
    5374,
    5383,
    5384,
    5376,
    5377,
    5378,
    5379,
    5380,
    5381,
    5382
};

local playerPathos = {};
local timeLeftInSalvage = nil;
local dateEntered = nil;

function tablefind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

----------------------------------------------------------------------------------------------------
-- func: get_raw_timestamp
-- desc: Returns the current raw Vana'diel timestamp.
----------------------------------------------------------------------------------------------------
local function get_raw_timestamp()
    local pointer = ashita.memory.read_uint32(ashita.ffxi.vanatime.pointer);
    return ashita.memory.read_uint32(pointer + 0x0C);
end 
ashita.ffxi.vanatime.get_raw_timestamp = get_raw_timestamp;

local function get_current_date()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local day = math.floor(ts / 86400);

    -- Calculate the moon information..
    local mphase = (day + 26) % 84;
    local mpercent = (((42 - mphase) * 100)  / 42);
    if (0 > mpercent) then
        mpercent = math.abs(mpercent);
    end

    -- Build the date information..
    local vanadate          = { };
    vanadate.weekday        = (day % 8);
    vanadate.day            = (day % 30) + 1;
    vanadate.month          = ((day % 360) / 30) + 1;
    vanadate.year           = (day / 360);
    vanadate.moon_percent   = math.floor(mpercent + 0.5);
    
    local days = {
    "Firesday",
    "Earthsday",
    "Watersday",
    "Windsday",
    "Iceday",
    "Lightningsday",
    "Lightsday",
    "Darksday"
    }
    
    vanadate.weekday = days[vanadate.weekday + 1]
    
    if (38 <= mphase) then  
        vanadate.moon_phase = math.floor((mphase - 38) / 7);
    else
        vanadate.moon_phase = math.floor((mphase + 46) / 7);
    end

    return vanadate;
end
ashita.ffxi.vanatime.get_current_date = get_current_date;

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the configuration..
    WhatTheCell_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', WhatTheCell_config);
    
    local playerZone = AshitaCore:GetDataManager():GetParty():GetMemberZone(0);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():Create('__WhatTheCell_addon');
    f:SetColor(WhatTheCell_config.font.color);
    f:SetFontFamily(WhatTheCell_config.font.family);
    f:SetFontHeight(WhatTheCell_config.font.size);
    f:SetBold(true);
    f:SetPositionX(WhatTheCell_config.font.position[1]);
    f:SetPositionY(WhatTheCell_config.font.position[2]);
    if (playerZone >= 73 and playerZone <= 76) then
        playerPathos = basePathos;
        f:SetVisibility(true);
    else
        f:SetVisibility(false);
    end
    f:GetBackground():SetColor(WhatTheCell_config.font.bgcolor);
    f:GetBackground():SetVisibility(WhatTheCell_config.font.bgvisible);
end);
---------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when our addon is unloaded.
---------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
	local f = AshitaCore:GetFontManager():Get( '__WhatTheCell_addon' );
	WhatTheCell_config.font.position = { f:GetPositionX(), f:GetPositionY() };
	
	ashita.settings.save(_addon.path .. 'settings/settings.json', WhatTheCell_config);
	
	AshitaCore:GetFontManager():Delete( '__WhatTheCell_addon' );
end );
---------------------------------------------------------------------------------------------------
-- func: incoming_text
-- desc: Event called when the addon is asked to handle an incoming chat line.
---------------------------------------------------------------------------------------------------

ashita.register_event('incoming_text', function(mode, chat)
    if (mode == 121 or mode == 127) then
        for k,v in pairs(cells) do
            local c = ashita.regex.search(chat, string.lower(v['name']));
            if (c ~= nil) then
                if v['need'] == false then
                    return ashita.regex.replace(chat, string.lower(v['name']), string.lower(v['name']).. " (" .. string.lower(v['effect']) .. " - have)");
                else
                    return ashita.regex.replace(chat, string.lower(v['name']), string.lower(v['name']).. " (" .. string.lower(v['effect']) .. " - need)");
                end
            end
        end
    end
    return false;
end);

ashita.register_event('incoming_packet', function(id, size, packet)
    
    if id == 0x00A then
        local f = AshitaCore:GetFontManager():Get('__WhatTheCell_addon');
        local zoneId = struct.unpack('H', packet, 0x30 + 1);
        if (zoneId >= 73 and zoneId <= 76) then
            f:SetVisibility(true)
            playerPathos = basePathos;
            timeLeftInSalvage = os.time(os.date("!*t")) + 6000;
        else
            f:SetVisibility(false)
            timeLeftInSalvage = nil
        end
        dateEntered = get_current_date().weekday;
    end
    return false;
    
end);

ashita.register_event('outgoing_packet', function(id, size, packet)
	-- Used Item
	if (id == 0x037) then
        itemIndexVal = struct.unpack('b', packet, 0x0F);
        itemId = AshitaCore:GetDataManager():GetInventory():GetItem(0, itemIndexVal).Id;
        for k,v in pairs(playerPathos) do
            if v == itemId then
                table.remove(playerPathos, tablefind(playerPathos, v))
                cells[itemId]['need'] = false
            end
        end
    end
	return false;
end);

ashita.register_event('render', function()
    local f = AshitaCore:GetFontManager():Get('__WhatTheCell_addon');
    local currentPathos = "";
    if timeLeftInSalvage ~= nil then
        currentPathos = "Time remaining: " .. os.date('!%H:%M:%S', timeLeftInSalvage - os.time(os.date("!*t"))) .. "\n(Entered on " .. dateEntered .. ")\n"
    end 
    currentPathos = currentPathos .. "Currently Locked\n"
    for k,v in pairs(playerPathos) do
        currentPathos = currentPathos .. "\n" .. cells[v]['effect'] .. " (Unlock: " .. cells[v]['name'] .. ")"
    end   
    f:SetText(currentPathos)
end);