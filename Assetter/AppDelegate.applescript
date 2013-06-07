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
    property myModel :    missing value
    property mySN :       missing value
    property myAT :       missing value
    property myMem :      missing value
    property myHDs :      missing value
    property myHDsizes :  missing value
    property myHDdevs :   missing value
    property myNics :     missing value
    property myNic1 :     missing value
    property myNic2 :     missing value
    property myNic1ip :   missing value
    property myNic1mac :  missing value
    property myNic2ip :   missing value
    property myNic2mac :  missing value
    
--- OTHER PROPERTIES ---
    property outputFile : ""
    property theContent : ""
    
--- HANDLERS ---

    -- General error handler, writes to Console.
    on errorOut_(theError)
        log "Script Error: " & theError
    end errorOut_
    
    -- Get asset tag info or set it if it is not present.
    on assetTag_(sender)
        try 
            set my myAT to do shell script "nvram asset-tag | awk '{print $2}'"
            if myAT is "" then
                set myAT to text returned of (display dialog "No asset tag found. Please enter my asset tag:" default answer "")
                set thePassword to text returned of (display dialog "Enter your admin password to save asset tag to nvram:" default answer "" with hidden answer)
                do shell script "/bin/echo '" & thePassword & "' | sudo -S nvram asset-tag='" & myAT & "'"
            end if
        on error theError
            errorOut_(theError)
        end try
    end assetTag_
    
    -- Gather system information and place values into properties that are bound to text fields in the GUI.
    on getSysInfo_(sender)
        try
            set my myHostname to (do shell script "scutil --get ComputerName")
            set my myModel to (do shell script "system_profiler SPHardwareDataType | awk -F': ' '/Model Name/{print $2}'")
            set my mySN to (do shell script "system_profiler SPHardwareDataType | awk -F': ' '/Serial Number/{print $2}'")
            
            set my myMem to (do shell script "system_profiler SPHardwareDataType | awk -F': ' '/Memory/{print $2}'")
            set my myHDs to (do shell script "diskutil list | awk '/0:/{sub(/\\*/,\"\");print $3, $4, $5}'")
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
    end getSysInfo_

    -- Export data to text file on the desktop when export button is pushed, overwriting existing file
    on exportButton_(sender)
        set my outputFile to ((path to desktop as string) & myHostname & "_ASSETS.txt")
        set posixFile to POSIX path of outputFile
        set my theContent to "==============
Hostname:      " & myHostname & "
Model:         " & myModel & "
Serial Number: " & mySN & "
Asset Tag:     " & myAT & "
Memory:        " & myMem & "
Nic 1 IP:      " & myNic1ip & "
Nic 1 MAC:     " & myNic1mac & "
Nic 2 IP:      " & myNic2ip & "
Nic 2 MAC:     " & myNic2mac & "
Hard Drive(s):
" & myHDs
        
        try
            set fileRef to (open for access current application's file outputFile with write permission)
            set eof fileRef to 0
            write theContent to fileRef as text
            close access fileRef
        on error theError
            try
                close access fileRef
            end try
            errorOut_(theError)
        end try
    end exportButton_
        
    -- This block is run when the app is launched
	on applicationWillFinishLaunching_(aNotification)
        assetTag_(me)
        getSysInfo_(me)
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