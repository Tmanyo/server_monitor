bad_nodes = {}
bad_nodes.lava_placed = {}
bad_nodes.water_placed = {}
bad_nodes.corium_placed = {}
bad_nodes.chernobylite_placed = {}

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
end)

-- If there isn't a file, make one.
local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "r")
if f == nil then
     local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "w")
     f:write(minetest.serialize(bad_nodes))
     f:close()
end

-- Saves changes to player's account.
function save_nodes()
     local data = bad_nodes
     local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "w")
     if err then
          return err
     end
     f:write(minetest.serialize(data))
     f:close()
end

-- Reads changes from player's account.
function read_nodes()
     local f, err = io.open(minetest.get_worldpath() .. "/player_tracker", "r")
     local data = minetest.deserialize(f:read("*a"))
     f:close()
          return data
end

bad_nodes = read_nodes()

local major = {}
function priority_high()
	for k,v in pairs(bad_nodes.lava_placed) do
		if v >= 5 then
			table.insert(major, k)
		end
	end
	for k,v in pairs(bad_nodes.water_placed) do
		if v >= 30 then
			table.insert(major, k)
		end
	end
	for k,v in pairs(bad_nodes.corium_placed) do
		if v >= 1 then
			table.insert(major, k)
		end
	end
	for k,v in pairs(bad_nodes.chernobylite_placed) do
		if v >= 2 then
			table.insert(major, k)
		end
	end
	if #major == 0 or nil then
		table.insert(major, "None")
	end
	local refined_major = minetest.serialize(major):gsub("return", ""):gsub("\"", ""):gsub("{", ""):gsub("}", ""):gsub(" ", "")
	return refined_major
end

local minor = {}
function priority_low()
	for k,v in pairs(bad_nodes.lava_placed) do
		if v >= 1 then
			if v <= 4 then
				table.insert(minor, k)
			end
		end
	end
	for k,v in pairs(bad_nodes.water_placed) do
		if v >= 1 then
			if v <= 29 then
				table.insert(minor, k)
			end
		end
	end
	for k,v in pairs(bad_nodes.corium_placed) do
		if v == 0 then
			table.insert(minor, k)
		end
	end
	for k,v in pairs(bad_nodes.chernobylite_placed) do
		if v == 1 then
			table.insert(minor, k)
		end
	end
	if #minor == 0 or nil then
		table.insert(minor, "None")
	end
	local refined_minor = minetest.serialize(minor):gsub("return", ""):gsub("\"", ""):gsub("{", ""):gsub("}", ""):gsub(" ", "")
	return refined_minor
end
			

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local playername = placer:get_player_name()
	if newnode.name == "default:lava_source" then
		if not bad_nodes.lava_placed[playername] then
			bad_nodes.lava_placed[playername] = 1
		else
			bad_nodes.lava_placed[playername] = bad_nodes.lava_placed[playername] + 1
		end
	elseif newnode.name == "default:water_source" then
		if not bad_nodes.water_placed[playername] then
			bad_nodes.water_placed[playername] = 1
		else
			bad_nodes.water_placed[playername] = bad_nodes.water_placed[playername] + 1
		end
	end
	if minetest.get_modpath("technic") then
		if newnode.name == "technic:chernobylite_block" then
			if not bad_nodes.chernobylite_placed[playername] then
				bad_nodes.chernobylite_placed[playername] = 1
			else
				bad_nodes.chernobylite_placed[playername] = bad_nodes.chernobylite_placed[playername] + 1
			end
		elseif newnode.name == "technic:corium_source" then
			if not bad_nodes.corium_placed[playername] then
				bad_nodes.corium_placed[playername] = 1
			else
				bad_nodes.corium_placed[playername] = bad_nodes.corium_placed[playername] + 1
			end
		end
	end
	save_nodes()
end)

formspec = "size[12,10]" .. 
	"background[0,0;12,10;welcome_bg.png;true]" ..
	"label[.5,-.25;Potential High Priority:]" ..
	"textlist[.5,.25;4,5;high_priority;" .. priority_high() .. ";;false]" ..
	"label[.5,5.25;Potential Low Priority:]" ..
	"textlist[.5,5.75;4,4.5;low_priority;" .. priority_low() .. ";;false]" ..
	"tabheader[6,1;player_stats;Overview,Action;1;;false]" ..
	"image[5.71,.65;7,7;action_bg.png]"

info_text = "label[6,.75;Welcome!  This is a useful tool for server hosts/admins\nthat can't afford to spend time on their server" ..
	" all day.\nTo find out more information as to why a player is on a\npriority list, click their name.  In the overview tab" ..
	" it\nshows the reason why.  In the action tab, you can\nchoose what you want to do about the situation.\nHowever, as always" ..
	" you can handle the situation on\nyour own."

minetest.register_chatcommand("poi", {
	description = "View players of interest.",
	func = function(name, param)
		if minetest.check_player_privs(name, {privs=true}) then
			minetest.show_formspec(name, "server_monitor:welcome",
				"size[12,10]" .. 
				"background[0,0;12,10;welcome_bg.png;true]" ..
				"image[4.25,4;4,2;welcome_text.png]")
			minetest.after(2, function()
				minetest.show_formspec(name, "server_monitor:main_screen", formspec)
			end)
		else
			minetest.chat_send_player(name, "[Server] Access Denied, you must be an admin!")
		end
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "server_monitor:main_screen" then
		local event = minetest.explode_textlist_event(fields.high_priority)
		if event.type == "CHG" then
			if major[1] == "None" then
				formspec1 = formspec .. "label[6,.75;There are no high priority players at this time.]"
				minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec1)
			else
				formspec1 = formspec .. "label[8,.75;" .. major[event.index] .. "]" .. "label[6.25,1.25;Lava Source Placed: " ..
				bad_nodes.lava_placed[major[event.index]] .. "]" .. "label[6.25,1.75;Water Source Placed: " ..
				bad_nodes.water_placed[major[event.index]] .. "]" .. "label[6.25,2.25;Corium Source Placed: " ..
				bad_nodes.corium_placed[major[event.index]] .. "]" .. "label[6.25,2.75;Chernobylite Placed: " ..
				bad_nodes.chernobylite_placed[major[event.index]] .. "]"
				minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec1)
			end
		end
		local minor_event = minetest.explode_textlist_event(fields.low_priority)
		if event.type == "DCL" then
			formspec2 = formspec .. info_text
			minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec2)
		elseif minor_event.type == "DCL" then
			formspec2 = formspec .. info_text
			minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec2)
		end
		if minor_event.type == "CHG" then
			if minor[1] == "None" then
				formspec3 = formspec .. "label[6,.75;There are no low priority players at this time.]"
				minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec3)
			else
				formspec3 = formspec .. "label[8,.75;" .. minor[minor_event.index] .. "]" .. "label[6.25,1.25;Lava Source Placed: " ..
				bad_nodes.lava_placed[minor[minor_event.index]] .. "]" .. "label[6.25,1.75;Water Source Placed: " ..
				bad_nodes.water_placed[minor[minor_event.index]] .. "]" .. "label[6.25,2.25;Corium Source Placed: " ..
				bad_nodes.corium_placed[minor[minor_event.index]] .. "]" .. "label[6.25,2.75;Chernobylite Placed: " ..
				bad_nodes.chernobylite_placed[minor[minor_event.index]] .. "]"
				minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec3)
			end
		end
		if fields.player_stats[2] then
			formspec4 = formspec .. "label[6,.75;Cows go moo!]"
			minetest.show_formspec(player:get_player_name(), "server_monitor:main_screen", formspec4)
		end
	end
end)
			
			
