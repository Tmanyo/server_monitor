# server_monitor
This mod allows you to keep the peace on your Minetest server!

# Operators Manual
# Description:
 - This mod is designed to detect nodes placed that can be hazardous to the server and other players.  Server Monitor also monitors chat
 by watching to see if any bad language is used.  Overall, it is designed for server hosts/admins.  However, if a moderator has a
 Moderator Access Keyword (MAK), they can access it as well.
 # Chatcommand:
  - The chatcommand is very simple and easy to remember.  It is "sm" which stands for Server Monitor.
  # Main Screen of the Graphical User Interface (GUI):
   - When the form is first opened a screen will welcome you for 2 seconds and will procede onto the main screen.  At the left you can see
   two black boxes.  The top black box will contain players that have met the requirements to be placed there.  Players start in the bottom
   box when they do something wrong.  The bottom box is for the lower priority players.  These players haven't done as much as the players
   in the top box.  At the right, you can see a black outlined box.  When you click on a player's name, it will show who they are and what
   they have done wrong.  You can do several things.  If you click on the "Actions" button, you can choose to remove the person from the
   list and perhaps handle the issue yourself or you can choose to ban or exempt them.  If xban2 is installed, the ban will ban the player's IP
   and will record it in the xban log.  When you click on "Ban" you can choose to use the default reason which can be found on the options
   screen or you can create a custom reason specifically for that player.  If you choose to "Exempt" the player, they will be removed from
   the list and placed in the exempt players list which can also be accessed from the options screen.  If a player is exempt, they will no
   longer show up on either priority list if they do something wrong.
