#Ifdef ARrtGlobals
#pragma rtGlobals=1        // Use modern global access method.
#else
#pragma rtGlobals=3        // Use strict wave reference mode
#endif 
#pragma ModuleName=MainPanel
Menu "Automatic tuning"
	"Measure Curves", SecondHarmonic_Initialize()
End

Function SecondHarmonic_Initialize()
	
	// Make data folder to hold variables
	if (datafolderexists("Root:Variables") == 0)
		NewDataFolder Root:Variables
	endif

	cd "Root:Variables"
 
	String/G foldername = "SecondHarm"
	String/G exptbasename = "Tune"
	Variable/G firstspot = 0
	Variable/G lastspot = 0
	Variable/G centerfreq_input = 300
	Variable/G centerfreqL_input = 800
	Variable/G FittWidth_input=100
	Variable/G Tunetime_input=3
	Variable/G driveamp_input = 1
	Variable/G centerfreq
	Variable/G centerfreqL
	Variable/G driveamp
	Variable/G currentspot
	Variable/G currentvolt
	Variable/G Vincr=0 
	Variable/G MHarm1=1 
	Variable/G MHarm2=2 
	Variable/G involsconvert = GV("AmpInvOLS") // units of nm/V

	String/G processfolder = "SecondHarm"
	String/G basename = "Tune"
	String/G typeharm
	Variable/G freqfitwidth = 90
	Variable/G firstpoint = 0
	Variable/G lastpoint = 0
	Variable/G plotpoint = 0
	Variable/G incrmvolt=.2
	Variable/G stopvolt=3
	Variable/G DCOffset=0
	String/G exptbasenameFreq=exptbasename+"Freq"
	String/G exptbasenameAmp=exptbasename+"Amp"
	String/G exptbasenamePhase=exptbasename+"Phase"
	

	Execute "SecondHarmonicPanel()"

End

Window SecondHarmonicPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(773,71,1440,506)
	ShowTools/A
	SetDrawLayer UserBack
	SetDrawEnv linethick= 2
	DrawLine 16,221,642,221
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 13,247,"Select points"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 15,277,"Drive Amplitude Sweep"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 15,308,"Drive Frequencies (kHz)"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 18,367,"Enter the two harmonics you want to measure"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 32,122,"DC OFFSET correction [V]"
	SetDrawEnv linethick= 2
	DrawLine 342,122,342,208
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 365,126,"Signal and DAQ"
	SetVariable exptbasename_setvar,pos={376,32},size={179,24},bodyWidth=97,title="\\Z16\\f01File name"
	SetVariable exptbasename_setvar,value= root:Variables:exptbasename
	SetVariable foldername_setvar,pos={77,33},size={236,24},bodyWidth=132,title="\\Z16\\f01Folder name"
	SetVariable foldername_setvar,value= root:Variables:foldername,styledText= 1
	SetVariable firstspot_setvar,pos={286,229},size={160,16},title="First Spot"
	SetVariable firstspot_setvar,value= root:Variables:firstspot
	SetVariable lastspot_setvar,pos={480,229},size={138,16},title="Last Spot"
	SetVariable lastspot_setvar,value= root:Variables:lastspot
	SetVariable driveampinput_setvar,pos={310,258},size={95,16},bodyWidth=50,title="Start (V )"
	SetVariable driveampinput_setvar,value= root:Variables:driveamp_input
	SetVariable incrmvolt_setvar,pos={421,258},size={106,16},bodyWidth=50,title="Increments"
	SetVariable incrmvolt_setvar,value= root:Variables:incrmvolt
	SetVariable stopvolt_setvar,pos={545,258},size={73,16},bodyWidth=50,title="End"
	SetVariable stopvolt_setvar,value= root:Variables:stopvolt
	SetVariable centerfreqinput_setvar,pos={315,293},size={99,16},bodyWidth=60,title="Vertical"
	SetVariable centerfreqinput_setvar,value= root:Variables:centerfreq_input
	SetVariable centerfreqinputl_setvar,pos={523,293},size={96,16},bodyWidth=60,title="Lateral"
	SetVariable centerfreqinputl_setvar,value= root:Variables:centerfreql_input
	SetVariable MHarm1_setvar,pos={428,351},size={77,16},bodyWidth=60,title="#1"
	SetVariable MHarm1_setvar,value= root:Variables:MHarm1
	SetVariable MHarm2_setvar,pos={543,351},size={77,16},bodyWidth=60,title="#2"
	SetVariable MHarm2_setvar,value= root:Variables:MHarm2
	Button SecondHarmonic_button,pos={346,382},size={110,40},proc=SecondHarmonic_button,title="Measure Curves"
	SetVariable Fit_setvar1,pos={285,323},size={153,16},bodyWidth=60,title="Sweep width (kHz)"
	SetVariable Fit_setvar1,value= root:Variables:FittWidth_input
	SetVariable tunetime_setvar2,pos={482,320},size={137,16},bodyWidth=60,title="Tune time (sec)"
	SetVariable tunetime_setvar2,value= root:Variables:Tunetime_input
	Button Stop_button1,pos={188,379},size={110,40},proc=Stop_button,title="STOP"
	Button Stop_button1,fColor=(39168,0,0)
	SetVariable TipVoltageSetVar_0,pos={98,137},size={175,18},bodyWidth=110,proc=NapSetVarFunc,title="Tip Voltage"
	SetVariable TipVoltageSetVar_0,help={"Bias applied to the tip"},font="Arial"
	SetVariable TipVoltageSetVar_0,fSize=12,format="%.2W1PV"
	SetVariable TipVoltageSetVar_0,limits={-inf,inf,0.0001},value= root:packages:MFP3D:Main:Variables:MasterVariablesWave[%TipVoltage][%Value]
	CheckBox TipVoltageBox_0,pos={46,139},size={21,14},proc=NapCheckboxFunc,title=" "
	CheckBox TipVoltageBox_0,help={"When selected Tip Voltage will be applied to the surface pass"}
	CheckBox TipVoltageBox_0,value= 0
	SetVariable SurfaceVoltageSetVar_1,pos={72,161},size={201,18},bodyWidth=110,proc=NapSetVarFunc,title="Sample Voltage"
	SetVariable SurfaceVoltageSetVar_1,help={"Bias applied to the sample"}
	SetVariable SurfaceVoltageSetVar_1,font="Arial",fSize=12,format="%.2W1PV"
	SetVariable SurfaceVoltageSetVar_1,limits={-inf,inf,0.005},value= root:packages:MFP3D:Main:Variables:MasterVariablesWave[%SurfaceVoltage][%Value]
	CheckBox SurfaceVoltageBox_1,pos={46,163},size={21,14},proc=NapCheckboxFunc,title=" "
	CheckBox SurfaceVoltageBox_1,help={"When selected Sample Voltage will be applied to the surface pass"}
	CheckBox SurfaceVoltageBox_1,value= 0
	SetVariable TuneFilterSetVar_3,pos={414,157},size={199,18},bodyWidth=110,proc=TuneSetVarFunc,title="Low Pass Filter"
	SetVariable TuneFilterSetVar_3,help={"Low pass filter applied to capturing tune data"}
	SetVariable TuneFilterSetVar_3,font="Arial",fSize=12,format="%.3W1PHz"
	SetVariable TuneFilterSetVar_3,limits={-inf,inf,100},value= root:packages:MFP3D:Main:Variables:ThermalVariablesWave[%TuneFilter][%Value]
	SetVariable TuneCaptureRateSetVar_3,pos={426,131},size={187,18},bodyWidth=110,proc=TuneSetVarFunc,title="Capture Rate"
	SetVariable TuneCaptureRateSetVar_3,help={"Capture frequency used for a tune"}
	SetVariable TuneCaptureRateSetVar_3,font="Arial",fSize=12,format="%.3W1PHz"
	SetVariable TuneCaptureRateSetVar_3,limits={-inf,inf,100},value= root:packages:MFP3D:Main:Variables:ThermalVariablesWave[%TuneCaptureRate][%Value]
EndMacro

Function Stop_button(ctrlName) : ButtonControl //STOP

	String ctrlName // currently a string variable not used
	NVAR Vincr = root:Variables:Vincr
	NVAR DoNXTune =root:Packages:MFP3D:Tune:DoNXTune

	ARCheckFunc("DontChangeXPTCheck",0)//  unlock cross point
	ARCheckFunc("ARUserCallbackMasterCheck_1",0) // Turn off callbacks on tune
	ARExecuteControl("StopScan_0", "MasterPanel", 0, "") // Withdraw	
	DoNXTune = 0	// turn on harmonic measurmennts // 1 to turn on  N X tuning, 0 for off
	Vincr=0
	beep
	print "STOPED"

END
// This is the first function that will be run when the "measure curves" button is pressed
Function SecondHarmonic_button(ctrlName) : ButtonControl

	String ctrlName // currently a string variable not used
	// Declare all global variables used in this function
	SVAR foldername = root:Variables:foldername
	NVAR Vincr = root:Variables:Vincr
	NVAR firstspot = root:Variables:firstspot
	NVAR lastspot = root:Variables:lastspot
	NVAR centerfreq_input = root:Variables:centerfreq_input
	NVAR centerfreql_input = root:Variables:centerfreql_input
	NVAR driveamp_input = root:Variables:driveamp_input
	NVAR centerfreq = root:Variables:centerfreq
	NVAR centerfreqL = root:Variables:centerfreqL
	NVAR driveamp = root:Variables:driveamp
	NVAR currentspot = root:Variables:currentspot
	NVAR currentvolt = root:Variables:currentvolt
	NVAR centerfreq = root:Variables:centerfreq
	NVAR stopvolt = root:Variables:stopvolt
	NVAR incrmvolt = root:Variables:incrmvolt
	NVAR FittWidth_input = root:Variables:FittWidth_input
	NVAR Tunetime_input = root:Variables:Tunetime_input
	SVAR exptbasename = root:variables:exptbasename
	SVAR exptbasenameAmp = root:variables:exptbasenameAmp
	SVAR exptbasenameFreq = root:variables:exptbasenameFreq
	SVAR exptbasenamePhase = root:variables:exptbasenamePhase

	

	Variable Tunetime,stepsV, numpAmp
	Tunetime=Tunetime_input

	Variable/G widthfreq
	
	currentvolt = driveamp_input

	//NVAR driveamp = root:Variables:driveamp
	// Convert input frequency and drive amps into frequency in kHz, and amplitude before going through high voltage amplifier
	centerfreq = centerfreq_input*1000
	centerfreql = centerfreql_input*1000
	widthfreq=FittWidth_input*1000
	currentspot = firstspot
	ARExecuteControl("TuneTimeSetVar_3", "MasterPanel",Tunetime, "S") // tune time is deifned 	

	ARCheckFunc("DualACModeBox_3",1) // tunr dual AC on	
	
	
	ARExecuteControl("DualACModeBox_3", "MasterPanel",1,"") // turn dual AC on
	sleep/s 2
	
	ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune
	sleep/s 2
	
	
	NVAR DoNXTune =root:Packages:MFP3D:Tune:DoNXTune

	
		ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune
	sleep/s Tunetime
	numpAmp=numpnts(root:packages:MFP3D:Tune:Amp) //this is the number of data points in one tune!
	print "numpAmp" ,numpAmp

	// for this to work, you should have the modified version of thermal.ipf file in place  (ehsan's modification)
	 
	DoNXTune = 1	// turn on harmonic measurmennts // 1 to turn on  N X tuning, 0 for off
	Vincr=0	// this is the increment counter for drive amplitude.let's start with zero, fresh and easy!
	// Make new folder from the name selected and place in root
	String folder_path = "root:" + foldername
	if (datafolderexists(folder_path) == 0)
		NewDataFolder/O $folder_path
	endif

	cd folder_path
	
	stepsV=round((stopvolt- driveamp_input)/incrmvolt)+2
	
	Make/O/N=(2,stepsV) $exptbasename=NaN
	// i=vector data of tuning, j=step in voltage, k=location, l=[V1,V2,L1,L2]
	Make/O/N=(numpAmp,stepsV,lastspot+1, 4) $exptbasenameAmp=NaN
	Make/O/N=(numpAmp,stepsV,lastspot+1, 4) $exptbasenameFreq=NaN
	Make/O/N=(numpAmp,stepsV,lastspot+1, 4) $exptbasenamePhase=NaN

	
	// Turn on callbacks
	ARCheckFunc("ARUserCallbackMasterCheck_1", 1) //Master callback on
	ARCheckFunc("ARUserCallbackStopCheck_1", 1)  // withdraw callback
	ARCheckFunc("ARUserCallbackGoToSpotCheck_1", 1) // go to spot
	
	ARCheckFunc("ARUserCallbackTuneCheck_1",1)// tune call back

	ARExecuteControl("TuneTimeSetVar_3", "MasterPanel",Tunetime, "S") // tune time is deifned 	
	ARExecuteControl("SweepWidthSetVar_3", "MasterPanel", widthfreq, "Hz") // sweep width widthfreq Hz	

	PV("ForcespotNumber", firstspot)
	PDS("ARUserCallbackStop", "GotoPoint()")   // "ARUserCallbackStop" is the call back for "Withdraw". We associate "GotoPoint()" with withdraw, after each withdraw, gotopoint() will be perfromed.
	ARExecuteControl("StopScan_0", "MasterPanel", 0, "") // Withdraw
	//in the above code we turned on 2 callbacks (withdraw, go to spot), we associate withdraw with GoToPoint(), and then we withdraw. After the withdraw is completed, GotoPoint() will be run.
End

Function GotoPoint()
	NVAR firstspot = root:Variables:firstspot
	NVAR lastspot = root:Variables:lastspot
	NVAR currentspot = root:Variables:currentspot
	NVAR MHarm1 = root:Variables:MHarm1
	NVAR currentvolt = root:Variables:currentvolt
	NVAR centerfreq = root:Variables:centerfreq
	NVAR DoNXTune =root:Packages:MFP3D:Tune:DoNXTune
	NVAR centerfreqL = root:Variables:centerfreqL	
	SVAR exptbasename = root:variables:exptbasename	
	NVAR Vincr = root:Variables:Vincr
	Wave savewave =  $exptbasename	// First time running		
	SVAR exptbasenameAmp = root:variables:exptbasenameAmp
	SVAR exptbasenamePhase = root:variables:exptbasenamePhase
	SVAR exptbasenameFreq = root:variables:exptbasenameFreq
	Wave savewaveAmp =$exptbasenameAmp	// First time running			
	Wave savewaveFreq= $exptbasenameFreq	// First time running			
	Wave savewavePhase = $exptbasenamePhase	// First time running	
	if (currentspot == firstspot)
		ARExecuteControl("DriveAmplitudeSetVar_3", "MasterPanel",0,"V") // set drive amplitude1
		ARExecuteControl("DriveAmplitude1SetVar_3", "MasterPanel",currentvolt,"V") // set drive amplitude2
		ARExecuteControl("DriveFrequencySetVar_3", "MasterPanel",centerfreq,"Hz") // set center freq 1		
		ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm1,"")  // measuring "MHarm1" harmonic of Deflection signa	
		PV("ForcespotNumber", currentspot)
		// cross point setting
		ARExecuteControl("InFastPopup", "crosspointpanel",0,"ACdefl")//put InFast on ACDefl 
		ARCheckFunc("DontChangeXPTCheck",1)//  lock cross point
		ARExecuteControl("WriteXPT", "crosspointpanel",0,"Write Crosspoint")//write corsspoint
		ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm1,"")  // measuring "MHarm1" harmonic of Deflection signa
		if (vincr==0)
				PDS("ARUserCallbackGoToSpot", " tunev1()")	//associates tuneARv() with "go to point". //vertical tune
				ARExecuteControl("GoForce_2", "MasterPanel", 0, "")  // run go there and after that run tuneAR()
		else
			PDS("ARUserCallbackTune", " tuneARv()")	//associates tuneARv() with "tune". //vertical tune
			ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune and after that run tuneAR()		
		endif 		
	endif
	
	if (currentspot > firstspot && currentspot <= lastspot)
				ARExecuteControl("DriveAmplitudeSetVar_3", "MasterPanel",0,"V") // set drive amplitude1
				ARExecuteControl("DriveAmplitude1SetVar_3", "MasterPanel",currentvolt,"V") // set drive amplitude2
				ARExecuteControl("DriveFrequencySetVar_3", "MasterPanel",centerfreq,"Hz") // set center freq 1		
				ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm1,"")  // measuring "MHarm1" harmonic of Deflection signa	
				PV("ForcespotNumber", currentspot)
				PDS("ARUserCallbackGoToSpot", " tunev1()")	//associates tunev1() with "go to point". //vertical tune
				ARExecuteControl("GoForce_2", "MasterPanel", 0, "")  // run go there and after that run tuneAR()
	endif
	
	if (currentspot > lastspot)
		ARExecuteControl("DriveFrequencySetVar_3", "MasterPanel",centerfreqL,"Hz") // set center freq 1		
		ARCheckFunc("DontChangeXPTCheck",0)//  unlock cross point
		ARCheckFunc("ARUserCallbackMasterCheck_1",0) // Turn off callbacks on tune
		ARExecuteControl("StopScan_0", "MasterPanel", 0, "") // Withdraw	
		//DoNXTune = 0	// turn off harmonic measurmennts // 1 to turn on  N X tuning, 0 for off
		
		String freq1=exptbasename+"Freq.ibw"
		String amp1=exptbasename+"Amp.ibw"
		String phase1=exptbasename+"Phase.ibw"
		
		
		Save/O/C/P=SaveImage $exptbasename			
		Save/O/C/P=SaveImage savewaveAmp as amp1
		Save/O/C/P=SaveImage savewaveFreq as freq1	
		Save/O/C/P=SaveImage savewavephase	as phase1
		beep
		print "Tuning done"
	endif
End


function tunev1() //run the tune V 1
	PDS("ARUserCallbackTune", " tuneARv()")	//associates tuneARv2() with "tune". //vertical  tune #2harm
	ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune and after that run tuneAR()
End



Function tuneARv() //vertical  tune #1 harm

	NVAR MHarm2 = root:Variables:MHarm2	
	NVAR Vincr = root:Variables:Vincr
	NVAR currentspot = root:Variables:currentspot
	NVAR involsconvert = root:Variables:involsconvert
	SVAR exptbasename = root:variables:exptbasename
	SVAR typeharm = root:variables:typeharm
	SVAR exptbasenameAmp = root:variables:exptbasenameAmp
	SVAR exptbasenamePhase = root:variables:exptbasenamePhase
	SVAR exptbasenameFreq = root:variables:exptbasenameFreq
	Wave savewaveAmp =$exptbasenameAmp	// First time running			
	Wave savewaveFreq= $exptbasenameFreq	// First time running			
	Wave savewavePhase = $exptbasenamePhase	// First time running			
	Wave dumAmp=root:packages:MFP3D:Tune:Amp
	Wave dumPhase=root:packages:MFP3D:Tune:Phase
	Wave dumFreq=root:packages:MFP3D:Tune:frequency

	 typeharm="ARV"

	savewaveAmp[][Vincr][currentspot][0]=dumAmp[p]
	savewaveFreq[][Vincr][currentspot][0] =dumFreq[p]
	savewavePhase[][Vincr][currentspot][0] =dumPhase[p]	
	
	ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm2,"")  // measuring "MHarm2" harmonic of Deflection signa	
	PDS("ARUserCallbackTune", " tuneARv2()")	//associates tuneARv2() with "tune". //vertical  tune #2harm
	ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune and after that run tuneAR()
END

Function tuneARv2() //Vertical  tune  #2harm
	SVAR typeharm = root:variables:typeharm
	SVAR state=root:packages:mfp3d:xpt:state
	NVAR MHarm1 = root:Variables:MHarm1
	NVAR centerfreqL = root:Variables:centerfreqL	
	NVAR Vincr = root:Variables:Vincr
	NVAR currentspot = root:Variables:currentspot
	NVAR involsconvert = root:Variables:involsconvert
	SVAR exptbasename = root:variables:exptbasename	
	SVAR exptbasenameAmp = root:variables:exptbasenameAmp
	SVAR exptbasenamePhase = root:variables:exptbasenamePhase
	SVAR exptbasenameFreq = root:variables:exptbasenameFreq
	Wave savewaveAmp =$exptbasenameAmp	// First time running			
	Wave savewaveFreq= $exptbasenameFreq	// First time running			
	Wave savewavePhase =$exptbasenamePhase	// First time running			
	Wave dumAmp=root:packages:MFP3D:Tune:Amp
	Wave dumPhase=root:packages:MFP3D:Tune:Phase
	Wave dumFreq=root:packages:MFP3D:Tune:frequency
	
	 typeharm="ARV2"

		//saving the real tune data
	savewaveAmp[][Vincr][currentspot][1]=dumAmp[p]
	savewaveFreq[][Vincr][currentspot][1] =dumFreq[p]
	savewavePhase[][Vincr][currentspot][1]=dumPhase[p]
	
	
	ARExecuteControl("DriveFrequencySetVar_3", "MasterPanel",centerfreqL,"Hz") // set center freq for lateral 1st harm		
	ARExecuteControl("InFastPopup", "crosspointpanel",0,"Lateral")  //put InFast on Lateral
	ARExecuteControl("WriteXPT", "crosspointpanel",0,"Write Crosspoint") //write corsspoint
	ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm1,"")  // measuring "MHarm1" harmonic of Deflection signa	
	PDS("ARUserCallbackTune", " tuneARl()")	//associates tuneARv2() with "tune". //vertical  tune #1harm
	ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune and after that run tuneAR()
	
	

	
	
End

Function tuneARl() //lateral  tune #1 harm
	SVAR typeharm = root:variables:typeharm
	NVAR MHarm2 = root:Variables:MHarm2
	NVAR Vincr = root:Variables:Vincr
	NVAR currentspot = root:Variables:currentspot
	NVAR involsconvert = root:Variables:involsconvert
	SVAR exptbasename = root:variables:exptbasename	
	SVAR exptbasenameAmp = root:variables:exptbasenameAmp
	SVAR exptbasenamePhase = root:variables:exptbasenamePhase
	SVAR exptbasenameFreq = root:variables:exptbasenameFreq
	Wave savewaveAmp =$exptbasenameAmp	// First time running			
	Wave savewaveFreq= $exptbasenameFreq	// First time running			
	Wave savewavePhase = $exptbasenamePhase	// First time running			
	Wave dumAmp=root:packages:MFP3D:Tune:Amp
	Wave dumPhase=root:packages:MFP3D:Tune:Phase
	Wave dumFreq=root:packages:MFP3D:Tune:frequency
	 typeharm="ARL"
	 
	 		//saving the real tune data
	savewaveAmp[][Vincr][currentspot][2] =dumAmp[p]
	savewaveFreq[][Vincr][currentspot][2] =dumFreq[p]
	savewavePhase[][Vincr][currentspot][2] =dumPhase[p]

	ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm2,"")  // measuring "MHarm2" harmonic of Deflection signa	
	PDS("ARUserCallbackTune", " tuneARl2()")	//associates tuneARv2() with "tune". //vertical  tune #2harm
	ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")  // run one tune and after that run tuneAR()
	
End
	
Function tuneARl2() //lateral  tune #2 harm
	SVAR typeharm = root:variables:typeharm
	NVAR Vincr = root:Variables:Vincr
	NVAR currentvolt = root:Variables:currentvolt
	NVAR driveamp_input = root:Variables:driveamp_input
	NVAR currentspot = root:Variables:currentspot
	NVAR MHarm1 = root:Variables:MHarm1
	NVAR centerfreq = root:Variables:centerfreq	
	NVAR Vincr = root:Variables:Vincr
	NVAR stopvolt = root:Variables:stopvolt
	NVAR incrmvolt = root:Variables:incrmvolt
	NVAR currentspot = root:Variables:currentspot
	NVAR involsconvert = root:Variables:involsconvert
	SVAR exptbasename = root:variables:exptbasename	
	Wave savewave =$exptbasename	// First time running			savewave[currentspot][Vincr][9] = GV("TuneQResult")
	SVAR exptbasenameAmp = root:variables:exptbasenameAmp
	SVAR exptbasenamePhase = root:variables:exptbasenamePhase
	SVAR exptbasenameFreq = root:variables:exptbasenameFreq
	Wave savewaveAmp =$exptbasenameAmp	// First time running			
	Wave savewaveFreq=$exptbasenameFreq	// First time running			
	Wave savewavePhase = $exptbasenamePhase	// First time running			
	Wave dumAmp=root:packages:MFP3D:Tune:Amp
	Wave dumPhase=root:packages:MFP3D:Tune:Phase
	Wave dumFreq=root:packages:MFP3D:Tune:frequency
		NVAR involsconvert = root:Variables:involsconvert


	 typeharm="ARL2"
	 
	 		//saving the real tune data
	savewaveAmp[][Vincr][currentspot][3] =dumAmp[p]
	savewaveFreq[][Vincr][currentspot][3]=dumFreq[p]
	savewavePhase[][Vincr][currentspot][3] =dumPhase[p]

	ARExecuteControl("DriveAmplitudeSetVar_3", "MasterPanel",0,"V") // set drive amplitude1
	ARExecuteControl("DriveAmplitude1SetVar_3", "MasterPanel",currentvolt,"V") // set drive amplitude2		
	ARExecuteControl("InFastPopup", "crosspointpanel",0,"ACdefl")//put InFast on ACDefl	
	ARExecuteControl("WriteXPT", "crosspointpanel",0,"Write Crosspoint") //write corsspoint
	ARExecuteControl("DriveFrequencySetVar_3", "MasterPanel",centerfreq,"Hz") // set center freq 1		
	ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",1/MHarm1,"")  // measuring "MHarm1" harmonic of Deflection signa
	PDS("ARUserCallbackTune", " tuneARv()")	//associates tuneARv2() with "tune". //vertical  tune #2harm
	Print "Drive Amp=",currentvolt,"V -- Increment",Vincr, "  -- Current spot=",currentspot
	savewave[0][Vincr] = currentvolt
	savewave[1][Vincr] = involsconvert
	
	if ((currentvolt)< stopvolt)				
		Vincr+=1
		currentvolt += incrmvolt
		ARExecuteControl("DriveAmplitudeSetVar_3", "MasterPanel",0,"V") // set drive amplitude1
		ARExecuteControl("DriveAmplitude1SetVar_3", "MasterPanel",currentvolt,"V") // set drive amplitude2		
		ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")
	else
		Vincr=0
		currentvolt=driveamp_input
		currentspot += 1
		ARExecuteControl("StopScan_0", "MasterPanel", 0, "") // Withdrawing calls up the function "GoToPoint()"		
	endif

End


