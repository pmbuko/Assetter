--
--  AppDelegate.applescript
--  Assetter
--
--  Created by Peter Bukowinski on 6/6/13.
--  
--  This software is released under the terms of the MIT license.
--  Copyright (C) 2013 by Peter Bukowinski
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.


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
    property isIdle : true
    property doneLoading : false
    property pwGood : false
    
--- HANDLERS ---

    -- General error handler, writes to Console.
    on errorOut_(theError)
        log "Error: " & theError
    end errorOut_
    
    -- Get asset tag info or set it if not present.
    on assetTag_(sender)
        try 
            set my myAT to do shell script "/usr/sbin/nvram asset-tag | /usr/bin/awk '{print $2}'"
            if myAT is "" then
                set my myAT to text returned of (display dialog "Asset tag is not set. Please enter it now:" default answer "" buttons {"Cancel", "OK"} default button 2 )
                try -- This try block traps for incorrect passwords
                    set thePassword to text returned of (display dialog "Enter your password to write asset tag to NVRAM:" default answer "" with hidden answer)
                    do shell script "/bin/echo '" & thePassword & "' | /usr/bin/sudo -S /usr/sbin/nvram asset-tag='" & myAT & "'"
                    set my pwGood to true
                    do shell script "/usr/bin/sudo -k" -- Expire sudo session immediately upon success
                on error -- This block runs if first password attempt is incorrect
                    repeat until pwGood is true
                        try
                            set thePassword to text returned of (display dialog "Incorrect password. Please try again:" default answer "" with icon 2 with hidden answer)
                            do shell script "/bin/echo '" & thePassword & "' | /usr/bin/sudo -S /usr/sbin/nvram asset-tag='" & myAT & "'"
                            set my pwGood to true
                        end try
                    end repeat
                end try
            end if
        on error theError
            errorOut_(theError)
        end try
    end assetTag_
    
    -- Gather system information and place values into properties that are bound to text fields in the GUI.
    on getSysInfo_(sender)
        try
            set my myHostname to (do shell script "/usr/sbin/scutil --get ComputerName")
            set my myModel to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk -F': ' '/Model Name/{print $2}'")
            set my mySN to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk -F': ' '/Serial Number \\(system\\)/{print $2}'")
            
            set my myMem to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk -F': ' '/Memory/{print $2}'")
            set my myHDs to (do shell script "/usr/sbin/diskutil list | /usr/bin/awk '/0:/{sub(/\\*/,\"\");printf \"%9s %s - %s\\n\", $3, $4, $5}'")
            set my myHDsizes to (do shell script "/usr/sbin/diskutil list | /usr/bin/awk '/0:/{sub(/\\*/,\"\");printf \"%s %s\\n\", $3, $4}'")
            set my myHDdevs to (do shell script "/usr/sbin/diskutil list | /usr/bin/awk '/0:/{sub(/\\*/,\"\");print $5}'")
            
            set my myNics to (do shell script "/usr/sbin/networksetup -listnetworkserviceorder | /usr/bin/awk '/: en/{printf \"%s \", substr($NF, 1, 3)}'")
            set my myNic1 to first word of myNics
            set my myNic2 to second word of myNics
            set my myNic1ip to (do shell script "/sbin/ifconfig " & myNic1 & " inet | /usr/bin/awk '/inet /{print $2}'")
            if myNic1ip = "" then set my myNic1ip to "-- no ip --"
            set my myNic2ip to (do shell script "/sbin/ifconfig " & myNic2 & " inet | /usr/bin/awk '/inet /{print $2}'")
            if myNic2ip = "" then set my myNic2ip to "-- no ip --"
            set my myNic1mac to (do shell script "/sbin/ifconfig " & myNic1 & " ether | /usr/bin/awk '/ether /{print $2}'")
            set my myNic2mac to (do shell script "/sbin/ifconfig " & myNic2 & " ether | /usr/bin/awk '/ether /{print $2}'")
        on error theError
            errorOut_(theError)
        end try
    end getSysInfo_

    -- Export data to text file on the desktop when export button is pushed, overwriting existing file
    on exportButton_(sender)
        set my outputFile to ((path to desktop as string) & myHostname & "_ASSETS.txt")
        set my theContent to ¬
"Hostname : " & myHostname & "
Model : " & myModel & "
Serial Number : " & mySN & "
Asset Tag : " & myAT & "
Memory : " & myMem & "
" & myNic1 & " IP : " & myNic1ip & "
" & myNic1 & " MAC : " & myNic1mac & "
" & myNic2 & " IP : " & myNic2ip & "
" & myNic2 & " MAC : " & myNic2mac & "
Drives :
" & myHDs
        
        try -- Write data out to file
            set fileRef to (open for access current application's file outputFile with write permission)
            set eof fileRef to 0
            write theContent to fileRef as text
            close access fileRef
        on error theError
            try -- Close out the file reference in case of error
                close access fileRef
            end try
            errorOut_(theError)
        end try
    end exportButton_
    
    -- This block is run when the app is launched
	on applicationWillFinishLaunching_(aNotification)
        set my isIdle to false
        assetTag_(me)
        getSysInfo_(me)
        set my isIdle to true
        set my doneLoading to true
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