---------------------------------------------
--           ADF gauge                     --
-- Modification of Russ Green's original   --
-- ADF dip model and code:  26.05.20       --
--                                         --
-- Adapted for FlywithLua Ed Syson 30.05.20--
-- Thanks to PPLIR for realworld tuning of --
-- ADF model                               --
--                                         --
-- This co-opts ADF2 to provide bearings   --
-- for ADF1 and will be unreliable with    --
-- dual ADF aircraft if ADF2 is needed.      --
-- 
-- Jitter can be applied to the ADF to     --
-- better simulate the variablity in       --
-- the instrument. If not required set     --
-- MAX_Jitter to zero.                     --
--                                         --
-- Uncomment Do_Every_Draw to see data     --
---------------------------------------------

---------------------------------------------
--   Properties                            --
---------------------------------------------
 Jitter_On = true  --Set true for jitter, false for steady
 MAX_Jitter = 1.5  --Degrees +/- of ADF variability (rec. 1.5)
 Tgt_Jitter = 0    --Random jitter on the ADF bearing - pointer moves to this over time
 ADF_Jitter = 0    --Actual amount of jitter applied to pointer this frame
 Jitter_speed = 60 --Number of frames to move from current position to target jitter position (rec 30)
---------------------------------------------
--   Functions                             --
---------------------------------------------


function new_adfdipped()
    --this method approximates ADF dip towards the low wing in a turn
    Status_Line = ""
    local Max_Dip = 10    --Maximum amount to dip the ADF pointer in degrees (7-10)
    local Full_BankAngle = 10   --Bank angle beyond which maximum dip can occur (10)
    local Mod_Brg = 0  --bearing expressed as 0-180 degrees (always positive)
    local Sgn_Brg = 1  --sign of bearing -ve to port, positive to starboard
    local Applied_Dip = 0  --Actual Dip being applied this frame
    local Capped_Bank_Angle = 0  


    DataRef("heading","sim/cockpit/radios/adf1_cardinal_dir","readonly")
    DataRef("ADF1_Brg","sim/cockpit/radios/adf1_dir_degt", "writable")
    DataRef("rollang", "sim/cockpit2/gauges/indicators/roll_electric_deg_pilot", "readonly")

    DataRef("ADF1_Freq", "sim/cockpit2/radios/actuators/adf1_frequency_hz","writable")
    DataRef("ADF2_Freq", "sim/cockpit2/radios/actuators/adf2_frequency_hz","writable")
    DataRef("ADF2_Brg","sim/cockpit2/radios/indicators/adf2_relative_bearing_deg", "readonly")
    DataRef("ident","sim/cockpit2/radios/indicators/adf1_nav_id","readonly")
    
    ADF2_Freq = ADF1_Freq  --Set ADF2 to the same frequency as ADF 1
    relbrg = ADF2_Brg      -- Take the 'clean' reference bearing from ADF2, to which dip will be added
   
    if ADF2_Brg < 0 then 
        Sgn_Brg = -1
        Mod_Brg = -1 * ADF2_Brg   
    else
        Sgn_Brg = 1
        Mod_Brg = ADF2_Brg
    end
        
    --Calculate amount of dip assuming max bank angle
    if Mod_Brg >= 120 then 
        Applied_Dip = -1 * Max_Dip
        Status_Line = Status_Line .. " MAX+DIP "
    elseif Mod_Brg > 60 then
            Applied_Dip = Max_Dip * ((90-Mod_Brg)/30)
            Status_Line = Status_Line .. " TAPER  "
    elseif Mod_Brg >= 0 then
        Applied_Dip = Max_Dip
        Status_Line = Status_Line .. " MAX-DIP "
    end
    ---Now moderate the amount of dip for shallow bank angles and apply sign
    Capped_Bank_Angle = rollang
    if Capped_Bank_Angle > Full_BankAngle then Capped_Bank_Angle = Full_BankAngle end
    if Capped_Bank_Angle < (-1*Full_BankAngle) then Capped_Bank_Angle = -1 * Full_BankAngle end
    Applied_Dip = Applied_Dip * Capped_Bank_Angle/Full_BankAngle

    -- Now add Jitter if required
    if Jitter_On == true then
        ADF_Jitter = ADF_Jitter + ((Tgt_Jitter - ADF_Jitter)/Jitter_speed)
    else
        ADF_Jitter = 0
    end

        set("sim/operation/override/override_adf",1)    --Overrride the ADF rel bearing
        ADF1_Brg = ADF2_Brg
        if ident~="" then     -- Only apply dip and jitter if a valid ident code
            ADF1_Brg = ADF1_Brg + Applied_Dip + ADF_Jitter
        end
        
        set("sim/operation/override/override_adf",0)
        Status_Line = Status_Line .. " *  Real Relative Bearing" .. math.floor(relbrg)
        Status_Line = Status_Line .. " *  ADF1 Dipped Bearing " .. math.floor(ADF1_Brg)
        Status_Line = Status_Line .. " *  Dip " .. math.floor(Applied_Dip*10)/10
        Status_Line = Status_Line .. " *  ADF Jitter " .. math.floor(ADF_Jitter*10)/10
        Status_Line = Status_Line .. " *  Ident " .. ident
end


do_every_frame("new_adfdipped()")

function DataDraw()
	local pos = 0
	pos = bubble(20, pos, Status_Line)
	
end

--do_every_draw("DataDraw()")

function JitterADF()
    Tgt_Jitter = math.random(-1 * MAX_Jitter, MAX_Jitter)
end

do_often("JitterADF()")

---------------------------------------------
-- END       ADF gauge                     --
---------------------------------------------   