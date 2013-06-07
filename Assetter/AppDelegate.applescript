--
--  AppDelegate.applescript
--  Assetter
--
--  Created by Peter Bukowinski on 6/6/13.
--  Copyright (c) 2013 Peter Bukowinski. All rights reserved.
--

script AppDelegate
--- CLASSES ---
	property parent : class "NSObject"
    
--- OBJECTS ---
    property myHostname : missing value
    property myModel : missing value
    property mySN : missing value
    property myAT : missing value
    property myMem : missing value
    property myHDsizes : missing value
    property myHDdevs : missing value
    property myNics : missing value
    property myNic1 : missing value
    property myNic2 : missing value
    property myNic1ip : missing value
    property myNic1mac : missing value
    property myNic2ip : missing value
    property myNic2mac : missing value
    
--- HANDLERS ---

    -- General error handler, writes to Console.
    on errorOut_(theError)
        log "Script Error: " & theError
    end errorOut_
    
    -- This block is run when the app is launched
	on applicationWillFinishLaunching_(aNotification)
        try -- Gather system information and place values into our properties
            set my myHostname to (do shell script "scutil --get ComputerName")
            set my myModel to (do shell script "system_profiler SPHardwareDataType | awk -F': ' '/Model Name/{print $2}'")
            set my mySN to (do shell script "system_profiler SPHardwareDataType | awk -F': ' '/Serial Number/{print $2}'")
            set my myAT to (do shell script "if [ -f '/Library/Management/AssetTag' ]; then cat /Library/Management/AssetTag; else echo '--not found--'; fi")
        
            set my myMem to (do shell script "system_profiler SPHardwareDataType | awk -F': ' '/Memory/{print $2}'")
            set my myHDsizes to (do shell script "diskutil list | awk '/0:/{sub(/\\*/,\"\");print $3, $4}'")
            set my myHDdevs to (do shell script "diskutil list | awk '/0:/{sub(/\\*/,\"\");print $5}'")
            
            set my myNics to (do shell script "networksetup -listnetworkserviceorder | awk '/: en/{printf \"%s \", substr($NF, 1, 3)}'")
            set my myNic1 to first word of myNics
            set my myNic2 to second word of myNics
            set my myNic1ip to (do shell script "ifconfig " & myNic1 & " inet | awk '/inet /{print $2}'")
            if myNic1ip = "" then set my myNic1ip to "-- no ip --"
            set my myNic2ip to (do shell script "ifconfig " & myNic2 & " inet | awk '/inet /{print $2}'")
            if myNic2ip = "" then set my myNic1ip to "-- no ip --"
            set my myNic1mac to (do shell script "ifconfig " & myNic1 & " ether | awk '/ether /{print $2}'")
            set my myNic2mac to (do shell script "ifconfig " & myNic2 & " ether | awk '/ether /{print $2}'")
        on error theError
            errorOut_(theError)
        end try
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    -- Quit the app when the window is closed.
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
	
end script