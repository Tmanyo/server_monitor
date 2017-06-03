---
-- Tables and Variables
---

bad_nodes = {}
bad_nodes.lava_placed = {}
bad_nodes.water_placed = {}
bad_nodes.corium_placed = {}
bad_nodes.chernobylite_placed = {}
bad_nodes.exempt_players = {}
bad_nodes.low_lava = {}
bad_nodes.low_water = {}
bad_nodes.low_corium = {}
bad_nodes.low_chernobylite = {}
bad_nodes.high_lava = {}
bad_nodes.high_water = {}
bad_nodes.high_corium = {}
bad_nodes.high_chernobylite = {}
bad_nodes.default_reason = {}
bad_nodes.MAK = {}
bad_nodes.bad_language = {}
bad_nodes.spoken_bad = {}

local minor = {}
local major = {}

refined_major = {}
refined_minor = {}

local ptype = {}
local add_on = {}
local formspec = {}
local total = {}
local words = {}

local a = {}
local b = {}
local d = {}
local c = 0
local remove = {}
local ban = {}
local exempt = {}

---
-- Saving Functions
---

-- If there isn't a file, make one.
local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "r")
if f == nil then
     local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "w")
     f:write(minetest.serialize(bad_nodes))
     f:close()
end

-- Saves changes to player's name.
function save_nodes()
     local data = bad_nodes
     local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "w")
     if err then
          return err
     end
     f:write(minetest.serialize(data))
     f:close()
end

-- Reads changes from player's name.
function read_nodes()
     local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "r")
     local data = minetest.deserialize(f:read("*a"))
     f:close()
          return data
end

bad_nodes = read_nodes()

minetest.register_on_joinplayer(function(player)
	if not bad_nodes.lava_placed[player:get_player_name()] then
		bad_nodes.lava_placed[player:get_player_name()] = 0
	end
	if not bad_nodes.water_placed[player:get_player_name()] then
		bad_nodes.water_placed[player:get_player_name()] = 0
	end
	if not bad_nodes.corium_placed[player:get_player_name()] then
		bad_nodes.corium_placed[player:get_player_name()] = 0
	end
	if not bad_nodes.chernobylite_placed[player:get_player_name()] then
		bad_nodes.chernobylite_placed[player:get_player_name()] = 0
	end
	if not bad_nodes.spoken_bad[player:get_player_name()] then
		bad_nodes.spoken_bad[player:get_player_name()] = {}
	end
	save_nodes()
end)

---
-- Settings
---

-- Default Settings

if tonumber(bad_nodes.low_lava) == nil then
	bad_nodes.low_lava = 1
end
if tonumber(bad_nodes.low_water) == nil then
	bad_nodes.low_water = 5
end
if tonumber(bad_nodes.low_corium) == nil then
	bad_nodes.low_corium = 1
end
if tonumber(bad_nodes.low_chernobylite) == nil then
	bad_nodes.low_chernobylite = 1
end
if tonumber(bad_nodes.high_lava) == nil then
	bad_nodes.high_lava = 5
end
if tonumber(bad_nodes.high_water) == nil then
	bad_nodes.high_water = 30
end
if tonumber(bad_nodes.high_corium) == nil then
	bad_nodes.high_corium = 2
end
if tonumber(bad_nodes.high_chernobylite) == nil then
	bad_nodes.high_chernobylite = 2
end
if minetest.serialize(bad_nodes.default_reason) == "return {}" then
	bad_nodes.default_reason = "Due to your actions, you have been banned."
end
if minetest.serialize(bad_nodes.MAK) == "return {}" then
	bad_nodes.MAK = "MiNeTeSt"
end
if minetest.serialize(bad_nodes.bad_language) == "return {}" then
	bad_nodes.bad_language = "shit, dick, fuck, ass, asshole, bitch, cunt, fucker, dumbass, jackass, motherfucker, pussy, faggot, fucking, damn, whore, ho, retard"
end
save_nodes()

---
-- Node/Chat Action Recording
---

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local playername = placer:get_player_name()
	if newnode.name == "default:lava_source" then
		bad_nodes.lava_placed[playername] = bad_nodes.lava_placed[playername] + 1
	elseif newnode.name == "default:water_source" then
		bad_nodes.water_placed[playername] = bad_nodes.water_placed[playername] + 1
	end
	if minetest.get_modpath("technic") then
		if newnode.name == "technic:chernobylite_block" then
			bad_nodes.chernobylite_placed[playername] = bad_nodes.chernobylite_placed[playername] + 1
		elseif newnode.name == "technic:corium_source" then
			bad_nodes.corium_placed[playername] = bad_nodes.corium_placed[playername] + 1
		end
	end
	save_nodes()
end)

minetest.register_on_chat_message(function(name, message)
	local string_words = {}
	for word in message:gmatch("%S+") do
		table.insert(string_words, string.lower(word))
	end
	for k,v in pairs(string_words) do
		if string.len(v) == 1 then
			string_words = minetest.deserialize(minetest.serialize(string_words):gsub(v .. ",", ""))
		else
			print(minetest.serialize(string_words))
			local keyword = v:gsub("\"", "")
			print(v)
			if minetest.serialize(bad_nodes.bad_language):match(" " .. keyword .. ",") or
			minetest.serialize(bad_nodes.bad_language):match(keyword .. ",") or
			minetest.serialize(bad_nodes.bad_language):match(", " .. keyword) then
				table.insert(bad_nodes.spoken_bad[name], v)
			end
		end
	end
	save_nodes()
end)

---
-- Prioritizing Functions
---

function priority_low()
	minor = {}
	for k,v in pairs(bad_nodes.lava_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v >= tonumber(bad_nodes.low_lava) then
				if not minetest.serialize(major):match(k) then
					if not minetest.serialize(minor):match(k) then
						table.insert(minor, k)
					end
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.water_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v >= tonumber(bad_nodes.low_water) then
				if not minetest.serialize(major):match(k) then
					if not minetest.serialize(minor):match(k) then
						table.insert(minor, k)
					end
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.corium_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v == tonumber(bad_nodes.low_corium) then
				if not minetest.serialize(major):match(k) then
					if not minetest.serialize(minor):match(k) then
						table.insert(minor, k)
					end
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.chernobylite_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v == tonumber(bad_nodes.low_chernobylite) then
				if not minetest.serialize(major):match(k) then
					if not minetest.serialize(minor):match(k) then
						table.insert(minor, k)
					end
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.spoken_bad) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if not minetest.serialize(minor):match(k) then
				if #v >= 1 then
					if not minetest.serialize(major):match(k) then
						table.insert(minor, k)
					end
				end
			end
		end
	end
	return minetest.serialize(minor):gsub("return", ""):gsub("\"", ""):gsub("{", ""):gsub("}", ""):gsub(" ", "")
end

function priority_high()
	minor = {}
	for k,v in pairs(bad_nodes.lava_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v >= tonumber(bad_nodes.high_lava) then
				if not minetest.serialize(major):match(k) then
					table.insert(major, k)
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.water_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v >= tonumber(bad_nodes.high_water) then
				if not minetest.serialize(major):match(k) then
					table.insert(major, k)
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.corium_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v >= tonumber(bad_nodes.high_corium) then
				if not minetest.serialize(major):match(k) then
					table.insert(major, k)
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.chernobylite_placed) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if v >= tonumber(bad_nodes.high_chernobylite) then
				if not minetest.serialize(major):match(k) then
					table.insert(major, k)
				end
			end
		end
	end
	for k,v in pairs(bad_nodes.spoken_bad) do
		if not minetest.serialize(bad_nodes.exempt_players):match(k) then
			if #v >= 5 then
				if not minetest.serialize(major):match(k) then
					table.insert(major, k)
				end
			end
		end
	end
	priority_low()
	return minetest.serialize(major):gsub("return", ""):gsub("\"", ""):gsub("{", ""):gsub("}", ""):gsub(" ", "")
end

---
-- Formspec Related Code
---

info_text = "label[6,.75;Welcome!  This is a useful tool for server hosts/admins\nthat can't afford to spend time on their server" ..
	" all day.\nTo find out more information as to why a player is on a\npriority list, click their name.  In the overview tab" ..
	" it\nshows the reason why.  In the action tab, you can\nchoose what you want to do about the situation.\nHowever, as always" ..
	" you can handle the situation on\nyour own."

refined_major = priority_high()
refined_minor = priority_low()

function main_screen(ptype, add_on)
	formspec = "size[12,10]" ..
	"background[0,0;12,10;welcome_bg_beta.png;true]" ..
	"label[.5,-.25;Potential High Priority:]" ..
	"textlist[.5,.25;4,5;high_priority;" .. priority_high() .. ";;false]" ..
	"label[.5,5.25;Potential Low Priority:]" ..
	"textlist[.5,5.75;4,4.5;low_priority;" .. priority_low() .. ";;false]" ..
	"button[6,-.25;2,1;overview;Overview]" ..
	"button[8,-.25;2,1;actions;Actions]" ..
	"image[5.71,.65;7,7;action_bg.png]" ..
	"button[5.75,8.75;2,1;options;Options]"
	if add_on == 1 then
		formspec = formspec .. "label[6,.75;There are no high priority players at this time.]"
	end
	if add_on == 2 then
		formspec = formspec .. "label[8,.75;" .. major[d] .. "]" .. "label[6.25,1.25;Lava Source Placed: " ..
		bad_nodes.lava_placed[major[d]] .. "]" .. "label[6.25,1.75;Water Source Placed: " ..
		bad_nodes.water_placed[major[d]] .. "]" .. "label[6.25,2.25;Corium Source Placed: " ..
		bad_nodes.corium_placed[major[d]] .. "]" .. "label[6.25,2.75;Chernobylite Placed: " ..
		bad_nodes.chernobylite_placed[major[d]] .. "]" .. "label[6.25,3.25;Bad Language: " ..
		#bad_nodes.spoken_bad[major[d]] .. "]"
		if #bad_nodes.spoken_bad[major[d]] >= 1 then
			total = #bad_nodes.spoken_bad[major[d]]
			words = minetest.serialize(bad_nodes.spoken_bad[major[d]]):gsub("return ", ""):gsub("{", ""):gsub("}", ""):gsub("\"", "")
			formspec = formspec .. "label[8,.75;" .. major[d] .. "]" .. "label[6.25,1.25;Lava Source Placed: " ..
			bad_nodes.lava_placed[major[d]] .. "]" .. "label[6.25,1.75;Water Source Placed: " ..
			bad_nodes.water_placed[major[d]] .. "]" .. "label[6.25,2.25;Corium Source Placed: " ..
			bad_nodes.corium_placed[major[d]] .. "]" .. "label[6.25,2.75;Chernobylite Placed: " ..
			bad_nodes.chernobylite_placed[major[d]] .. "]" .. "label[6.25,3.25;Bad Language: " ..
			tonumber(total) .. "]" .. "label[6.25,3.75;Words Spoken: " ..
			words .. "]"
		end
	end
	if add_on == 3 then
		formspec = formspec .. info_text
	end
	if add_on == 4 then
		formspec = formspec .. "label[6,.75;There are no low priority players at this time.]"
	end
	if add_on == 5 then
		formspec = formspec .. "label[8,.75;" .. minor[d] .. "]" .. "label[6.25,1.25;Lava Source Placed: " ..
		bad_nodes.lava_placed[minor[d]] .. "]" .. "label[6.25,1.75;Water Source Placed: " ..
		bad_nodes.water_placed[minor[d]] .. "]" .. "label[6.25,2.25;Corium Source Placed: " ..
		bad_nodes.corium_placed[minor[d]] .. "]" .. "label[6.25,2.75;Chernobylite Placed: " ..
		bad_nodes.chernobylite_placed[minor[d]] .. "]" .. "label[6.25,3.25;Bad Language: " ..
		#bad_nodes.spoken_bad[minor[d]] .. "]"
		if #bad_nodes.spoken_bad[minor[d]] >= 1 then
			total = #bad_nodes.spoken_bad[minor[d]]
			words = minetest.serialize(bad_nodes.spoken_bad[minor[d]]):gsub("return ", ""):gsub("{", ""):gsub("}", ""):gsub("\"", "")
			formspec = formspec .. "label[8,.75;" .. minor[d] .. "]" .. "label[6.25,1.25;Lava Source Placed: " ..
			bad_nodes.lava_placed[minor[d]] .. "]" .. "label[6.25,1.75;Water Source Placed: " ..
			bad_nodes.water_placed[minor[d]] .. "]" .. "label[6.25,2.25;Corium Source Placed: " ..
			bad_nodes.corium_placed[minor[d]] .. "]" .. "label[6.25,2.75;Chernobylite Placed: " ..
			bad_nodes.chernobylite_placed[minor[d]] .. "]" .. "label[6.25,3.25;Bad Language: " ..
			tonumber(total) .. "]" .. "label[6.25,3.75;Words Spoken: " ..
			words .. "]"
		end
	end
	if add_on == 6 then
		formspec = formspec .. "checkbox[6,.75;remove;Situation Handled (Remove From Priority List);false]" ..
		"label[6,1.50;Checking the following automatically removes the player from the \npriority list.]" ..
		"checkbox[6,2.25;exempt;Exempt Player;false]" .. "checkbox[6,2.75;ban;Ban Player;false]" ..
		"box[5.9,1.5;5,1;red]" .. "button[5.75,6.75;2,1;apply;Apply]" .. "button[7.75,6.75;2,1;cancel;Cancel]"
	end
	if add_on == 7 then
		formspec = formspec .. "label[6,.75;No Player Selected.]"
	end
	if add_on == 8 then
		formspec = formspec .. "checkbox[6,.75;remove;Situation Handled (Remove From Priority List);false]" ..
		"label[6,1.50;Checking the following automatically removes the player from the \npriority list.]" ..
		"checkbox[6,2.25;exempt;Exempt Player;false]" .. "checkbox[6,2.75;ban;Ban Player;true]" ..
		"box[5.9,1.5;5,1;red]" .. "button[5.75,6.75;2,1;apply;Apply]" .. "button[7.75,6.75;2,1;cancel;Cancel]" ..
		"checkbox[6.5,3.25;default_message;Use Default Reason;true]" ..
		"label[6.5,4;Or]" .. "textarea[6.75,4.5;4,2;custom_reason;;" .. minetest.formspec_escape("") .. "]"
	end
	if add_on == 9 then
		formspec = formspec .. "checkbox[6,.75;remove;Situation Handled (Remove From Priority List);false]" ..
		"label[6,1.50;Checking the following automatically removes the player from the \npriority list.]" ..
		"checkbox[6,2.25;exempt;Exempt Player;true]" .. "checkbox[6,2.75;ban;Ban Player;false]" ..
		"box[5.9,1.5;5,1;red]" .. "button[5.75,6.75;2,1;apply;Apply]" .. "button[7.75,6.75;2,1;cancel;Cancel]"
	end
	if add_on == 10 then
		formspec = formspec .. "label[6,.75;You have not selected any priority players.]"
	end
	if add_on == 11 then
		formspec = formspec .. "label[8,9;Incorrect Fields Reset To Default: " .. c .. "]"
	end
	minetest.show_formspec(ptype, "server_monitor:main_screen", formspec)
end

minetest.register_chatcommand("sm", {
	description = "View players of interest.",
	func = function(name, param)
		if minetest.check_player_privs(name, {privs=true}) then
			minetest.show_formspec(name, "server_monitor:welcome",
				"size[12,10]" ..
				"background[0,0;12,10;welcome_bg.png;true]" ..
				"image[4.25,4;4,2;welcome_text.png]")
			minetest.after(2, function()
				local ptype = name
				main_screen(ptype, add_on)
			end)
		elseif minetest.check_player_privs(name, {basic_privs=true}) then
			minetest.show_formspec(name, "server_monitor:moderator",
				"size[5,5]" ..
				"background[0,0;5,5;welcome_bg.png;true]" ..
				"pwdfield[1,2;3,1;mod_pass;Moderator Access Keyword:;]" ..
				"button[2,3.5;2,1;pass_check;Get Access]")
		end
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local ptype = player:get_player_name()
	refined_major = priority_high()
	refined_minor = priority_low()
	if formname == "server_monitor:main_screen" then
		local event = minetest.explode_textlist_event(fields.high_priority)
		if event.type == "CHG" then
			if priority_high() == "" then
				local add_on = 1
				main_screen(ptype, add_on)
				a = 1
				b = 1
			else
				local add_on = 2
				d = event.index
				main_screen(ptype, add_on)
				a = 1
				b = 0
			end
		end
		local minor_event = minetest.explode_textlist_event(fields.low_priority)
		if event.type == "DCL" then
			local add_on = 3
			main_screen(ptype, add_on)
			a = 2
			b = 0
		elseif minor_event.type == "DCL" then
			local add_on = 3
			main_screen(ptype, add_on)
			a = 2
			b = 0
		end
		if minor_event.type == "CHG" then
			if priority_low() == "" then
				local add_on = 4
				main_screen(ptype, add_on)
				a = 3
				b = 1
			else
				local add_on = 5
				d = minor_event.index
				main_screen(ptype, add_on)
				a = 3
				b = 0
			end
		end
		if fields.actions then
			if a == 1 or a == 3 then
				if b == 0 then
					local add_on = 6
					main_screen(ptype, add_on)
				else
					local add_on = 7
					main_screen(ptype, add_on)
				end
			else
				local add_on = 7
				main_screen(ptype, add_on)
			end
		end
		if fields.cancel then
			local add_on = 6
			main_screen(ptype, add_on)
			remove = 0
			ban = 0
			exempt = 0
		end
		if fields.remove then
			remove = 1
		end
		if fields.ban then
			ban = 1
			if not fields.exempt then
				local add_on = 8
				main_screen(ptype, add_on)
			else
				local add_on = 8
				main_screen(ptype, add_on)
			end
		end
		if fields.exempt then
			exempt = 1
			local add_on = 9
			main_screen(ptype, add_on)
		end
		if fields.overview then
			if a == 1 then
				if b == 0 then
					local add_on = 2
					main_screen(ptype, add_on)
				else
					local add_on = 1
					main_screen(ptype, add_on)
				end
			elseif a == 2 then
				local add_on = 3
				main_screen(ptype, add_on)
			elseif a == 3 then
				if b == 0 then
					local add_on = 5
					main_screen(ptype, add_on)
				else
					local add_on = 4
					main_screen(ptype, add_on)
				end
			else
				local add_on = 10
				main_screen(ptype, add_on)
			end
		end
		if fields.options then
			local exempt_p = minetest.serialize(bad_nodes.exempt_players):gsub("return", ""):gsub("\"", ""):gsub("{", ""):gsub("}", "")
			local mak = minetest.serialize(bad_nodes.MAK):gsub("return", ""):gsub("\"", ""):gsub("{", ""):gsub("}", ""):gsub(" ", "")
			minetest.show_formspec(player:get_player_name(), "server_monitor:options_screen",
				"size[12,10]" ..
				"background[0,0;12,10;welcome_bg_beta.png;true]" ..
				"label[0,0;Low Priority Requirements:]" ..
				"field[.5,1;2,1;low_lava;Lave Source:;" .. minetest.formspec_escape(bad_nodes.low_lava) .. "]" ..
				"field[.5,2;2,1;low_water;Water Source:;" .. minetest.formspec_escape(bad_nodes.low_water) .. "]" ..
				"field[.5,3;2,1;low_corium;Corium Placed:;" .. minetest.formspec_escape(bad_nodes.low_corium) .. "]" ..
				"field[.5,4;2,1;low_chernobylite;Chernobylite Placed:;" .. minetest.formspec_escape(bad_nodes.low_chernobylite) .. "]" ..
				"label[3.5,0;High Priority Requirements:]" ..
				"field[4,1;2,1;high_lava;Lava Source:;" .. minetest.formspec_escape(bad_nodes.high_lava) .. "]" ..
				"field[4,2;2,1;high_water;Water Source:;" .. minetest.formspec_escape(bad_nodes.high_water) .. "]" ..
				"field[4,3;2,1;high_corium;Corium Placed:;" .. minetest.formspec_escape(bad_nodes.high_corium) .. "]" ..
				"field[4,4;2,1;high_chernobylite;Chernobylite Placed:;" .. minetest.formspec_escape(bad_nodes.high_chernobylite) .. "]" ..
				"textarea[.5,6;5,3;default_reason;Default Ban Reason:;" .. minetest.formspec_escape(bad_nodes.default_reason) .. "]" ..
				"field[8,2;3,1;mod_key;Moderator Access Keyword:;" .. minetest.formspec_escape(mak) .. "]" ..
				"textarea[7,3.5;4.5,2;exempt_list;Exempt Players:;" .. minetest.formspec_escape(exempt_p) .. "]" ..
				"textarea[7,5.75;4.5,2;bad_words;Bad Language:;" .. minetest.formspec_escape(bad_nodes.bad_language) .. "]" ..
				"button[7,8;2,1;options_apply;Apply]" ..
				"button[9,8;2,1;options_cancel;Cancel]")
		end
		if fields.apply then
			if remove == 1 then
				if a == 1 then
					bad_nodes.lava_placed[major[d]] = 0
					bad_nodes.water_placed[major[d]] = 0
					bad_nodes.corium_placed[major[d]] = 0
					bad_nodes.chernobylite_placed[major[d]] = 0
					bad_nodes.spoken_bad[major[d]] = {}
					save_nodes()
					remove = 0
					major = {}
					priority_high()
				elseif a == 3 then
					bad_nodes.lava_placed[minor[d]] = 0
					bad_nodes.water_placed[minor[d]] = 0
					bad_nodes.corium_placed[minor[d]] = 0
					bad_nodes.chernobylite_placed[minor[d]] = 0
					bad_nodes.spoken_bad[minor[d]] = {}
					save_nodes()
					remove = 0
					minor = {}
					priority_low()
				end
			end
			if exempt == 1 then
				local exempt_players = minetest.serialize(bad_nodes.exempt_players):gsub("return ", ""):gsub("{", ""):gsub("}", ""):gsub("\"", "")
				if a == 1 then
					if exempt_players == "" then
						bad_nodes.exempt_players = exempt_players .. major[d]
					else
						bad_nodes.exempt_players = exempt_players .. ", " .. major[d]
					end
					major = {}
					priority_high()
				elseif a == 3 then
					if exempt_players == "" then
						bad_nodes.exempt_players = exempt_players .. minor[d]
					else
						bad_nodes.exempt_players = exempt_players .. ", " .. minor[d]
					end
					minor = {}
					priority_low()
				end
				exempt = 0
			end
			if ban == 1 then
				if minetest.get_modpath("xban2") then
					if a == 1 then
						if fields.default_message then
							xban.ban_player(major[d], "Server Monitor", nil, bad_nodes.default_reason)
						else
							xban.ban_player(major[d], "Server Monitor", nil, fields.custom_reason)
						end
						bad_nodes.lava_placed[major[d]] = 0
						bad_nodes.water_placed[major[d]] = 0
						bad_nodes.corium_placed[major[d]] = 0
						bad_nodes.chernobylite_placed[major[d]] = 0
						bad_nodes.spoken_bad[major[d]] = {}
						major = {}
						priority_high()
					elseif a == 3 then
						if fields.default_message then
							xban.ban_player(minor[d], "Server Monitor", nil, bad_nodes.default_reason)
						else
							xban.ban_player(minor[d], "Server Monitor", nil, fields.custom_reason)
						end
						bad_nodes.lava_placed[minor[d]] = 0
						bad_nodes.water_placed[minor[d]] = 0
						bad_nodes.corium_placed[minor[d]] = 0
						bad_nodes.chernobylite_placed[minor[d]] = 0
						bad_nodes.spoken_bad[minor[d]] = {}
						minor = {}
						priority_low()
					end
				else
					if a == 1 then
						minetest.ban_player("\"" .. major[d] .. "\"")
						bad_nodes.lava_placed[major[d]] = 0
						bad_nodes.water_placed[major[d]] = 0
						bad_nodes.corium_placed[major[d]] = 0
						bad_nodes.chernobylite_placed[major[d]] = 0
						bad_nodes.spoken_bad[major[d]] = {}
						major = {}
						priority_high()
					elseif a == 3 then
						minetest.ban_player("\"" .. minor[d] .. "\"")
						bad_nodes.lava_placed[minor[d]] = 0
						bad_nodes.water_placed[minor[d]] = 0
						bad_nodes.corium_placed[minor[d]] = 0
						bad_nodes.chernobylite_placed[minor[d]] = 0
						bad_nodes.spoken_bad[minor[d]] = {}
						minor = {}
						priority_low()
					end
				end
				ban = 0
			end
			main_screen(ptype, add_on)
			save_nodes()
		end
	end
	if formname == "server_monitor:options_screen" then
		if fields.options_apply then
			if not fields.low_lava:match("%D") then
				bad_nodes.low_lava = fields.low_lava
			else
				c = c + 1
			end
			if not fields.low_water:match("%D") then
				bad_nodes.low_water = fields.low_water
			else
				c = c + 1
			end
			if not fields.low_corium:match("%D") then
				bad_nodes.low_corium = fields.low_corium
			else
				c = c + 1
			end
			if not fields.low_chernobylite:match("%D") then
				bad_nodes.low_chernobylite = fields.low_chernobylite
			else
				c = c + 1
			end
			if not fields.high_lava:match("%D") then
				bad_nodes.high_lava = fields.high_lava
			else
				c = c + 1
			end
			if not fields.high_water:match("%D") then
				bad_nodes.high_water = fields.high_water
			else
				c = c + 1
			end
			if not fields.high_corium:match("%D") then
				bad_nodes.high_corium = fields.high_corium
			else
				c = c + 1
			end
			if not fields.high_chernobylite:match("%D") then
				bad_nodes.high_chernobylite = fields.high_chernobylite
			else
				c = c + 1
			end
			bad_nodes.default_reason = fields.default_reason
			if not fields.mod_key:match(" ") then
				bad_nodes.MAK = fields.mod_key
			else
				c = c + 1
			end
			bad_nodes.exempt_players = fields.exempt_list
			save_nodes()
			minor = {}
			major = {}
			priority_low()
			priority_high()
			if c > 0 then
				local add_on = 11
				main_screen(ptype, add_on)
				c = 0
			else
				main_screen(ptype, add_on)
			end
		end
		if fields.options_cancel then
			main_screen(ptype, add_on)
		end
	end
	if formname == "server_monitor:moderator" then
		if fields.pass_check then
			if fields.mod_pass == bad_nodes.MAK then
				main_screen(ptype, add_on)
			else
				minetest.show_formspec(player:get_player_name(), "server_monitor:moderator",
					"size[5,5]" ..
					"background[0,0;5,5;welcome_bg_beta.png;true]" ..
					"pwdfield[1,2;3,1;mod_pass;Moderator Access Keyword:;]" ..
					"button[2,3.5;2,1;pass_check;Get Access]" ..
					"label[1,3;Incorrect Moderator Access Keyword (MAK)]")
			end
		end
	end
end)
