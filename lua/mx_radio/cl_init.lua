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
include("cl_car_radio.lua")
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Clientside Stuff
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	local stream_volume = CreateClientConVar("stream_volume", "100", true, false)
	local stream_distance = CreateClientConVar("stream_distance", "1000", true, false)
	local stream_number = CreateClientConVar("stream_number", "2", true, false)
	local stream_3d = CreateClientConVar("stream_3d", "1", true, false)
	
	ChanNum = 0
	Channels = {}

	surface.CreateFont("MenuLarge", {
			font = "Verdana",
			size = 15,
			weight = 600,
			antialias = true,
	})

	surface.CreateFont( "WinLarge", {
		font = "Trebuchet MS",
		size = 32,
		weight = 900,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= true
	} )

	surface.CreateFont( "WinSmall", {
		font = "Trebuchet MS",
		size = 20,
		weight = 900,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= true
	} )
	
/////////////////////////////////////////////////////////////
//Change station
/////////////////////////////////////////////////////////////
	function changeStation(station, radio)
	
		if (station == "stop" && radio:IsValid()) then
			for k,v in pairs (Channels) do
				if (v.radio == radio) then
					StopStream(v.Channel, v.ChanNum)
				end
			end
		elseif radio:IsValid() then
			sound.PlayURL( station, ThreeDSound().." play loop", function( chan )
				if chan && chan:IsValid() then
					chan:SetPos(radio:GetPos())
					chan:SetVolume(stream_volume:GetInt() / 100)
					StreamSetup(station, radio, chan)
				else
					LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream Not Responding, Please Try Again later.")
				end
			end )
		end
		PrintTable(Channels)
	end
	
function ThreeDSound()
	if (stream_3d:GetBool()) then
		return "3d mono"
	else
		return ""
	end
end

/////////////////////////////////////////////////////////////
//Setup the stream
/////////////////////////////////////////////////////////////
	function StreamSetup(station, radio, chan)
		for k,v in pairs (Channels) do
			if (v.radio == radio) then
				StopStream(v.Channel, v.ChanNum)
			end
		end
		ChanNum = ChanNum + 1
		Channels[ChanNum] = {
			ChanNum = ChanNum,
			Channel = chan,
			station = station,
			radio = radio,
			playing = false,
		}
	end

/////////////////////////////////////////////////////////////
//Manage streams
/////////////////////////////////////////////////////////////
	function StreamManager()
		local num = 0
		if (table.Count(Channels) > 0) then
			for k,v in pairs (Channels) do
				if (!v.radio:IsValid() && v.Channel:IsValid()) then
					StopStream(v.Channel, v.ChanNum)
				else
					if stream_3d:GetBool() then
						v.Channel:SetVolume(stream_volume:GetInt() / 100)
						v.Channel:SetPos(v.radio:GetPos())
					else
						local volume = (((-(v.radio:GetPos():Distance(LocalPlayer():GetPos())) + stream_distance:GetInt()) / stream_distance:GetInt()) * (stream_volume:GetInt() / 100))
						v.Channel:SetVolume(volume)
					end
					if (v.radio:GetPos():Distance(LocalPlayer():GetPos()) > stream_distance:GetInt()) then
						v.playing = false
						v.Channel:Pause()
						num = num -1
					else
						if !v.playing then
							v.playing = true
							v.Channel:Play()
						end
					end
				end
			end
		end
	end
	hook.Add( "Think", "Stream_Manager", StreamManager)

/////////////////////////////////////////////////////////////
//Stop the station, and clear it out of the Channels table
/////////////////////////////////////////////////////////////
	function StopStream(chan, ChanNum)
		chan:Stop()
		Channels[ChanNum] = nil
	end


/////////////////////////////////////////////////////////////
//Menu
/////////////////////////////////////////////////////////////
	function RadioMenu(radio)
		local RPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
		RPanel:SetSize( 300, 400 ) -- Size of the frame
		RPanel:SetTitle( "Mx Radio" ) -- Title of the frame
		RPanel:SetVisible( true )
		RPanel:SetDraggable( true ) -- Draggable by mouse?
		RPanel:ShowCloseButton( true ) -- Show the close button?
		RPanel:MakePopup() -- Show the frame
		RPanel:Center()
		RPanel:MakePopup()
	
		local PropertySheet = vgui.Create( "DPropertySheet" )
		PropertySheet:SetParent( RPanel )
		PropertySheet:SetPos( 10, 30 )
		PropertySheet:SetSize( RPanel:GetWide() - 20, RPanel:GetTall() - 40 )
	
		local SheetItem1 = vgui.Create( "DPanel")
		SheetItem1:SetPos( 0, 0 )
		SheetItem1:SetSize( PropertySheet:GetWide() - 4, PropertySheet:GetTall() - 22 )
	
		local SheetItem2 = vgui.Create( "DPanel" )
		SheetItem2:SetPos( 0, 0 )
		SheetItem2:SetSize( PropertySheet:GetWide() - 4, PropertySheet:GetTall() - 22 )
		SheetItem2.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawRect( 0, 0, SheetItem2:GetWide(), SheetItem2:GetTall() ) -- Draw the rect
		end
	
		PropertySheet:AddSheet( "Stations", SheetItem1, "icon16/sound.png", false, false, "Radio Stations" )
		PropertySheet:AddSheet( "Settings", SheetItem2, "icon16/wrench_orange.png", false, false, "Settings" )
	
		//Allow Admins to add stations to the server
		if LocalPlayer():IsAdmin() || LocalPlayer():IsSuperAdmin() then
			
		
		end
	
		local StreamList = vgui.Create("DListView", SheetItem1)
		StreamList:SetPos(0, 0)
		StreamList:SetSize(PropertySheet:GetWide() - 16, PropertySheet:GetTall() - 36)
		StreamList:SetMultiSelect(false)
		StreamList:AddColumn("Stations")
		StreamList.OnClickLine = function(parent, line, isselected)
			for k,v in pairs(stations) do
				if (v.info == line:GetValue(1)) then
					station = v.stationURL
					info = v.info
				end
			end
			if (LocalPlayer():IsAdmin() || LocalPlayer():IsSuperAdmin()) then
				local MenuOptions = DermaMenu()
				MenuOptions:AddOption("Change to " .. line:GetValue(1), function()
					StationChange(station, radio)
					LocalPlayer():PrintMessage( HUD_PRINTTALK , "Radio Changed to: " .. info)
				end ):SetImage( "icon16/sound.png" )
				
				MenuOptions:AddOption("Turn Off Radio", function()
					StationChange("stop", radio)
				end ):SetImage( "icon16/sound_mute.png" )
				
				MenuOptions:AddOption("Play Custom Station", function()
					CustomStreamMenu(radio)
				end ):SetImage( "icon16/database_add.png" )
				
				MenuOptions:AddOption("Add New Station", function()
					AddStationMenu(radio)
				end ):SetImage( "icon16/add.png" )
				
				MenuOptions:AddOption("Delete Station", function()
					DeleteStation(info)
				end ):SetImage( "icon16/delete.png" )
				MenuOptions:Open()
			else
				local MenuOptions = DermaMenu()
				MenuOptions:AddOption("Change to " .. line:GetValue(1), function()
					StationChange(station, radio)
					LocalPlayer():PrintMessage( HUD_PRINTTALK , "Radio Changed to: " .. info)
				end ):SetImage( "icon16/sound.png" )
				
				MenuOptions:AddOption("Turn Off Radio", function()
					StationChange("stop", radio)
				end ):SetImage( "icon16/sound_mute.png" )
				
				MenuOptions:AddOption("Play Custom Station", function()
					CustomStreamMenu(radio)
				end ):SetImage( "icon16/database_add.png" )
				MenuOptions:Open()
			end
		end
		for k,v in pairs(stations) do
			StreamList:AddLine(v.info)
		end
	
		local TwoLabel1 = vgui.Create( "DLabel", SheetItem2 )
		TwoLabel1:SetPos( 2, 10 )
		TwoLabel1:SetFont("WinSmall")
		TwoLabel1:SetText( "Client-Side Settings")
		TwoLabel1:SizeToContents()
	
		local VolumeSlide = vgui.Create( "DNumSlider", SheetItem2 )
		VolumeSlide:SetSize( 275, 100 ) -- Keep the second number at 100
		VolumeSlide:SetPos(3, 0)
		VolumeSlide:SetText( "Stream Volume" )
		VolumeSlide:SetMin( 0 ) -- Minimum number of the slider
		VolumeSlide:SetMax( 100 ) -- Maximum number of the slider
		VolumeSlide:SetDecimals( 0 ) -- Sets a decimal. Zero means it's a whole number
		VolumeSlide:SetConVar( "stream_volume" ) -- Set the convar
	
		local DistanceSlide = vgui.Create( "DNumSlider", SheetItem2 )
		DistanceSlide:SetSize( 275, 100 ) -- Keep the second number at 100
		DistanceSlide:SetPos(3, 75)
		DistanceSlide:SetText( "Stream Fade Distance" )
		DistanceSlide:SetMin( 100 ) -- Minimum number of the slider
		DistanceSlide:SetMax( 1500 ) -- Maximum number of the slider
		DistanceSlide:SetDecimals( 0 ) -- Sets a decimal. Zero means it's a whole number
		DistanceSlide:SetConVar( "stream_distance" ) -- Set the convar
		
		local TDCheckBox = vgui.Create( "DCheckBoxLabel", SheetItem2 )
		TDCheckBox:SetPos( 3,200 )
		TDCheckBox:SetText( "Enable 3D sound" )
		TDCheckBox:SetConVar( "stream_3d" ) -- ConCommand must be a 1 or 0 value
		TDCheckBox:SetValue( stream_3d:GetBool() )
		TDCheckBox:SizeToContents() -- Make its size to the contents. Duh?
	end
	
	function CustomStreamMenu(radio)
		local CSFrame = vgui.Create( "DFrame" ) -- Creates the frame itself
		CSFrame:SetSize( 376, 200 ) -- Size of the frame
		CSFrame:SetTitle( "Custom Radio Stream" ) -- Title of the frame
		CSFrame:SetVisible( true )
		CSFrame:SetDraggable( true ) -- Draggable by mouse?
		CSFrame:ShowCloseButton( true ) -- Show the close button?
		CSFrame:MakePopup() -- Show the frame
		CSFrame:Center()
		CSFrame:MakePopup()
		
		local CSPanel = vgui.Create( "DPanel", CSFrame )
		CSPanel:SetPos( 4, 24 )
		CSPanel:SetSize( CSFrame:GetWide() - 8, CSFrame:GetTall() - 28 )
		CSPanel.Paint = function()
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 0, CSPanel:GetWide(), CSPanel:GetTall() )
		end
		
		local ThreeLabel1 = vgui.Create( "DLabel", CSPanel )
		ThreeLabel1:SetPos( 2, 100 )
		ThreeLabel1:SetFont("WinSmall")
		ThreeLabel1:SetText( "Enter Custom Stream URL")
		ThreeLabel1:SizeToContents()
	
		local ThreeLabel2 = vgui.Create( "DLabel", CSPanel )
		ThreeLabel2:SetPos( 2, 0 )
		ThreeLabel2:SetFont("WinSmall")
		ThreeLabel2:SetText( ">Stream must contain 'http'")
		ThreeLabel2:SizeToContents()
	
		local ThreeLabel3 = vgui.Create( "DLabel", CSPanel )
		ThreeLabel3:SetPos( 2, 20 )
		ThreeLabel3:SetFont("WinSmall")
		ThreeLabel3:SetText( ">Do not include quotations or other symbols")
		ThreeLabel3:SizeToContents()
	
		local ThreeLabel4 = vgui.Create( "DLabel", CSPanel )
		ThreeLabel4:SetPos( 2, 50 )
		ThreeLabel4:SetFont("WinSmall")
		ThreeLabel4:SetText( "Example:")
		ThreeLabel4:SizeToContents()
	
		local ThreeLabel5 = vgui.Create( "DLabel", CSPanel )
		ThreeLabel5:SetPos( 2, 70 )
		ThreeLabel5:SetText( "http://yp.shoutcast.com/sbin/tunein-station.pls?id=66666&play_status=1")
		ThreeLabel5:SizeToContents()
	
		local StreamEntry = vgui.Create( "DTextEntry", CSPanel )
		StreamEntry:SetPos( 2, 120 )
		StreamEntry:SetTall( 20 )
		StreamEntry:SetWide( 353 )
		StreamEntry:SetEnterAllowed( false )
	
		local SubmitButton = vgui.Create( "DButton", CSPanel )
		SubmitButton:SetText( "Submit" )
		SubmitButton:SetPos( 280, 140 )
		SubmitButton:SetSize( 75, 30 )
		SubmitButton.DoClick = function ()
			//Custom Station url to check
			CheckStation = string.Trim(StreamEntry:GetValue())
			//Don't check useless crap
			if( string.match(CheckStation, "http") )then
				//is it a real stream?
				sound.PlayURL( CheckStation, "3d mono noplay loop", function( chan )
					if chan && chan:IsValid() then
						chan:Stop()
						LocalPlayer():PrintMessage( HUD_PRINTTALK , "Valid Stream!")
						StationChange(CheckStation, radio)
						CSFrame:Close()
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream Not Valid!")
					end
				end)
			else
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream Not Valid!")
			end
		end
		
	end
	
	function AddStationMenu(radio)
	
		local ASFrame = vgui.Create( "DFrame" ) -- Creates the frame itself
		ASFrame:SetSize( 376, 280 ) -- Size of the frame
		ASFrame:SetTitle( "Add Radio Station" ) -- Title of the frame
		ASFrame:SetVisible( true )
		ASFrame:SetDraggable( true ) -- Draggable by mouse?
		ASFrame:ShowCloseButton( true ) -- Show the close button?
		ASFrame:MakePopup() -- Show the frame
		ASFrame:Center()
		ASFrame:MakePopup()
	
		local ASPanel = vgui.Create( "DPanel", ASFrame)
		ASPanel:SetPos( 4, 24 )
		ASPanel:SetSize( ASFrame:GetWide() - 8, ASFrame:GetTall() - 28 )
		ASPanel.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawRect( 0, 0, ASFrame:GetWide(), ASFrame:GetTall() ) -- Draw the rect
		end
		
		local FourLabel = vgui.Create( "DLabel", ASPanel )
		FourLabel:SetPos( 2, 140 )
		FourLabel:SetFont("WinSmall")
		FourLabel:SetText( "Enter Custom Stream URL")
		FourLabel:SizeToContents()
		
		local FourLabel1 = vgui.Create( "DLabel", ASPanel )
		FourLabel1:SetPos( 2, 180 )
		FourLabel1:SetFont("WinSmall")
		FourLabel1:SetText( "Enter Custom Stream Info")
		FourLabel1:SizeToContents()
	
		local FourLabel2 = vgui.Create( "DLabel", ASPanel )
		FourLabel2:SetPos( 2, 0 )
		FourLabel2:SetFont("WinSmall")
		FourLabel2:SetText( ">Stream must contain 'http'")
		FourLabel2:SizeToContents()
	
		local FourLabel3 = vgui.Create( "DLabel", ASPanel )
		FourLabel3:SetPos( 2, 20 )
		FourLabel3:SetFont("WinSmall")
		FourLabel3:SetText( ">Do not include quotations or other symbols")
		FourLabel3:SizeToContents()
		
		local FourLabel35 = vgui.Create( "DLabel", ASPanel )
		FourLabel35:SetPos( 2, 40 )
		FourLabel35:SetFont("WinSmall")
		FourLabel35:SetText( ">Keep Station Info Short (<30 Charecters)")
		FourLabel35:SizeToContents()
	
		local FourLabel4 = vgui.Create( "DLabel", ASPanel )
		FourLabel4:SetPos( 2, 70 )
		FourLabel4:SetFont("WinSmall")
		FourLabel4:SetText( "Example:")
		FourLabel4:SizeToContents()
	
		local FourLabel5 = vgui.Create( "DLabel", ASPanel )
		FourLabel5:SetPos( 2, 90 )
		FourLabel5:SetText( "http://yp.shoutcast.com/sbin/tunein-station.pls?id=6666&play_status=1")
		FourLabel5:SizeToContents()
		
		local FourLabel6 = vgui.Create( "DLabel", ASPanel )
		FourLabel6:SetPos( 2, 110 )
		FourLabel6:SetText( "FM Station Music")
		FourLabel6:SizeToContents()
	
		local Stream1Entry = vgui.Create( "DTextEntry", ASPanel )
		Stream1Entry:SetPos( 2, 160 )
		Stream1Entry:SetTall( 20 )
		Stream1Entry:SetWide( 353 )
		Stream1Entry:SetEnterAllowed( false )
		
		local InfoEntry = vgui.Create( "DTextEntry", ASPanel )
		InfoEntry:SetPos( 2, 200 )
		InfoEntry:SetTall( 20 )
		InfoEntry:SetWide( 353 )
		InfoEntry:SetEnterAllowed( false )
		InfoEntry:SetAllowNonAsciiCharacters( false )
	
		local SubmitButton1 = vgui.Create( "DButton", ASPanel )
		SubmitButton1:SetText( "Submit" )
		SubmitButton1:SetPos( 280, 220 )
		SubmitButton1:SetSize( 75, 30 )
		SubmitButton1.DoClick = function ()
			CheckStation = string.Trim(Stream1Entry:GetValue())
			CheckInfo = string.Trim(InfoEntry:GetValue())
			if (string.len( CheckInfo ) > 30) then
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream Info Can only be 30 Charecters")
			elseif (string.len( CheckInfo ) < 3) then
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream Info Can Must be at least 3 Charecters")
			elseif( !string.match(CheckStation, "http") )then
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream URL Not Valid!")
			else
				//is it a real stream?
				sound.PlayURL( CheckStation, "3d mono noplay loop", function( chan )
					if chan && chan:IsValid() then
						chan:Stop()
						LocalPlayer():PrintMessage( HUD_PRINTTALK , "Valid Stream! Uploading...")
						LocalPlayer():PrintMessage( HUD_PRINTTALK , "Re-open Menu to see added Station!")
						net.Start( "CStationUpload" )
							net.WriteString(CheckStation)
							net.WriteString(CheckInfo)
						net.SendToServer()
						if ASFrame then
							ASFrame:Close()
						end
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK , "*Stream URL Not Valid!")
					end
				end)
			end
		end
	end
	//delete the station
	function DeleteStation(info)
		local DSFrame = vgui.Create( "DFrame" )
		DSFrame:SetSize( 340, 120 )
		DSFrame:SetTitle( "Delete Station" )
		DSFrame:SetVisible( true )
		DSFrame:SetDraggable( true )
		DSFrame:ShowCloseButton( true )
		DSFrame:MakePopup()
		DSFrame:Center()
		DSFrame:MakePopup()
		
		local DSPanel = vgui.Create( "DPanel", DSFrame )
		DSPanel:SetPos( 4, 24 )
		DSPanel:SetSize( DSFrame:GetWide() - 8, DSFrame:GetTall() - 28 )
		DSPanel.Paint = function()
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 0, DSPanel:GetWide(), DSPanel:GetTall() )
		end
		
		local Label1 = vgui.Create( "DLabel", DSPanel )
		Label1:SetPos( 2, 0 )
		Label1:SetFont("WinSmall")
		Label1:SetText( "Are you sure you want to delete this station?")
		Label1:SizeToContents()
		
		local Label2 = vgui.Create( "DLabel", DSPanel )
		Label2:SetPos( 2, 20 )
		Label2:SetFont("WinSmall")
		Label2:SetText(info)
		Label2:SizeToContents()
	
		local YesButton = vgui.Create( "DButton", DSPanel )
		YesButton:SetText( "Yes" )
		YesButton:SetPos( 73, 50 )
		YesButton:SetSize( 60, 30 )
		YesButton.DoClick = function ()
			net.Start( "DeleteStation" )
				net.WriteString(info)
			net.SendToServer()
			LocalPlayer():PrintMessage( HUD_PRINTTALK , "Deleted Station, Re-open Menu to see removed Station!")
			DSFrame:Close()
		end
		
		local NoButton = vgui.Create( "DButton", DSPanel )
		NoButton:SetText( "No" )
		NoButton:SetPos( 193, 50 )
		NoButton:SetSize( 60, 30 )
		NoButton.DoClick = function ()
			DSFrame:Close()
		end

	end

//draw the menu when told
	net.Receive( "RMenu", function( len, pl )
		radio = net.ReadEntity()
		stations = net.ReadTable()
		RadioMenu(radio)
	end )

//get all station to play
	net.Receive( "UpdateStation", function( len, pl )
		station = net.ReadString()
		radio = net.ReadEntity()
		changeStation(station, radio)
	end )

//send to the server the new radio station
	function StationChange(station, radio)
		net.Start( "StationChange" )
			net.WriteString(station)
			net.WriteEntity(radio)
		net.SendToServer()
	end