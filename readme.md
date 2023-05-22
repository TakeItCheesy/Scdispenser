**Author:** TakeItCheesy<br>
**Version:** 1.2.3<br>
**Abbreviations:** scd<br>

# SC-Dispenser
SC-Dispenser is a simple addon for making skillchains using immanence on a scholar and magic bursting off of those if enabled. **Note:** Timings may very well be off if you don't have capped (80%) fast cast on your scholar.

## Commands:

 ### //scd sc [liquefusion|fourstep|sixstep]	 
 
 * Starts making a skillchain of the selected element.
	* 'liquefusion' makes a 3 step fire skillchain.
	* 'fourstep' makes a 4-step alternating stone/aero (for sortie objectives)
	* 'sixstep' makes a 6-step alternating stone/aero (useful in vagary)
 * In-game macro example:
	* `/con scd sc` or `/con scd sc liquefusion`	
											
 ### //scd element ['Element'|back]			 
 
 * 'Element' can be any of 'Stone', 'Water', 'Aero', 'Blizzard', 'Thunder', 'Light' or 'Dark' and is optional (capitalization matters). If no Element is provided it will cycle through them instead.
 * 'back' will cycle backwards in the list of elements instead of forwards.
 * In-game macro example:
	* `/con scd element`, `/con scd element back` or `/con scd element Aero`
											
 ### //scd burst [on|off|helix]  	 
 
 * Sets Burst mode to on, off or helix or cycles through them if no argument is given. If 'on' or 'helix' it will automatically burst the correct tier 5 spell or helix 2 at the appropriate time in the skillchain. For light/dark it'll only ever do helix.
 * In-game macro example:
	* `/con scd burst` or `/con scd burst helix`
 
 ### //scd ebullience 					 
 
 * Toggles ebullience usage for the bursting on/off. I recommend leaving this off, but it's there in case you need it. Note that if tabula rasa is active it will always use ebullience in any case.
 * In-game macro example:
	* `/con scd ebullience` 
 
 ### //scd tier [1|2]		 
 
 * Changes skillchain tier, cycles if not specified.
 * In-game macro example:
	* `/con scd tier` or `/con scd tier 1`
 
 ### //scd cancel
 
 * Tries to stop current skillchain (some scheduled events may go through still and does not work for the four/six-step options)
 * In-game macro example:
	* `/con scd cancel`

## Changes:

### v1.2.3
 * HUD is now hidden on logout
 * Misc. code cleanup
 * Timer for active skillchains

### v1.2.2
 * Now checks stratagem + spell recasts before starting.
 * Minor tweaks to timings.
 * Ebullience now also activates for helix when turned on.
 * Elements now line up with easynuke if you want to cycle both at the same time, and there's now an option for cycling backwards.

### v1.2.1
 * Settings file added for setting font and/or position for the HUD. 
 * Added an option for tier1 skillchains, still defaults to tier2.
 
### v1.2.0
 * Rewrite of event scheduling for skillchains.
 * Added option for cancelling current skillchain.
 
### v1.1.1
 * Added fourstep for sortie objectives.

### v1.1.0
 * Sixstep option added for skillchains.
 
### 1.0.3
 * Minor HUD tweaks.

        