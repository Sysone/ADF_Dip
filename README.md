# ADF_Dip
A FlyWithLua script to implement ADF Dip in X-plane
This modification of Russ Greeen's original model and code implements ADF dip in x-plane as a FlyWithLua script/.

The script uses ADF2 to provide a reference bearing for the ADF and then adds two 'errors' typically seen in basic ADF units:
  1) ADF Dip, where due to the misalignment of the ADF antenna and the NDB station in certain orientations, the ADF needle tends to dip towards the lower wing in a turn; and
  2) Jitter, where the ADF needle tends to move randomly around the precise, correct heading.

The strength of these two effects can be configured in the initial lines of the script.

The script is hacked until it worked and has not been optimised or thoroughly debugged.

The script uses the following x-plane datarefs:
    DataRef("heading","sim/cockpit/radios/adf1_cardinal_dir","readonly")
    DataRef("ADF1_Brg","sim/cockpit/radios/adf1_dir_degt", "writable")
    DataRef("rollang", "sim/cockpit2/gauges/indicators/roll_electric_deg_pilot", "readonly")
    DataRef("ADF1_Freq", "sim/cockpit2/radios/actuators/adf1_frequency_hz","writable")
    DataRef("ADF2_Freq", "sim/cockpit2/radios/actuators/adf2_frequency_hz","writable")
    DataRef("ADF2_Brg","sim/cockpit2/radios/indicators/adf2_relative_bearing_deg", "readonly")
    DataRef("ident","sim/cockpit2/radios/indicators/adf1_nav_id","readonly")
    
     "sim/cockpit/radios/adf1_dir_degt" is used because it is one of the few ADF bearing datarefs which is writeable. Once the dip and jitter have been calculated
     they are added to this dataref, which drives the instrument.
     
     As Dip varies with roll angle "sim/cockpit2/gauges/indicators/roll_electric_deg_pilot" is used to provide roll input. In an aircraft model with no electric roll
     instruments, this may need to be changed to a vacuum source.
     
Known Issues
------------

Certain instruments appear to use absolute bearing datarefs rather than reletive bearings - notably glass cockpit. As these datarefs are not writeable, this script does not 
apply dip to the datarefs used by these instruments. (Known to not work with AirManager Aspen 1000.)

Because this script uses ADF2 as a reference bearing ADF2 must be tuned to and be receiving the same NDB as ADF1. This might lead to unpredictable behaviour in aircraft models with two ADFs.

Requires
------
X-Plane
FlyWithLua plugin
