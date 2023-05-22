--[[
Copyright © 2022, TakeItCheesy
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of EasyNuke nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Nyarlko, or it's members, BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Skillchain Dispenser'
_addon.author = 'TakeItCheesy'
_addon.version = '1.2.3'
_addon.command = 'scd'
_addon.commands = {'sc', 'element', 'burst', 'ebullience', 'tier', 'cancel', 'help'}

require('tables')
texts = require('texts')
res = require('resources')
config = require('config')

function init()
	Elements= T{'Fire', 'Aero', 'Thunder', 'Light', 'Blizzard', 'Water', 'Stone', 'Dark'}
	
	Ele_index = 1
	Skillchain = {}
		Skillchain.Fire = {}
			Skillchain.Fire['1'] = {skillchain='Liquefaction', opener='Thunder', closer='Pyrohelix', mbhelix='Pyrohelix II', delay=6}	
			Skillchain.Fire['2'] = {skillchain='Fusion', opener='Fire',	closer='Ionohelix',	mbhelix='Pyrohelix II', delay=6}	
		Skillchain.Water = {}	
			Skillchain.Water['1'] = {skillchain='Reverberation', opener='Stone', closer='Hydrohelix', mbhelix='Hydrohelix II', delay=6}
			Skillchain.Water['2'] = {skillchain='Distortion', opener='Luminohelix', closer='Geohelix', mbhelix='Hydrohelix II', delay=7}
		Skillchain.Thunder = {}
			Skillchain.Thunder['1'] = {skillchain='Impaction', opener='Blizzard', closer='Ionohelix', mbhelix='Ionohelix II', delay=6}
			Skillchain.Thunder['2'] = {skillchain='Fragmentation', opener='Blizzard', closer='Hydrohelix', mbhelix='Ionohelix II', delay=6}
		Skillchain.Stone = {}
			Skillchain.Stone['1'] = {skillchain='Scission', opener='Fire', closer='Geohelix', mbhelix='Geohelix II', delay=6}
			Skillchain.Stone['2'] = {skillchain='Gravitation', opener='Aero', closer='Noctohelix', mbhelix='Geohelix II', delay=6}
		Skillchain.Aero = {}
			Skillchain.Aero['1'] = {skillchain='Detonation', opener='Thunder', closer='Anemohelix', mbhelix='Anemohelix II', delay=6}
			Skillchain.Aero['2'] = {skillchain='Fragmentation', opener='Blizzard', closer='Hydrohelix', mbhelix='Anemohelix II', delay=6}
		Skillchain.Blizzard = {}
			Skillchain.Blizzard['1'] = {skillchain='Induration', opener='Water', closer='Cryohelix', mbhelix='Cryohelix II', delay=6}
			Skillchain.Blizzard['2'] = {skillchain='Distortion', opener='Luminohelix', closer='Geohelix', mbhelix='Cryohelix II', delay=7}
		Skillchain.Light = {}
			Skillchain.Light['1'] = {skillchain='Transfixion', opener='Noctohelix', closer='Luminohelix', mbhelix='Luminohelix II', delay=7}
			Skillchain.Light['2'] = {skillchain='Fusion', opener='Fire', closer='Ionohelix',	mbhelix='Luminohelix II', delay =6}
		Skillchain.Dark = {}
			Skillchain.Dark['1'] = {skillchain='Compression', opener='Blizzard', closer='Noctohelix', mbhelix='Noctohelix II', delay=6}
			Skillchain.Dark['2'] = {skillchain='Gravitation', opener='Aero', closer='Noctohelix', mbhelix='Noctohelix II', delay=6}
	
	Tier = '2'
					
	Burst = T{'off', 'on', 'helix'}
	Burst_index = 1
	
	Ebullience = 'off'

	BurstMode = Burst[Burst_index]
	
	MsgColor  = 123
	
	SCactive = false
	StepOne = false
	StepTwo = false
	StepThree = false
	StepBurst = false
			
	Defaults = T{	
		pos = { x=0, y=0 },
		padding = 5,
		text = { size=12, font='Impact' }
		colors = {
			Fire = {204, 0, 0} 
			Water = {0, 102, 204}
			Aero = {51, 102, 0}
			Light = {255, 255, 255}
			Stone = {139, 139, 19}
			Blizzard = {0, 204, 204}
			Thunder = {102, 0, 204}
			Dark = {0, 0, 0}
		}
	}
	
	Settings = config.load('data\\settings.xml', Defaults)
	
	HUD = texts.new()

	HUD:bg_alpha(150)	
	HUD:bg_color(40, 40, 55)
	HUD:stroke_width(2)
	HUD:stroke_color(255,255,255)
	HUD:stroke_alpha(0)
	HUD:font(Settings.text.font)
	HUD:size(Settings.text.size)
	HUD:pos(Settings.pos.x, Settings.pos.y)
	HUD:pad(Settings.padding)

	update_hud()
end

function make_boom(arg)
	if SCactive then
		windower.add_to_chat(MsgColor, 'Skillchain already in progress, cancel or wait for it to finish.')
	else
		--checks for dark arts/addendum black
		if not (buff_check(359) or buff_check(402)) then
			windower.add_to_chat(MsgColor, 'Dark Arts not active, skillchain aborted.')
			return
			--disables burst mode if addendum black is not active, still makes skillchain
		elseif BurstMode == 'on' and not buff_check(402) then
			windower.add_to_chat(MsgColor, 'Addendum: Black not active. Turning Burst mode off.')
			BurstMode = 'off'
			Burst_index = 1
			update_hud()
		end
		
		--get current target
		local index = windower.ffxi.get_player().target_index
		if index ~= nil then
			Targeted = windower.ffxi.get_mob_by_index(index)
		else
			Targeted = nil
		end
		
		--checks if we have a target and that it's not a player
		if not Targeted or not Targeted.is_npc or Targeted.name == 'Luopan' then
			windower.add_to_chat(MsgColor, 'Invalid target, skillchain aborted.')
			return
		end
		
		--simpler scheduled skillchains for the 4/6step options
		if arg[1] ~= nil then 
			if arg[1] == 'fourstep' then
				fourstep()
				return
			elseif arg[1] == 'sixstep' then
				sixstep()
				return
			end			
		end	
		
		--variables for current selected skillchain element
		Liquefusion = false
		SCtarget = Targeted.id
		SCname = Skillchain[CurrentElement][Tier].skillchain
		SCelement = CurrentElement
		SCopener = Skillchain[CurrentElement][Tier].opener
		SCcloser = Skillchain[CurrentElement][Tier].closer
		SChelix = Skillchain[CurrentElement][Tier].mbhelix
		SCdelay = Skillchain[CurrentElement][Tier].delay
		MBdelay = SCdelay + 6
		if CurrentElement == 'Light' or CurrentElement == 'Dark' then
			SCnuke = SChelix
		else
			SCnuke = CurrentElement..' V'
		end
		
		--different variables for fire 3step
		if arg[1] == 'liquefusion' then
			SCname = translate('Liquefaction')..' > '..translate('Fusion')
			SCelement = 'Fire'
			SCopener = 'Stone'
			SCcloser = 'Fire'
			SChelix = 'Pyrohelix II'
			SCnuke = 'Fire V'
			SCdelay = 6
			MBdelay = 20
			Liquefusion = true
		end
		
		--check stratagem recast		
		local recharge = 48
		if windower.ffxi.get_player().job_points.sch.jp_spent >= 550 then
			recharge = 33
		end
		local recast = windower.ffxi.get_ability_recasts()[231] or 0	
		--windower.add_to_chat(MsgColor, recast)
		if Liquefusion then
			if recast > 2 * recharge + 13 then
				windower.add_to_chat(MsgColor, 'Not enough stratagems, skillchain aborted.')
				return
			end
		else
			if recast > 3 * recharge + 5 then
				windower.add_to_chat(MsgColor, 'Not enough stratagems, skillchain aborted.')
				return
			end
		end		
		
		--check spell recasts
		if check_recast(SCopener) > 1 then
			windower.add_to_chat(MsgColor, SCopener..' not ready, skillchain aborted.')
			return
		end
		if check_recast(SCcloser) > 5 then
			windower.add_to_chat(MsgColor, SCcloser..' not ready, skillchain aborted.')
			return
		end
		if Liquefusion then
			if check_recast('Ionohelix') > 13 then
				windower.add_to_chat(MsgColor, 'Ionohelix not ready, skillchain aborted.')
				return
			end
		end
		
		--schedules booms
		StepOne = true
		SCactive = true
		coroutine.schedule(step_one, 0.5)
		coroutine.schedule(step_two, SCdelay)
		if Liquefusion then
			coroutine.schedule(step_three, 14) 
		end
		coroutine.schedule(step_burst, MBdelay)
		windower.send_command('timer c "SC IN PROGRESS" '..MBdelay..' up spells/00247.png')
	end
end

function step_one()
	if not StepOne then return end
	StepOne = false
	StepTwo = true
	windower.chat.input('/p Opening SC: '..translate(SCname)..' on '..Targeted.name..' - MB: '..translate(SCelement)..'.')
	windower.chat.input('/ja Immanence <me>')
	windower.chat.input:schedule(1.5, '/ma '..SCopener..' '..SCtarget)
end

function step_two()
	if not StepTwo then return end
	if Liquefusion then 
		SCname = 'Liquefaction' 
		StepThree = true
	else
		StepBurst = true
	end
	StepTwo = false
	windower.chat.input('/ja Immanence <me>')
	windower.chat.input:schedule(1.5 , '/p Closing SC: '..translate(SCname)..' - MB: '..translate(SCelement)..' now!')
	windower.chat.input:schedule(1.5 , '/ma '..SCcloser..' '..SCtarget)
end

function step_three()
	if not StepThree then return end
	StepBurst = true
	StepThree = false
	windower.chat.input('/ja Immanence <me>' )
	windower.chat.input:schedule(1.5, '/p Closing SC: '..translate('Fusion')..' - MB: '..translate('Fire')..' now!')
	windower.chat.input:schedule(1.5, '/ma Ionohelix '..SCtarget)
end

function step_burst()
	if not StepBurst then return end
	local wait = 0
	if BurstMode ~= 'off' and (Ebullience == 'on' or buff_check(377)) then
		windower.chat.input('/ja Ebullience <me>')
		wait = 1.2
	end
	if BurstMode == 'on' then
		windower.chat.input:schedule(wait,'/ma '..SCnuke..' '..SCtarget)
	elseif BurstMode == 'helix' then
		windower.chat.input:schedule(wait,'/ma '..SChelix..' '..SCtarget)
	end	
	StepOne = false
	StepTwo = false
	StepThree = false
	StepBurst = false
	coroutine.schedule(function() 
		SCactive = false 
		windower.add_to_chat(MsgColor, 'Ready to start next skillchain.') 
	end, 5)	
end

function fourstep()
	windower.add_to_chat(MsgColor, 'Starting 4-step.')
	local SCtarget = Targeted.id	
	local delay = 0
	windower.chat.input:schedule(delay, '/ma Stone '..SCtarget)
	windower.chat.input:schedule(delay + 4, '/ja Immanence <me>') 
	windower.chat.input:schedule(delay + 5, '/ma Aero '..SCtarget)
	windower.chat.input:schedule(delay + 9, '/ja Immanence <me>')
	windower.chat.input:schedule(delay + 10, '/ma Stone '..SCtarget)
	windower.chat.input:schedule(delay + 14, '/ja Immanence <me>')
	windower.chat.input:schedule(delay + 15, '/ma Aero '..SCtarget)
end

function sixstep()
	windower.add_to_chat(MsgColor, 'Starting 6-step.')
	local SCtarget = Targeted.id
	local delay = 0	
	--if immanence is already active assumes you waited long enough and go
	if buff_check(470) then
		delay = 0
	--if tabula rasa is active just start
	elseif buff_check(377) then
		windower.chat.input('/ja Immanence <me>')
		delay = 1
	--no immanence/tabula up, activate immenance and wait for strat to recharge a bit before going
	else 
		windower.chat.input('/ja Immanence <me>')
		delay = 15
		windower.add_to_chat(MsgColor, 'Waiting 15 seconds for stratagems.')
	end	
	windower.chat.input:schedule(delay, '/ma Stone '..SCtarget)
	windower.chat.input:schedule(delay + 4, '/ja Immanence <me>') 
	windower.chat.input:schedule(delay + 5, '/ma Aero '..SCtarget)
	windower.chat.input:schedule(delay + 9, '/ja Immanence <me>')
	windower.chat.input:schedule(delay + 10, '/ma Stone '..SCtarget)
	windower.chat.input:schedule(delay + 14, '/ja Immanence <me>')
	windower.chat.input:schedule(delay + 15, '/ma Aero '..SCtarget)
	windower.chat.input:schedule(delay + 19, '/ja Immanence <me>')
	windower.chat.input:schedule(delay + 20, '/ma Stone '..SCtarget)
	windower.chat.input:schedule(delay + 24, '/ja Immanence <me>')
	windower.chat.input:schedule(delay + 25, '/ma Aero '..SCtarget)
end

function check_recast(spell)
	local SpellID = {
		['Fire'] = 144,
		['Blizzard'] = 149,
		['Aero'] = 154,
		['Stone'] = 159,
		['Thunder'] = 164,
		['Geohelix'] = 278,
		['Hydrohelix'] = 279, 
		['Anemohelix'] = 280,
		['Pyrohelix'] = 281,
		['Cryohelix'] = 282,
		['Ionohelix'] = 283,
		['Noctohelix'] = 284,
		['Luminohelix'] = 285,
	}
	local recasts = windower.ffxi.get_spell_recasts() 
	return recasts[SpellID[spell]] / 60 or 0
end

function buff_check(check)	
	Buffs = T(windower.ffxi.get_player().buffs)
	if Buffs:contains(check) then
		return true
	end
	--359 = dark arts
	--402 = add: black
	--470 = immanence
	--365 = ebullience		
	--377 = tabula rasa
end

function save_pos() 
	Settings.pos.x = HUD:pos_x()
	Settings.pos.y = HUD:pos_y()
	Settings:save('all')	
end

function hide ()
	HUD:hide()
end

function update_hud()
	if windower.ffxi.get_player()['main_job_id'] ~= 20 then 
		hide()
		return 
	end
	
	CurrentElement = Elements[Ele_index]
	Color = Settings.colors[CurrentElement]

	HUD:text('Element: '..CurrentElement..'\n'..'Tier: '..tostring(Tier)..'\n'..'Burst: '..BurstMode..'\n'..'Ebullience: '..tostring(Ebullience))
	HUD:color(Color[1], Color[2], Color[3])
	
	if CurrentElement == 'Dark' then
		HUD:stroke_alpha(100)
	else
		HUD:stroke_alpha(0)
	end
	
	save_pos()
	HUD:show()
end

function help()
    print('Commands: ')
    print(' - help:  displays this help text')
    print(' - sc [liquefusion][fourstep][sixstep]: 	starts making selected skillchain')
    print(' - element [Element][back]: 	cycles through the different elements')
    print(' - burst [on][off][helix]: 	cycles bursting modes')
    print(' - ebullience: 	toggles ebullience usage')
    print(' - tier [1][2]: 	cycles skillchain tier')
    print(' - cancel: 	attempts to cancel current skillchain')
end

handle_commands = function(...)
	local args = T{...}		
    if args ~= nil then
        local cmd = table.remove(args,1):lower()
		if cmd == 'sc' then
			make_boom(args)
			if args[1] ~= nil and not S{'liquefusion', 'fourstep', 'sixstep'}:contains(args[1]) and not SCactive then
				windower.add_to_chat(MsgColor, "Invalid argument for skillchain, starting skillchain of selected element.")
			end
		elseif cmd == 'element' then
			if args[1] ~= nil and Elements:contains(args[1]) then
				Ele_index = table.find(Elements, args[1])
				update_hud()
			elseif args[1] and args[1] == 'back' then
				Ele_index = Ele_index - 1
				if Ele_index < 1 then
					Ele_index = #Elements
				end			
				update_hud()				
			elseif args[1] ~= nil then
				windower.add_to_chat(MsgColor, "Invalid element, valid options are:  'Fire', 'Stone', 'Water', 'Aero', 'Blizzard', 'Thunder', 'Light' or 'Dark'.")
			else
				Ele_index = Ele_index % 8 + 1 
				update_hud()
			end
		elseif cmd == 'burst' then
			if args[1] ~= nil and Burst:contains(args[1]) then
				BurstMode = args[1]
				Burst_index = table.find(Burst, args[1])
				update_hud()
			elseif args[1] ~= nil then
				windower.add_to_chat(MsgColor, "Invalid option for Burst, valid options are:  'on', 'off' or 'helix'.")
			else
				Burst_index = Burst_index % 3 + 1
				BurstMode = Burst[Burst_index]
				update_hud()
			end
		elseif cmd == 'ebullience' then
			if Ebullience == 'off' then
				Ebullience = 'on'
			else
				Ebullience = 'off'
			end
			update_hud()
		elseif cmd == 'tier' then
			if args[1] ~= nil and S{'1', '2'}:contains(args[1]) then
				Tier = args[1]
			else
				if Tier == '1' then
					Tier = '2'
				else
					Tier = '1'
				end
			end
			update_hud()
		elseif cmd == 'help' then
			help()
		elseif cmd == 'cancel' then
			StepOne = false
			StepTwo = false
			StepThree = false
			StepBurst = false
			SCactive = false	
			windower.add_to_chat(MsgColor, 'Cancelling current skillchain, please give it a second before starting another.')
			windower.send_command('timers d "SC IN PROGRESS"')
		end
	end
end

function translate(term)
	Translates = {}
	Translates.Fusion = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC1, 0xFD )
	Translates.Distortion = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC0, 0xFD )
	Translates.Gravitation = string.char(0xFD, 0x02, 0x02, 0x1E, 0xBE, 0xFD )
	Translates.Fragmentation = string.char(0xFD, 0x02, 0x02, 0x1E, 0xBF, 0xFD )
	Translates.Reverberation = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC5, 0xFD )
	Translates.Liquefaction = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC3, 0xFD )
	Translates.Compression = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC2, 0xFD )
	Translates.Transfixion = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC6, 0xFD )
	Translates.Induration = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC4, 0xFD )
	Translates.Detonation = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC8, 0xFD )
	Translates.Impaction = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC9, 0xFD )
	Translates.Scission = string.char(0xFD, 0x02, 0x02, 0x1E, 0xC7, 0xFD )	
	Translates.Fire = string.char(0xFD, 0x02, 0x02, 0x1B, 0x52, 0xFD)
	Translates.Blizzard = string.char(0xFD, 0x02, 0x02, 0x1B, 0x53, 0xFD)
	Translates.Water = string.char(0xFD, 0x02, 0x02, 0x1B, 0x4D, 0xFD)
	Translates.Aero = string.char(0xFD, 0x02, 0x02, 0x1B, 0x54, 0xFD)
	Translates.Thunder = string.char(0xFD, 0x02, 0x02, 0x1B, 0x56, 0xFD)
	Translates.Stone = string.char(0xFD, 0x02, 0x02, 0x1B, 0x58, 0xFD)
	Translates.Light = string.char(0xFD, 0x02, 0x02, 0x1E, 0x4B, 0xFD)
	local translate = Translates[term] or term
	return translate
end


windower.register_event('addon command', handle_commands)

windower.register_event('load', init)

windower.register_event('unload', save_pos)

windower.register_event('logout', hide)

windower.register_event('job change', update_hud)
 
