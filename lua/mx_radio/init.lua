--[[
  __  __        _____           _ _       
 |  \/  |      |  __ \         | (_)      
 | \  / |_  __ | |__) |__ _  __| |_  ___  
 | |\/| \ \/ / |  _  // _` |/ _` | |/ _ \ 
 | |  | |>  <  | | \ \ (_| | (_| | | (_) |
 |_|  |_/_/\_\ |_|  \_\__,_|\__,_|_|\___/ 
 
  Copyright (C) 2013-2015  Max (github.com/LinMax)

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]
AddCSLuaFile("cl_car_radio.lua")

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Serverside Stuff
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////
// Station File Setup
//Check if file exists, and create it if it doesn't
///////////////////////////////////////////////////////////////

	//see if file exsists
	if !file.Exists( "mxradio.txt", "DATA" ) then

		StationFile = {}
		
		
		StationFile[1] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=57352&play_status=1",
			info = "HouseTime.FM - 24h House"
		}

		StationFile[2] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=148196&play_status=1",
			info = "DUBSTEP.FM"
		}

		StationFile[3] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=138394&play_status=1",
			info = "Club Dubstep"
		}

		StationFile[4] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=714697&play_status=1",
			info = "1.FM - CLASSIC ROCK"
		}

		StationFile[5] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=135132&play_status=1",
			info = "ChroniX"
		}

		StationFile[6] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=71887&play_status=1",
			info = "181.FM - Kickin' Country"
		}

		StationFile[7] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=557801&play_status=1",
			info = "181.FM - Real Country"
		}

		StationFile[8] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=86433&play_status=1",
			info = "Absolutely Smooth Jazz"
		}

		StationFile[9] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=32999&play_status=1",
			info = "HOT 108 JAMZ"
		}

		StationFile[10] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=109295&play_status=1",
			info = "Bates FM - 104.3 Jamz"
		}

		StationFile[11] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=7540&play_status=1",
			info = "CINEMIX Classical / New Age"
		}

		StationFile[12] = {
			stationURL = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=212505&play_status=1",
			info = "Adagio.FM - Timeless Classical"
		}

		local SFile = file.Open( "mxradio.txt", "a", "DATA" )
		if !SFile then return end
		for  k,v in pairs(StationFile) do
			SFile:Write(v.stationURL.."\n")
			SFile:Write(v.info.."\n")
		end
		SFile:Close()
	end
///////////////////////////////////////////////////////////////////////////////////
//
// End Station File Setup
//
///////////////////////////////////////////////////////////////////////////////////

	radios ={}
	RadioNum =0

	util.AddNetworkString( "StationChange" )
	util.AddNetworkString( "RMenu" )
	util.AddNetworkString( "UpdateStation" )
	util.AddNetworkString( "CStationUpload" )
	util.AddNetworkString( "DeleteStation" )
	util.AddNetworkString( "GetCar" )

/////////////////////////////////////////////////////////////
// Setup Stations table
/////////////////////////////////////////////////////////////
	function SetUpStationTable()
		stations = {}
		local SFile = file.Read("mxradio.txt", "DATA")
		SFile = string.Split( SFile, "\n" )
		for  i=1, (table.getn(SFile) -1), 2 do
			stations[table.getn(stations) + 1] = {
				stationURL = SFile[i],
				info = SFile[i +1]
			}
		end
	end
	SetUpStationTable()

	
/////////////////////////////////////////////////////////////
//Receive Station Change
/////////////////////////////////////////////////////////////
	net.Receive( "StationChange", function( len, pl )
		station = net.ReadString()
		radio = net.ReadEntity()
		//send station to all players
		SendToAll(station, radio)
	end )
/////////////////////////////////////////////////////////////
//Delete Station 
/////////////////////////////////////////////////////////////
	net.Receive( "DeleteStation", function( len, pl )
		info = net.ReadString()
		DeleteStation(info)
	end )
	
	function DeleteStation(info)
		for k,v in pairs(stations) do
			if v.info == info then
				table.remove( stations, k)
			end
		end
		file.Delete( "mxradio.txt" )
		local SFile = file.Open( "mxradio.txt", "a", "DATA" )
		if !SFile then return end
		for  k,v in pairs(stations) do
			SFile:Write(v.stationURL.."\n")
			SFile:Write(v.info.."\n")
		end
		SFile:Close()
	end

/////////////////////////////////////////////////////////////
//Receive Custom Station 
/////////////////////////////////////////////////////////////
	net.Receive( "CStationUpload", function( len, pl )
		station = net.ReadString()
		info = net.ReadString()
		//Save the Station to the text file
		local SFile = file.Open( "mxradio.txt", "a", "DATA" )
			if !SFile then return end
			SFile:Write(station.."\n")
			SFile:Write(info.."\n")
			SFile:Close()
		SetUpStationTable()
	end )
	
/////////////////////////////////////////////////////////////
//Send Station to all Players
/////////////////////////////////////////////////////////////
	
	function SendToAll(station, radio)
		net.Start( "UpdateStation" )
			net.WriteString(station)
			net.WriteEntity(radio)
		net.Broadcast()
		for k,v in pairs(radios) do
			if radio == v.RadioEnt then
				radios[k] = {
					station = station,
					RadioEnt = radio,
				}
			end
		end
		if !RadioExsists(radio) then
			radios[RadioNum] = {
				station = station,
				RadioEnt = radio,
			}
			RadioNum = RadioNum +1
		end
	end
/////////////////////////////////////////////////////////////
//Manage Radios and their stations
/////////////////////////////////////////////////////////////
	function RadioManager()
		if (table.Count(radios) > 0) then
			for k,v in pairs (radios) do
				if !v.RadioEnt:IsValid() || v.station == "stop" then
					table.remove(radios, k)
				end
			end
		end
	end
	hook.Add( "Think", "Radio_Manager", RadioManager)
	function RadioExsists(radio)
		for k,v in pairs(radios) do
			if (v.RadioEnt == radio ) then return true end
		end
		return false
	end
	
	//Make the radios play when the player firsts spawns, if the radios where created before they joined
	function PlayerFirstSpawn( ply )
		if (table.Count(radios) > 0) then
			for k,v in pairs(radios) do
				NewJoinUpdate(ply, v.station, v.RadioEnt)
			end
		end
	end
	hook.Add( "PlayerInitialSpawn", "playerFirstSpawn", PlayerFirstSpawn )
	function NewJoinUpdate(ply, NewStation, RadioEnt)
		timer.Simple( 1, function()
			net.Start( "UpdateStation" )
				net.WriteString(NewStation)
				net.WriteEntity(RadioEnt)
			net.Send( ply )
		end )
	end
/////////////////////////////////////////////////////////////
//Start Rmenu
/////////////////////////////////////////////////////////////
function StartRMenu(ply, radio)
	net.Start( "RMenu" )
		net.WriteEntity(radio)
		net.WriteTable(stations)
	net.Send(ply)
end

/////////////////////////////////////////////////////////////
//Recieve Car Menu
/////////////////////////////////////////////////////////////
	net.Receive( "GetCar", function( len, pl )
		ply = net.ReadEntity()
		car = net.ReadEntity()
		StartRMenu(ply, car)
	end )