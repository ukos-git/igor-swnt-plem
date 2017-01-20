#pragma TextEncoding = "UTF-8"		// For details execute DisplayHelpTopic "The TextEncoding Pragma"
//Programmed by Matthias Kastner
//Date 28.07.2015
//Version 0: 	Skeleton
//Version 1: 	Global Settings in binary file
//Version 2: 	Dynamic paths for User Procedures directory
//			Dynamic Delimited Text Load for old Gratings and other Correction Files.
//Version 3:	Specified fixed Format for Loading Maps, Background etc.
//Version 4:	Loading of PLEMd1 Correction Waves completed. Versioning System also for Global Variables Initialization.
//Version 5:	Global Variables of PLEMd1 are saved in Subdirectory (avoid trash)
//			Versioning System extended for subversions. Loading Procedure Corrected.
//Version 6	Created Loading Dialog for Choosing the correct file Names.
//Version 7:	Created Mapper for Parameters for Map-INFO-Folder
//Version 8:	Loading Procedure for Igor Binary files. Extract Data to ORIGINAL-Folder
//Version 9: 	Save Files to BACKGROUND, PLEM, usw. 
//Version 10:	Update to new output files from 2015-04-14
//Version 11:	Bug tracking for files from 2015-06-02 and 2015-06-08: wrong description given in LabView. Blank Spaces, Background etc.
//Version 12: Corrections in PLEMd2BuildMaps: DeltaX, DeltaY (should be moved to a PLEMd2statsCalculate)
//ToDelete: PLEMd2statsMenu, PLEMd2statsAction, PLEMd2statsMap (used in display), PLEMd2statsCalculate
//before PLEMd2BuildMaps is called there has to be a separate call to calculate the stats (separate to header)
//Version 13.0: Added buggy power correction for all waves in Data Folder PLEMd2PowerCorrection and DataLoop
//Version 13.1: Added Power Correction Wave Added Search for correction waves available.
//Version 13.2: Restructured BuildMaps. Added complete interpolation of measured data to igor Wave Format
//Version 13.3: Mainly Code CleanUp and more consistency to stats class.
//Version 13.4: Converted Photon, Power, Grating to 2D-Waves, clean up of code, separation of Build from ProcessIBW
//Version 13.5: Fixed Grating Correction. Some Cleanup. Deleted PLEMd2statsMenu, PLEMd2statsAction, PLEMd2statsMap, PLEMd2statsCalculate PLEMd2PowerCorrection etc.
//Version 14: Changed Wavelength wave and scaling. Clean Igor wavescaling is now done and measured wave is interpolated.
//Version 15: Panel and Graph Window
//Version 16: Integration of rudimentary Atlas Panel, Wave Normalization with gnumNormalization
//Versopm 16.4 Minor bug fixes on strMapsAvailable and statsInitialization, extended menu size, added kill wave
//Version 17 Added 2d-Peak fitting procedure
//Version 17.1 minor bug fixes
//Version 18 Added switches for calculation
//Version 19.1 Improved 2Dfit to include tubes near the borders
//current
//Version 20.1 separation into different files, new Helper Functions for global Variables. Update of Save and Load Procedures.
//Version 20.2 corrected Igor7 bug (search for "\r\n" to "\r" only)
//Version 20.3 ToDo: DataFolder does not exist at a certain point.
//	ToDo: new Correction Waves for new setup
//	ToDo: Maybe Delete Old Import PLEMd2d1 function for further releases
//	ToDo: use prefs for global vars. fix base datafolder etc.


#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Constant PLEMd2Version = 2002

// Variables for current Project only. See also the LoadPreferences towards the end of the procedure for additional settings that are saved system-wide.
Function PLEMd2initVar()
	print "PLEMd2initVar: intialization of global variables"
	//Init Data Folder
	String strSaveDataFolder = GetDataFolder(1)
	SetDataFolder root:
	String/G gstrPLEMd2root 	= "root:PLEMd2"
	NewDataFolder/O/S $gstrPLEMd2root

	//Save Data Folder befor execution of this program so we can always switch after our program terminates
	//definition here only for initialization. 
	//during run time it is set in PMRinit() but we will already switch folders here. so better also here safe the path.
	String/G gstrSaveDataFolder = strSaveDataFolder
	
	//Specify source for new correction files (displayer2) and old files (displayer1 or Tilman's original)
	String/G gstrPathBase	= SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:PLEMd2:"
	
	//Global Wave Names for correction files (maybe this is better done dynamically)
	String/G gstrCCD1250		= gstrPLEMd2root + ":" + "CCD1250"
	String/G gstrInGaAs1250	= gstrPLEMd2root + ":" + "InGaAs1250"
	
	String/G gstrPLEMd1root = gstrPLEMd2root + ":" + "PLEMd1"
	String/G gstrMapsFolder = gstrPLEMd2root + ":" + "maps"
	SetDataFolder $gstrPLEMd2root  //folder should already be there.	
	//Correction Waves from old PLEM-displayer1

	NewDataFolder/O/S	 $gstrPLEMd1root
	String/G gstrPLEMd1PathBase	 = SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:Korrekturkurven:"	
	//Load only specified waves from folder. Leave blank if all waves from directory above should be loaded.	
	String/G gstrPLEMd1CorrectionToLoad = "1200 nm Blaze & CCD @ +20 °C.txt;" + "1200 nm Blaze & CCD @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "1200 nm Blaze & InGaAs @ +25 °C.txt;" + "1200 nm Blaze & InGaAs @ -25 °C.txt;" + "1200 nm Blaze & InGaAs @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "1250 nm Blaze & CCD @ -90 °C.txt;" + "1250 nm Blaze & InGaAs @ -90 °C.txt;" 	
	gstrPLEMd1CorrectionToLoad += "500 nm Blaze & CCD @ +20 °C.txt;" + "500 nm Blaze & CCD @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "760 nm Strahlenteiler (Chroma) Abs.txt;" + "760 nm Strahlenteiler (Chroma) Em.txt;"
	
	//the following waves and strings should be loaded to root if PLEMd1 is loaded. We use the info for killing the vars.
	String/G gstrPLEMd1strings = "file_path;file_extension;file_name;left_PLE;right_PLE;"
	String/G gstrPLEMd1variables = "background;start_wl;end_wl;increment;multiple;single;chroma_abs;chroma_em;nkt;power;photon;fermi_parameter;grating_detector;checked_a;checked_b;checked_c;checked_d;checked_e;mode;"
	String/G gstrPLEMd1waves = "WL_500_CCD_minus90;E_500_CCD_minus90;WL_1200_CCD_minus90;E_1200_CCD_minus90;WL_1250_CCD_minus90;E_1250_CCD_minus90;WL_1200_InGaAs_minus90;E_1200_InGaAs_minus90;WL_1250_InGaAs_minus90;E_1250_InGaAs_minus90;chroma_x_abs;chroma_y_abs;chroma_x_em;chroma_y_em;correction_x;correction_y;"
	String/G gstrPLEMd1CorrectionAvailable = ""
	Variable/G gnumPLEMd1IsInit = 0
	
	SetDataFolder $gstrPLEMd2root
	//Maps: Create Folder and Initialize Strings where we store the maps of the current project
	
	NewDataFolder/O	 $gstrMapsFolder
	String/G gstrMapsAvailable = ""
	Variable/G gnumMapsAvailable	= 0
	PLEMd2MapStringReInit()

	//save current init-version in project folder.
	Variable/G gnumPLEMd2Version = PLEMd2Version
	//set a variable in root folder to recognize if the module was initialized.
	SetDataFolder root:
	Variable/G gnumPLEMd2IsInit = 1
	SetDataFolder $gstrPLEMd2root
End

Function PLEMd2isInit()
	//numInit only chages if all the tests are ok.
	Variable numInit = 0
	String strGlobalVariables = ""
	String strSaveDataFolder = GetDataFolder(1)

	SetDataFolder root:

	if (FindListItem("gnumPLEMd2IsInit", VariableList("gnum*",";",4)) != -1)
		NVAR gnumPLEMd2IsInit
		if (FindListItem("gstrPLEMd2root", StringList("gstr*",";")) != -1)
			SVAR gstrPLEMd2root	= root:gstrPLEMd2root
			if (DataFolderExists(gstrPLEMd2root))
				SetDataFolder $gstrPLEMd2root				
				//Check if Version of Procedure matches Project.
				if (FindListItem("gnumPLEMd2Version",VariableList("gnum*",";",4)) != -1)
					NVAR gnumPLEMd2Version
					if (!(gnumPLEMd2Version<PLEMd2Version))
						//only at this point we can be sure, that the project is initialized.
						numInit = gnumPLEMd2IsInit
					endif
				endif
			endif
		endif
	endif
	
	SetDataFolder $strSaveDataFolder	
	return numInit
End

//The Init and exit Function should be called before and after a menu item is called.
//strSaveDataFolder should be handled differently. Global Vars are not suitable here.

Function PLEMd2init()
	//remember current path
	String strSaveDataFolder = GetDataFolder(1)			

	if (PLEMd2isInit()==0)
		PLEMd2initVar()
	endif
	
	//Change DataFolder to Project Root
	SVAR gstrPLEMd2root	= root:gstrPLEMd2root	
	SetDataFolder $gstrPLEMd2root
	
	//Save Original Path in Project Root
	SVAR gstrSaveDataFolder	
	gstrSaveDataFolder = strSaveDataFolder		
End

Function PLEMd2reset()
	print "PLEMd2reset: reset"
	NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit //ToDo assure someHow that global NVAR was set.
	gnumPLEMd2IsInit = 0
	PLEMd2exit() //needed to restore old DataFolder
	PLEMd2init()  //...before it is saved again. (Overwrite Protection)
End

Function PLEMd2exit()
	//Change DataFolder to Project Root
	SVAR gstrPLEMd2root	= root:gstrPLEMd2root	
	SetDataFolder $gstrPLEMd2root

	//Get Original Folder from VAR
	SVAR gstrSaveDataFolder
	
	// Move Back to original Folder
	SetDataFolder $gstrSaveDataFolder
End

Function PLEMd2()
	//INIT
	STRUCT PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)
	PLEMd2init()
	
	
	//EXIT
	PLEMd2exit()
	PLEMd2SavePackagePrefs(prefs)
End

Function PLEMd2Clean()
	String strVariables, strStrings, strAvailable
	String strSaveDataFolder = GetDataFolder(1)
	Variable i, numAvailable
	
	SetDataFolder root:

	strVariables	= VariableList("V_*",";",4)	//Scalar Variables
	strVariables	+= VariableList("*",";",2)	//System Variables
	strStrings	= StringList("S_*",";")
	
	numAvailable = ItemsInList(strVariables)	
	for (i=0;i<numAvailable;i+=1)
		strAvailable = StringFromList(i, strVariables)		
		Killvariables/Z $("root:" + strAvailable)
	endfor
	
	numAvailable = ItemsInList(strStrings)
	for (i=0;i<numAvailable;i+=1)
		strAvailable = StringFromList(i, strStrings)		
		Killstrings/Z $("root:" + strAvailable)
	endfor
	
	SetDataFolder $strSaveDataFolder	
End

Function PLEMd2Open()
	//INIT
	Struct PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)
	PLEMd2init()
	
	SVAR gstrMapsFolder, gstrMapsAvailable
	DFREF dfrPLEM
	
	String strFile, strFileName, strFileType
	String strWave, strWaveExtract, strDataFolder, strWaveNames
	String strPLEM
	Variable numCurrentMap = -1
	Variable numTotalX, numTotalY	
	Variable i,j
	
	strFile=PLEMd2PopUpChooseFile(prefs)
	print "PLEMd2Open: Opening File from " + strFile
	if (strlen(strFile)>0)
		strFileName = ParseFilePath(3, strFile, ":", 0, 0)
		strFileType  = ParseFilePath(4, strFile, ":", 0, 0)
		strPLEM = ReplaceString(" ", strFileName, "")
		
		dfrPLEM = returnMapFolder(strPLEM)		
		SetDataFolder dfrPLEM
		strDataFolder = GetDataFolder(1, dfrPLEM)

		strswitch(strFileType)
			case "ibw":	// literal string or string constant
				LoadWave/Q/A/N=temp strFile
				if (ItemsInList(S_waveNames) == 1)
					// move loaded wave to IBW
					strWave	= StringFromList(0, S_waveNames)
					Duplicate/O  $strwave IBW
					KillWaves/Z $strWave					

				else
					print "PLEMd2Open: Error Loaded more than one or no Wave from Igor Binary File"
				endif

				break
			default:
				print "PLEMd2Open: Could not open file"
			break
		endswitch
	endif	
	PLEMd2ProcessIBW(strPLEM)	
	PLEMd2BuildMaps(strPLEM)
	PLEMd2Display(strPLEM)
	
	PLEMd2exit()
	PLEMd2SavePackagePrefs(prefs)
End

Function PLEMd2ProcessIBW(strPLEM)
	String strPLEM
	//INIT
	Struct PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)
	Struct PLEMd2Stats stats
	PLEMd2statsLoad(stats, strPLEM) // load values from last call or default values
	PLEMd2statsInitialize(strPLEM) //reinit stats on version missmatch.
	String strWaveNames, strWaveExtract
	Variable numTotalX, numTotalY, i, j
	
	//print "PLEMd2ProcessIBW: Started with " + strPLEM
	// check if IBW file was loaded prior to function call.
	if (WaveExists(stats.wavIBW)==0)
		print "PLEMd2ProcessIBW: IBW Wave does not exist. Check Code."
		Abort
	endif

	DFREF dfrOriginal = returnMapOriginalFolder(strPLEM)
	stats.strDataFolderOriginal = GetDataFolder(1, dfrOriginal)
	setDataFolder dfrOriginal
	
	// load waves from IBW file
	strWaveNames = PLEMd2ExtractWaveList(stats.wavIBW)
	numTotalX	= DimSize(stats.wavIBW,0)
	numTotalY	= DimSize(stats.wavIBW,1)	
	if (numTotalY == 0 || numTotalX == 0)
		print "PLEMd2ProcessIBW: Binary File has no waves"
	endif
	if (numTotalY != ItemsInList(strWaveNames))
		print "PLEMd2ProcessIBW: Error WaveNames not correct in WaveNotes. Trying to correct WaveNotes"
		print strWaveNames
		print num2str(numTotalY)
		PLEMd2FixWavenotes(strPLEM)
		strWaveNames = PLEMd2ExtractWaveList(stats.wavIBW)
	endif
	if (numTotalY == ItemsInList(strWaveNames))
		//Extract Columns from Binary Wave and give them proper names
		for (i=0; i<numTotalY; i+=1)
			strWaveExtract = StringFromList(i, strWaveNames)
			Make/D/O/N=(numTotalX) $strWaveExtract
			Wave wavExtract = $strWaveExtract
			for (j=0; j<numTotalX; j+=1)
				wavExtract[j] = stats.wavIBW[j][i]
			endfor
			WaveClear wavExtract
		endfor
	else
		print "PLEMd2ProcessIBW: Error WaveNames not found in WaveNotes. Check and correct manually Igor0,Igor1,Igor2,Igor3"
	endif
	
	PLEMd2ExtractInfo(stats)	
		
	//correction for obviously wrong background (LabView Error)
	wave wavBackground = BG
	if ((stats.numbackground == 1) && (WaveExists(wavBackground)))
		//maybe check also stats.numCalibrationMode
		print "PLEMd2BuildMaps: Error: Background was set wrong in (old) LabView Code. Using single Background to proceed: " + num2str(stats.numBackground)
		stats.numbackground = 0
		PLEMd2statsSave(stats)
	endif
	WaveClear wavBackground
	PLEMd2statsSave(stats)
End

Function PLEMd2MapsAppendNotes(strPLEM)
	String strPLEM	
	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)
	String strHeader
	
	strHeader = Note(stats.wavIBW)
	strHeader = strHeader[0,(strsearch(strHeader, "IGOR0",0)-1)] // clean WaveNotes
	// copy header to 2d-waves
	Note/K/NOCR stats.wavPLEM 			strHeader
	Note/K/NOCR stats.wavMeasure		strHeader
	Note/K/NOCR stats.wavBackground 	strHeader
	Note/K/NOCR stats.wavGrating 		strHeader
	Note/K/NOCR stats.wavPower 			strHeader
	Note/K/NOCR stats.wavPhoton 		strHeader
	Note/K/NOCR stats.wavFilter 			strHeader
	Note/K/NOCR stats.wavQE		strHeader
End


Function PLEMd2BuildMaps(strPLEM)
	String strPLEM

	String strSaveDataFolder = GetDataFolder(1)	
	SetDataFolder root:
	SVAR gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsFolder
	
	Struct PLEMd2stats stats
	String strWaveBG, strWavePL
	Variable numExcitationFrom, numExcitationTo
	Variable i,j, numItems
	
	if (PLEMd2MapExists(strPLEM))
		//There are 3 different structures for DATA
		//1) WAVES: WL, BG, PL ...
		//2) WAVES: WL, BG_498_502, PL_498_502,BG_502_506,PL_502_506 ...
		//3) WAVES: WL, BG, PL_498_502,PL_502_506,PL_506_510,PL_510_514 ...
		//Possibilities handled:
		//1)+3) stats.strbackground = single --> wavexists(background)
		//2) stats. strBackground = multiple --> count(BG_*) = count (PL_*)
		
		PLEMd2statsLoad(stats, strPLEM)
		SetDataFolder returnMapOriginalFolder(strPLEM)
		
		wave wavWavelength = WL
		wave wavBackground = BG

		// collect strWavePL und strWaveBG
		switch(stats.numbackground)
			case 0:
			//single background
				if (WaveExists(wavBackground))									
					strWavePL = WaveList("PL*",";","") //must also match 1)condition
					// fill strWaveBG with dummy "BG"
					numItems = ItemsInList(strWavePL, ";")
					strWaveBG = ""
					for (i=0; i<numItems; i+=1)
						strWaveBG += "BG;"
					endfor
				else
					print "PLEMd2BuildMaps: Error, wave BG does not exist in folder :ORIGINAL"
				endif
				break
			case 1:
			//multiple background
				strWavePL = WaveList("PL_*",";","")				
				strWaveBG = WaveList("BG_*",";","")
				break
			default:
				print "PLEMd2BuildMaps: Background Case not handled"
				break
		endswitch
		// partially clear original waves.
		WaveClear wavBackground
		
		// updating stats (TotalX and TotalY)
		if (ItemsInList(strWaveBG, ";") != ItemsInList(strWavePL, ";"))
			print "PELMd2BuildMaps: Error Size Missmatch between Background Maps and PL Maps"
			stats.numPLEMTotalY = 0
			return 0
		else
			stats.numPLEMTotalY = ItemsInList(strWavePL, ";")
		endif
		if (!WaveExists(wavWavelength))
			print "PLEMd2BuildMaps: Wavelength Wave not found within ORIGINAL Folder"
			return 0
		else
			stats.numPLEMTotalX = NumPnts(wavWavelength)
		endif
		if (stats.numPLEMTotalY==1)
			stats.numCalibrationMode = 1		
		else
			stats.numCalibrationMode = 0
		endif
		// until now, we only know the wavestats of the original waves.
		stats.numPLEMLeftX	= wavWavelength[0]
		stats.numPLEMRightX	= wavWavelength[(stats.numPLEMTotalX-1)]
		// create new Waves, overwrite existing		
		SetDataFolder $(stats.strDataFolder)		
		if (stats.numPLEMTotalY==1)
			Make/D/O/N=(stats.numPLEMTotalX) PLEM
			Make/D/O/N=(stats.numPLEMTotalX) MEASURE
			Make/D/O/N=(stats.numPLEMTotalX) BACKGROUND
			Make/D/O/N=(stats.numPLEMTotalX) GRATING
			Make/D/O/N=(stats.numPLEMTotalX) POWER
			Make/D/O/N=(stats.numPLEMTotalX) PHOTON
			Make/D/O/N=(stats.numPLEMTotalX) FILTER
			Make/D/O/N=(stats.numPLEMTotalX) QUANTUM
		else
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) PLEM
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) MEASURE
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) BACKGROUND
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) GRATING
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) POWER
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) PHOTON
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) FILTER
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) QUANTUM
		endif
		PLEMd2MapsAppendNotes(stats.strPLEM)
		Make/D/O/N=(stats.numPLEMTotalX) xWavelength
		Make/D/O/N=(stats.numPLEMTotalX) xGrating
		Make/D/O/N=(stats.numPLEMTotalX) yGrating
		Make/D/O/N=(stats.numPLEMTotalY) yExcitation
		Make/D/O/N=(stats.numPLEMTotalY) yPower
		Make/D/O/N=(stats.numPLEMTotalY) yPhoton
		// save stats and reload wave references
		PLEMd2statsSave(stats)
		PLEMd2statsLoad(stats, strPLEM) 
		
		// update stats
		stats.numPLEMLeftX 		= wavWavelength[0]		
		stats.numPLEMRightX 	= wavWavelength[(stats.numPLEMTotalX-1)]
		stats.numPLEMDeltaX 	= PLEMd2Delta(wavWavelength)
		
		// create new wavelength wave with equal spaces.
		stats.wavWavelength = stats.numPLEMLeftX + p * stats.numPLEMDeltaX
		
		// Grating Waves (requires wavWavelength)
		String strGratingWave = PLEMd2d1CorrectionConstructor(stats.numGrating,stats.numDetector,stats.numCooling)
		if (StringMatch(strGratingWave,""))
			stats.wavYgrating = 1
			stats.wavXgrating = stats.wavWavelength 
			print "PLEMd2BuildMaps: Grating Wave was set to 1"
		else
			Duplicate/O $(ReplaceString("DUMMY", strGratingWave, "E_",1,1)) yGrating
			Duplicate/O $(ReplaceString("DUMMY", strGratingWave, "WL_",1,1)) xGrating
			PLEMd2statsLoad(stats, strPLEM) //reload wave references. Do not save computer power! :-)
		endif

		//wavQuantumEfficiency, wavFilter not handled yet
		stats.wavQE = 1
		stats.wavFilter = 1
		
		// different handling for spectra in calibration mode (1) and for maps (0)
		if (stats.numCalibrationMode == 1)
			// Original Waves: load
			wave wavMeasure 	= $(stats.strDataFolderOriginal + StringFromList(0,strWavePL))
			wave wavBackground 	= $(stats.strDataFolderOriginal + StringFromList(0,strWaveBG))
			
			// Interpolate:
			// linearly Interpolate all waves  to equal distances (igor wave form)
			interpolate2 /T=1 /I=3 /Y=stats.wavMeasure/X=stats.wavWavelength wavWavelength, wavMeasure
			interpolate2 /T=1 /I=3 /Y=stats.wavBackground/X=stats.wavWavelength wavWavelength, wavBackground
			interpolate2 /T=1 /I=3 /Y=stats.wavGrating/X=stats.wavWavelength stats.wavXgrating, stats.wavYgrating
						
			// Excitation wave			
			stats.wavExcitation 	= (stats.numEmissionStart + stats.numEmissionEnd) / 2
			
			// Stats: update
			stats.numPLEMDeltaY 	= stats.numEmissionDelta
			stats.numPLEMBottomY 	= stats.numEmissionStart
			stats.numPLEMTopY 		= stats.numEmissionEnd			
		else
			for (i=0; i<stats.numPLEMTotalY; i+=1)
				// Original Waves: load
				wave wavMeasure 	= $(stats.strDataFolderOriginal + StringFromList(i,strWavePL))
				wave wavBackground 	= $(stats.strDataFolderOriginal + StringFromList(i,strWaveBG))
				
				// Interpolate Start:
				// correct all waves  (to igor wave form). Use Free Waves
				// Interpolate Measurement Wave
				Duplicate/O/FREE/R=[][i] stats.wavMeasure wavTempMeasure
				Interpolate2 /T=1 /I=3 /Y=wavTempMeasure /X=stats.wavWavelength wavWavelength, wavMeasure
				// Interpolate Background Wave
				Duplicate/O/FREE/R=[][i] stats.wavBackground wavTempBackground
				interpolate2 /T=1 /I=3 /Y=wavTempBackground /X=stats.wavWavelength wavWavelength, wavBackground				
				// Interpolate Correction Waves (will be the same all over the for loop …)
				Duplicate/O/FREE/R=[][i] stats.wavGrating wavTempGrating
				interpolate2 /T=1 /I=3 /Y=wavTempGrating /X=stats.wavWavelength stats.wavXgrating, stats.wavYgrating
				
				for (j=0; j<stats.numPLEMTotalX; j+=1)
					stats.wavMeasure[j][i] 		= wavTempMeasure[j]
					stats.wavBackground[j][i] 	= wavTempBackground[j]
					stats.wavGrating[j][i]		= wavTempGrating[j]
				endfor				
				
				// Interpolate End: unload temp (interpolation waves) waves
				WaveClear wavTempMeasure
				WaveClear wavTempBackground
				WaveClear wavTempGrating
				
				// Original Waves: unload
				WaveClear wavBackground
				WaveClear wavMeasure
				
				// Excitation wave
				numExcitationFrom 	= str2num(StringFromList(1,StringFromList(i,strWavePL),"_"))
				numExcitationTo 		= str2num(StringFromList(2,StringFromList(i,strWavePL),"_"))
				stats.wavExcitation[i] 	= (numExcitationFrom + numExcitationTo) / 2				
			endfor
			// Stats: update
			stats.numPLEMBottomY	= (str2num(StringFromList(1,StringFromList(0,strWavePL),"_")) + str2num(StringFromList(2,StringFromList(0,strWavePL),"_"))) / 2
			stats.numPLEMTopY		= (str2num(StringFromList(1,StringFromList((stats.numPLEMTotalY-1),strWavePL),"_")) + str2num(StringFromList(2,StringFromList((stats.numPLEMTotalY-1),strWavePL),"_"))) / 2		
			stats.numPLEMDeltaY 	= 0			
		endif

		// Stats: update
		stats.numPLEMDeltaY	= PLEMd2Delta(stats.wavExcitation)
		stats.strPLEMfull = GetWavesDataFolder(stats.wavPLEM,2)
		PLEMd2statsSave(stats)
		// Power correction 
		// requires Excitation wave for Photon Energy
		stats.wavYpower 		= str2num(StringFromList(p, PLEMd2ExtractPower(stats.wavIBW), ";"))
		stats.wavYphoton 		= (stats.wavYpower * 1e-6) / (6.62606957e-34 * 2.99792458e+8 / (stats.wavExcitation * 1e-9)) 		// power is in uW and Excitation is in nm
		for (i=0; i<stats.numPLEMTotalY; i+=1)
			stats.wavPower[][i]=stats.wavYpower[i]
			stats.wavPhoton[][i]=stats.wavYphoton[i]
		endfor
		// set distinct Wave Scaling for Maps
		SetScale/I x stats.numPLEMLeftX, stats.numPLEMRightX, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground, stats.wavGrating, stats.wavPower, stats.wavPhoton
		SetScale/I y stats.numPLEMBottomY, stats.numPLEMTopY, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground, stats.wavGrating, stats.wavPower, stats.wavPhoton
		SetScale/I x stats.numPLEMBottomY, stats.numPLEMTopY, "", stats.wavExcitation
		
		// calculate new map		
		print "PLEMd2BuildMaps: Calculating new Map"
		if (stats.booBackground)
			stats.wavPLEM = (stats.wavMeasure - stats.wavBackground)
		else
			stats.wavPLEM = stats.wavMeasure
		endif
		if (stats.booPower)
			stats.wavPLEM/=stats.wavPower
		endif
		if (stats.booPhoton)
			stats.wavPLEM/=stats.wavPhoton
		endif
		if (stats.booNormalization)
			stats.wavPLEM/=stats.numNormalization
		endif		
		if (stats.booGrating)
			stats.wavPLEM/=stats.wavGrating
		endif
		if (stats.booQuantumEfficiency)
			stats.wavPLEM*=stats.wavQE
		endif
	else
		print "PLEMd2BuildMaps: Map does not exist"
	endif
	print "PLEMd2BuildMaps: Building finished. Full Path to Wave is"
	print stats.strPLEMfull
	SetDataFolder $strSaveDataFolder	
End

// function modified from absorption-load-v6
// calculates the mean distance between points in wave.
// mainly used in the process of transforming waves to igor wave format.
Function PLEMd2Delta(wavInput)
	Wave wavInput
	
	Variable numSize, numDelta, i
	String strDeltaWave

	numSize		= DimSize(wavInput,0)
	if (numSize > 1)	
		// calculate numDelta
		strDeltaWave = nameofwave(wavInput) + "_Delta"
		Make/O/N=(numSize-1) $strDeltaWave
		wave wavDeltaWave = $strDeltaWave	
		// extract delta values in wave
		for (i=0; i<(numSize-1); i+=1)
			wavDeltaWave[i] = (wavInput[(i+1)] - wavInput[i])
		endfor
		WaveStats/Q/W wavDeltaWave
		KillWaves/Z  wavDeltaWave
		wave M_WaveStats
		numDelta = M_WaveStats[3] //average
		//print "Wave " + nameofwave(wavInput) + " has a Delta of " + num2str(numDelta) + " with a standard deviation of " + num2str(M_WaveStats[4])
		//if X-Wave is not equally spaced, set the half minimum delta at all points.
		// controll by calculating statistical error 2*sigma/rms		
		if ((2*M_WaveStats[4]/M_WaveStats[5]*100)>5)
			print "PLEMd2Delta: Wave is not equally spaced. Check Code and calculate new Delta."
			// minimum
			numDelta = M_WaveStats[10]
			// avg - 2 * sdev : leave out the minimum 5% for statistical resaons
			if (M_WaveStats[3] > 0)		// sdev is always positive ;-)
				numDelta = M_WaveStats[3] - 2 * M_WaveStats[4]
			else
				numDelta = M_WaveStats[3] + 2 * M_WaveStats[4]
			endif
		endif
		// not used put possibly needed, when a new Delta Value is returned.
		numSize = ceil(abs((wavInput[(numSize-1)] - wavInput[0])/numDelta)+1)
		KillWaves/Z  M_WaveStats
	else
		numDelta = 0
	endif
	return numDelta
End

Function PLEMd2ExtractInfo(stats)
	Struct PLEMd2Stats &stats
	String strFound
	
	stats.strDate 		= PLEMd2ExtractSearch(stats.wavIBW, "Date")
	stats.strUser 		= PLEMd2ExtractSearch(stats.wavIBW, "User")
	stats.strFileName = PLEMd2ExtractSearch(stats.wavIBW, "File")

	stats.numCalibrationMode = PLEMd2ExtractVariables(stats.wavIBW,"numCalibrationMode")
	stats.numSlit = PLEMd2ExtractVariables(stats.wavIBW,"numSlit")
	stats.numGrating = PLEMd2ExtractVariables(stats.wavIBW,"numGrating")
	stats.numFilter = PLEMd2ExtractVariables(stats.wavIBW,"numFilter")
	stats.numShutter = PLEMd2ExtractVariables(stats.wavIBW,"numShutter")
	stats.numWLcenter = PLEMd2ExtractVariables(stats.wavIBW,"numWLcenter")
	stats.numDetector = PLEMd2ExtractVariables(stats.wavIBW,"numDetector")
	stats.numCooling = PLEMd2ExtractVariables(stats.wavIBW,"numCooling")
	stats.numExposure = PLEMd2ExtractVariables(stats.wavIBW,"numExposure")
	stats.numBinning = PLEMd2ExtractVariables(stats.wavIBW,"numBinning")
	stats.numScans = PLEMd2ExtractVariables(stats.wavIBW,"numScans")
	stats.numBackground = PLEMd2ExtractVariables(stats.wavIBW,"numBackground")
	stats.numWLfirst = PLEMd2ExtractVariables(stats.wavIBW,"numWLfirst")
	stats.numWLlast = PLEMd2ExtractVariables(stats.wavIBW,"numWLlast")
	stats.numWLdelta = PLEMd2ExtractVariables(stats.wavIBW,"numWLdelta")
	stats.numEmissionMode = PLEMd2ExtractVariables(stats.wavIBW,"numEmissionMode")
	stats.numEmissionPower = PLEMd2ExtractVariables(stats.wavIBW,"numEmissionPower")
	stats.numEmissionStart = PLEMd2ExtractVariables(stats.wavIBW,"numEmissionStart")
	stats.numEmissionEnd = PLEMd2ExtractVariables(stats.wavIBW,"numEmissionEnd")
	stats.numEmissionDelta = PLEMd2ExtractVariables(stats.wavIBW,"numEmissionDelta")
	stats.numEmissionStep = PLEMd2ExtractVariables(stats.wavIBW,"numEmissionStep")
End
//This Function is called every time. we probably could make it more efficient. ;_(
Function PLEMd2ExtractVariables(wavIBW, strVariableName)
	Wave wavIBW
	String strVariableName

	String strHeader, strReadLine, strItem
	String strListVariableNames, strListVariables
	Variable i, numCount
	
	String strReturn = ""
	
	strHeader = Note(wavIBW)
	numCount = ItemsInList(strHeader, "\r\n")

	i=0
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r\n")
	while ((StringMatch(strReadLine, "*IGOR0:*") != 1) && (i<numCount))
	strListVariableNames = StringFromList(1, strReadLine, ":")
	
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r\n")
	while ((StringMatch(strReadLine, "*IGOR1:*") != 1) && (i<numCount))
	strListVariables = StringFromList(1, strReadLine, ":")

	strItem = StringFromList(WhichListItem(strVariableName, strListVariableNames), strListVariables)
	//print "for " + strVariableName + " at item number: " + num2str(WhichListItem(strVariableName, strListVariableNames)) + " found item: " + strItem
	
	return str2num(strItem)
End

Function/S PLEMd2ExtractSearch(wavIBW, strFind)
	Wave wavIBW
	String strFind

	String strHeader, strReadLine, strItem
	Variable i, numCount
	
	String strReturn = ""
	
	strHeader = Note(wavIBW)
	numCount = ItemsInList(strHeader, "\r\n")

	i=0
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r\n")
	while ((StringMatch(strReadLine, "*" + strFind + "*") != 1) && (i<numCount))

	strItem = StringFromList(1, strReadLine, ":")
	if ((strlen(strReadLine)>0) && (strlen(strItem)>0))
		strReturn = strItem
	else
		strReturn = ""
	endif	
	
	return strReturn
End

Function/S PLEMd2ExtractWaveList(wavIBW)
	Wave wavIBW
	
	String strHeader, strList, strReadLine, strItem
	String strListWaveNumbers, strListWaveNames
	Variable numListWaveNumbers, numListWaveNames	
	Variable i, numCount, numItem
	
	strHeader=note(wavIBW)
	numCount = ItemsInList(strHeader, "\r")

	i=0
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r")
	while ((StringMatch(strReadLine, "*IGOR2*") != 1) && (i<numCount))
	strListWaveNumbers = StringFromList(1, strReadLine, ":")	

	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r")
	while ((StringMatch(strReadLine, "*IGOR3*") != 1) && (i<numCount))
	strListWaveNames = StringFromList(1, strReadLine, ":")

	numListWaveNumbers = ItemsInList(strListWaveNumbers, ";")
	numListWaveNames = ItemsInList(strListWaveNames, ";")
	if (numListWaveNumbers != numListWaveNames)
		print "PLEMd2ExtractWaveList: Size Missmatch in Binary File. Check Labview Programming"
		return ""
	endif
	
	strList = ""
	for (i=0; i<numListWaveNames; i+=1)
		strItem = StringFromList(i, strListWaveNames, ";")		
		numItem = str2num(StringFromList(i, strListWaveNumbers, ";"))
		if (strlen(strItem)>0)
			strList=AddListItem(strItem, strList, ";", numItem)			
		endif
	endfor
	return strList
End

Function/S PLEMd2ExtractPower(wavIBW)
	//wavIBW can be any wave with correct wavenotes
	Wave wavIBW

	String strHeader, strReadLine
	String strListPower, strListParse
	Variable i, numCount, numItem
	
	String strReturn = ""
	
	strHeader = Note(wavIBW)
	numCount = ItemsInList(strHeader, "\r\n")

	i=0
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r\n")
	while ((StringMatch(strReadLine, "*Power at*") != 1) && (i<numCount)) //Power at Glass Plate (µW):
	strListParse = StringFromList(1, strReadLine, ":")
	
	numCount = ItemsInList(strListParse)
	strListPower = ""
	//assure to return numbers (not strings) in liststring
	for (i=0;i<numCount; i=i+1)
		numItem = str2num(StringFromList(i, strListParse))
		strListPower = AddListItem(num2str(numItem), strListPower,";",Inf)
	endfor 
	//print "for " + strVariableName + " at item number: " + num2str(WhichListItem(strVariableName, strListVariableNames)) + " found item: " + strItem
	
	return strListPower
End

Function PLEMd2DuplicateByNum(numPLEM)
	Variable numPLEM
	if (numPLEM < 0)
		print "PLEMd2DuplicateByNum: Wrong Function Call numPLEM out of range"
		return 0
	endif
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	PLEMd2Duplicate(strPLEM)
End

Function/S	PLEMd2Duplicate(strPLEM)
	String strPLEM

	Struct PLEMd2Stats stats
	PLEMd2statsLoad(stats, strPLEM)

	SetDataFolder $(stats.strDataFolder)
	Wave PLEM
	String strWavename="root:" + stats.strPLEM
	String strTemp = strWavename
	Variable i=0
	if (WaveExists($strWavename))
		print "PLEMd2Duplicate: Wave already exists. Using incremental WaveName"
		do 
			wave wavTemp =$("")
			strTemp = strWavename + "_" + num2str(i)
			wave wavTemp = $strTemp
			i+=1		
		while (WaveExists(wavTemp))
		strWavename = strTemp
		wave wavTemp =$("")
	endif
	Duplicate PLEM $strWavename
	wave wavDuplicated = $strWavename
	print "PLEMd2Duplicate: WaveName is " + strWavename	
	SetDataFolder root:
	return GetwavesDataFolder(wavDuplicated,2)
End

//PLEMd2FixWavenotes
//Daniel Zuleeg programmed Igor3: and Igor4 where there should be Igor2 and Igor3.
Function PLEMd2FixWavenotesByNum(numPLEM)
	Variable numPLEM
	if (numPLEM < 0)
		print "PLEMd2FixWavenotesByNum: Wrong Function Call numPLEM out of range"
		return 0
	endif	
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	PLEMd2FixWavenotes(strPLEM)
End

Function PLEMd2FixWavenotes(strPLEM)
	String strPLEM
	Struct PLEMd2Stats stats
	String strHeader
	PLEMd2statsLoad(stats, strPLEM)
	
	strHeader = Note(stats.wavIBW)

	if ((StringMatch(strHeader, "*IGOR2:*")) == 0)
		//IGOR2 not found so the error is probably related to that. (caused by early version of LabView program)
		//I rename IGOR4 to IGOR3 and IGOR3 to IGOR2.
		print "PLEMd2FixWavenotes: Error: Did not find IGOR2 in WaveNote. Fixing...."
		strHeader = ReplaceString("IGOR3:",strHeader,"IGOR2:")
		strHeader = ReplaceString("IGOR4:",strHeader,"IGOR3:")
		Note/K/NOCR stats.wavIBW strHeader
	Endif
End



Function PLEMd2AtlasReload(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)
	
	// switch folder
	String strSaveDataFolder = GetDataFolder(1)
	String strDataFolder = stats.strDataFolder + "CHIRALITY"
	SetDataFolder $strDataFolder

	// create waves
	Make/O/N=45/D atlasS1nm
	Make/O/N=45/D atlasS2nm
	Make/O/N=45/D atlasN
	Make/O/N=45/D atlasM

	// tell igor that those are waves
	wave wavAtlasS1nm=atlasS1nm
	wave wavAtlasS2nm=atlasS2nm	
	wave wavAtlasN=atlasN
	wave wavAtlasM=atlasM

	// fill waves with data
	wavAtlasS1nm[0]= {613.783,688.801,738.001,765.334,821.087,861.001,898.436,939.274,939.274,961.118,1008,1033.2,1078.12,1097.21,1107,1116.97,1148,1148,1169.66,1227.57,1227.57,1239.84,1239.84,1239.84,1278.19}
	wavAtlasS1nm[25]= {1291.5,1318.98,1347.65,1347.65,1347.65,1362.46,1377.6,1393.08,1441.68,1441.68,1441.68,1458.64,1458.64,1512,1549.8,1549.8}
	wavAtlasS2nm[0]= {568.735,510.223,613.783,596.078,480.559,576.671,688.801,497.928,659.49,563.564,639.094,729.319,712.553,582.085,642.405,548.603,789.708,708.481,784.71,629.361,779.775,720.838,666.582,607.766}
	wavAtlasS2nm[24]= {849.207,784.71,849.207,746.893,681.232,708.481,849.207,799.898,918.401,861.001,925.255,918.401,751.419,789.708,885.601,991.873,932.212}
	wavAtlasN[0]	= {6, 5, 8, 7, 5, 6, 9, 7, 8, 6, 7, 10,9, 8, 7, 9,12, 8,11,10,10,8,9,11,13,9,12,10,12,11,11,9,15,10,14,13,13,12,10,16,12}
	wavAtlasM[0]	= {1, 3, 0, 2, 4, 4, 1, 3, 3, 5, 5, 2, 4, 4, 6, 2, 1, 6, 3,3,5,7,5,1,2,7,4,6,2,4,6,8,1,8,3,5,3,5,9,2,7}
	
	// reset original folder
	SetDataFolder $strSaveDataFolder
End

Function PLEMd2AtlasCreateNM(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)	
	
	Variable i
	
	WaveStats/Q/M=1 stats.wavChiralityn
	Redimension/N=(V_npnts) stats.wavChiralitynm
	for(i=0;i<V_npnts;i+=1)
		stats.wavChiralitynm[i]="("+num2str(stats.wavChiralityN[i])+","+num2str(stats.wavChiralityM[i])+")"
	endfor

End

Function PLEMd2AtlasRecalculate(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)	
	Variable numPlank = 4.135667516E-12 //meV s
	Variable numLight =  	299792458E9 //nm/s
	stats.wavEnergyS1	= numPlank * numLight / (numPlank * numLight / stats.wavAtlasS1nm - stats.numS1offset)
	stats.wavEnergyS2	= numPlank * numLight / (numPlank * numLight / stats.wavAtlasS2nm - stats.numS2offset)	
End

Function PLEMd2AtlasInit(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats

	PLEMd2AtlasReload(strPLEM) // also populates wave references
	PLEMd2statsLoad(stats, strPLEM)	// so we have to load afterwards
	
	Duplicate/O stats.wavAtlasS1nm stats.wavEnergyS1
	Duplicate/O stats.wavAtlasS2nm stats.wavEnergyS2
	Duplicate/O stats.wavAtlasN stats.wavchiralityn
	Duplicate/O stats.wavAtlasM stats.wavchiralitym
	
	// create waves of appropriate dimensions
	Duplicate/O stats.wavAtlasN stats.wav2Dfit
	Duplicate/O stats.wavAtlasN stats.wav1Dfit	
	stats.wav2Dfit = 0
	stats.wav1Dfit = 0
	
	stats.numS1offset = 0 // set to zero to avoid confusion. old values could be preserved.
	stats.numS2offset = 0
	// no recalculation needed
	PLEMd2AtlasCreateNM(strPLEM) // creates chiralitynm
	PLEMd2statsSave(stats)
	
End

Function PLEMd2AtlasEdit(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	String winPLEMedit
	
	if (PLEMd2MapExists(strPLEM) == 0)
		print "PLEMd2AtlasFit: Map does not exist properly"
		return 0
	endif
	
	PLEMd2statsLoad(stats, strPLEM)
	
	winPLEMedit = "win_" + stats.strPLEM + "_edit"
	DoWindow/F $winPLEMedit
	if (V_flag == 0)
		Edit stats.wavchiralitynm, stats.wav2Dfit, stats.wav1Dfit, stats.wavEnergyS1, stats.wavEnergyS2, stats.wavChiralityn, stats.wavChiralityM
		DoWindow/C/N/R $winPLEMedit
	endif	
	
End
Function PLEMd2AtlasClean(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	Variable i, numPoints
	
	PLEMd2statsLoad(stats, strPLEM)
	numPoints = DimSize(stats.wavchiralitynm,0)
	for (i=0; i<DimSize(stats.wavchiralitynm,0); i+=1)
		if (stats.wav2Dfit[i] == 0)
			DeletePoints i,1, stats.wavchiralitynm, stats.wavchiralityn, stats.wavchiralitym
			DeletePoints i,1, stats.wav2Dfit, stats.wav1Dfit, stats.wavEnergyS1, stats.wavEnergyS2
			i-=1
		endif		
	endfor
End
Function PLEMd2AtlasFit1D(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)	
End
Function PLEMd2AtlasFit2D(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	
	Variable numS1,numS2
	Variable numDeltaS1, numDeltaS2
	Variable numDeltaS1left, numDeltaS1right, numDeltaS2bottom, numDeltaS2top
	Variable V_fitOptions=4 // used to suppress CurveFit dialog
	Variable V_FitQuitReason // stores the CurveFit Quit Reason
	Variable V_FitError // Curve Fit error
	String strChirality = ""
	String strWavPLEMfitSingle, strWavPLEMfit
	String winPLEMfit, winPLEM
	Variable i
	
	if (PLEMd2MapExists(strPLEM) == 0)
		print "PLEMd2AtlasFit: Map does not exist properly"
		return 0
	endif
	
	// make waves
	PLEMd2statsLoad(stats, strPLEM)	
	strWavPLEMfitSingle 	= GetWavesDataFolder(stats.wavPLEMfitSingle,2)
	strWavPLEMfit 		= GetWavesDataFolder(stats.wavPLEMfit,2) 
	Make/O/N=(stats.numPLEMtotalx,stats.numPLEMtotaly,numpnts(stats.wavEnergyS1)) $strWavPLEMfit
	Make/O $strWavPLEMfitSingle //dummy wave
	// reload wave references
	PLEMd2statsLoad(stats, strPLEM)	
	
	stats.wavPLEMfit = NaN
	stats.wavPLEMfitSingle = 0
	SetScale y,stats.numPLEMbottomY,stats.numPLEMtopY,"",stats.wavPLEMfit
	SetScale x,stats.numPLEMleftX,stats.numPLEMrightX,"",stats.wavPLEMfit 
	//Display
	//AppendImage stats.wavPLEM
	
	numDeltaS1 = 50
	numDeltaS2 = 50	
	// input
	i=0
	for (i=0;i<numpnts(stats.wavEnergyS1);i+=1)	
		stats.wavPLEMfit[][][i]=0
		stats.wav2Dfit[i] = 0
		numS1 = stats.wavEnergyS1[i] //x
		numS2 = stats.wavEnergyS2[i] //y	
		
		numDeltaS1left 	= numDeltaS1/2
		numDeltaS1right 	= numDeltaS1/2
		numDeltaS2bottom = numDeltaS2/2
		numDeltaS2top 	= numDeltaS2/2
		
		if ((numS1-numDeltaS1left)<stats.numPLEMleftX)
			//print "chirality not in Map S1 Data Range"
			numDeltaS1left = numS1 - stats.numPLEMleftX
			if (numDeltaS1left<0)
				numDeltaS1left = 0
			endif
		endif
		if ((numS1+numDeltaS1right)>stats.numPLEMrightX)
			//print "chirality not in Map S1Data Range"
			numDeltaS1right = stats.numPLEMrightX - numS1
			if (numDeltaS1right<0)
				numDeltaS1right = 0
			endif
		endif
		if ((numS2-numDeltaS2bottom)<stats.numPLEMbottomY)
			//print "chirality not in Map S1Data Range"
			numDeltaS2bottom = numS2 - stats.numPLEMbottomY
			if (numDeltaS2bottom<0)
				numDeltaS2bottom = 0
			endif			
		endif
		if ((numS2+numDeltaS2top)>stats.numPLEMtopY)
			//print "chirality not in Map S1Data Range"
			numDeltaS2top = stats.numPLEMtopY - numS2
			if (numDeltaS2top<0)
				numDeltaS2top = 0
			endif
		endif
		if ((numDeltaS1<0) | (numDeltaS2<0))
			stats.wavPLEMfit[][][i] = 0
			stats.wav2Dfit[i] = 0			
		else
			V_FitError = 0
			//Make/O/T fitConstraints={"K6 = 0"}
			//Make/FREE/O W_coef = {0,1,stats.wavEnergyS1[i], (sqrt(stats.wav2Dfit[i]/(2*pi))), stats.wavEnergyS2[i], (sqrt(stats.wav2Dfit[i]/(2*pi))), 0}
			// gauss2d=K0+K1*exp((-1/(2*(1-K6^2)))*(((x-K2)/K3)^2 + ((y-K4)/K5)^2 - (2*K6*(x-K2)*(y-K4)/(K3*K5))))
			CurveFit/Q gauss2D stats.wavPLEM(numS1-numDeltaS1left,numS1+numDeltaS1right)(numS2-numDeltaS2bottom,numS2+numDeltaS2top)
			//FuncFit/Q PLEMd2SimpleGaussian2D, W_coef stats.wavPLEM(numS1-numDeltaS1left,numS1+numDeltaS1right)(numS2-numDeltaS2bottom,numS2+numDeltaS2top)
			if (V_FitError == 0)				
				Wave W_coef
				stats.wavPLEMfit[][][i] = Gauss2D(W_coef, x, y)
				stats.wavEnergyS1[i] = W_coef[2]
				stats.wavEnergyS2[i] = W_coef[4]
				stats.wav2Dfit[i] = W_coef[1]*2*pi* W_coef[3]* W_coef[5]*sqrt(1-W_coef[6]^2) // volume of 2d gauss without baseline
				
				//stats.wavPLEMfit[][][i] = PLEMd2SimpleGaussian2D(W_coef, x, y)
				//stats.wavEnergyS1[i] = W_coef[2]
				//stats.wavEnergyS2[i] = W_coef[4]
				//stats.wav2Dfit[i] = W_coef[1]*2*pi* W_coef[3]* W_coef[5] // volume of simpleGaussian

				W_coef = 0
				WaveClear W_coef
			else
				stats.wavPLEMfit[][][i] = 0
				stats.wav2Dfit[i] = 0
			endif
			// error checking
			if ((stats.wavEnergyS1[i]<0) | (stats.wavEnergyS2[i]<0) | (stats.wav2Dfit[i]<0))
				stats.wavPLEMfit[][][i] = 0
				stats.wav2Dfit[i] = 0			
			endif
			if ( (abs((numS1-stats.wavEnergyS1[i])/numS1)>0.25 ) | (abs((numS2-stats.wavEnergyS2[i])/numS2)>0.25 ))
				stats.wavPLEMfit[][][i] = 0
				stats.wav2Dfit[i] = 0			
			endif
		endif
	endfor
	// add all maps to one map
	PLEMd2AtlasMerge3d(stats.wavPLEMfit,stats.wavPLEMfitSingle)
	
	// check if window already exists
	winPLEM = "win_" + stats.strPLEM
	DoWindow/F $winPLEM
	// DoWindow sets the variable V_flag: 
	// 	1 window existed
	// 	0 no such window
	// 	2 window is hidden. 	
	if (V_flag == 1)
		String listContour = ContourNameList("", ";")
		for (i=0;i<ItemsInList(listContour);i+=1)
			RemoveContour $(StringFromList(i, listContour))
		endfor
		AppendMatrixContour stats.wavPLEMfitSingle
		ModifyContour ''#0 labels=0,autoLevels={0,*,10}
	endif

	// check if window already exists
	winPLEMfit = "win_" + stats.strPLEM + "_fit"
	DoWindow/F $winPLEMfit
	if (V_flag == 2)
		print "PLEMd2AtlasFit: Fit-Graph was hidden. Case not handled. check code"
	elseif (V_flag == 0)
		Display
		DoWindow/C/N/R $winPLEMfit
		Appendimage stats.wavPLEMfitSingle
		PLEMd2Decorate()
	endif
End

// define your own fit functions
Function PLEMd2SimpleGaussian2D(w,x,y):Fitfunc
    Wave w
    variable x
    variable y
    
    //w[0] = background
    //w[1] = amplitude
    //w[2] = x centre
    //w[3] = peak width
    //w[4] = y centre
    return    w[0]+w[1]*exp(-( (x-w[2])^2/(2 * w[3]^2) - (y-w[4])/(2 * w[5]^2)   ))
End

Function PLEMd2AtlasMerge3d(wave3d,wave2d)
	Wave wave3d,wave2d
	Variable i
	Duplicate/O/R=[][][0] wave3d wave2d
	Redimension/N=(Dimsize(wave3d,0),Dimsize(wave3d,1)) wave2d
	for(i=1;i<Dimsize(wave3d,2);i+=1)
		wave2d += wave3d[p][q][i]
	endfor	
End

Function PLEMd2AtlasShow(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	if (PLEMd2MapExists(strPLEM) == 0)
		print "PLEMd2AtlasShow: Map does not exist properly"
		return 0
	endif
	PLEMd2statsLoad(stats, strPLEM)	
	PLEMd2Display(strPLEM)
	PLEMd2AtlasHide(strPLEM) //prevent multiple traces
	//wavEnergyS1, , wavChiralityn, wavChiralitym, wav2Dfit
	AppendToGraph stats.wavEnergyS2/TN=plem01 vs stats.wavEnergyS1
	AppendToGraph stats.wavEnergyS2/TN=plem02 vs stats.wavEnergyS1
	AppendToGraph stats.wavEnergyS2/TN=plem03 vs stats.wavEnergyS1
	
	ModifyGraph mode(plem02)=3 //cross
	ModifyGraph marker(plem02)=1
	ModifyGraph rgb(plem02)=(0,0,0)

	ModifyGraph mode(plem03)=3 //dots
	ModifyGraph useMrkStrokeRGB(plem03)=1
	ModifyGraph textMarker(plem03)={stats.wavChiralitynm,"default",0,0,5,0.00,10.00} //labels top
	ModifyGraph rgb(plem03)=(65535,65535,65535)
	ModifyGraph mrkStrokeRGB(plem03)=(65535,65535,65535)
	
	ModifyGraph mode(plem01)=3 , msize(plem01)=2		
	ModifyGraph marker(plem01)=5 // squares
	ModifyGraph marker(plem01)=8 // circles
	ModifyGraph msize(plem01)=5
	ModifyImage ''#0 ctab= {0,*,Terrain256,0}	
	ModifyGraph height={Plan,1,left,bottom}		
End
Function PLEMd2AtlasHide(strPLEM)
	String strPLEM
	if (PLEMd2MapExists(strPLEM) == 0)
		print "PLEMd2AtlasHide: Map does not exist properly"
		return 0
	endif
	PLEMd2Display(strPLEM)
	RemoveFromGraph/Z plem01
	RemoveFromGraph/Z plem02	
	RemoveFromGraph/Z plem03
	
	Variable i
	String listContour = ContourNameList("", ";")
	for (i=0;i<ItemsInList(listContour);i+=1)
		RemoveContour $(StringFromList(i, listContour))
	endfor	
End


Function PLEMd2d1Open()

End

//adapted from function OpenFileDialog on http://www.entorb.net/wickie/IGOR_Pro
Function/S PLEMd2PopUpChooseFile(prefs,[strPrompt])
	STRUCT PLEMd2Prefs &prefs
	String strPrompt
	strPrompt = selectstring(paramIsDefault(strPrompt), strPrompt, "choose file")
	
	Variable refNum
	String strOutputPath = ""
	String strOutputFile = ""
	String fileFilters = "Igor Binary File (*.ibw):.ibw;General Text Files (*.txt, *.csv):.txt,.csv;All Files:.*;"
	String strPath = ""
	
	//load Path from Preferences.
	strPath = prefs.strMapsPath
	
	GetFileFolderInfo/Q/Z=1 strPath
	
	if (V_Flag != 0)
		print "PLEMd2PopUpChooseFile: Path does not exist. Switching to System Documents Folder"
		strPath = SpecialDirPath("Documents", 0, 0, 0 )	
	endif

	NewPath/O/Q/Z path, strPath
	PathInfo/S path
	if (V_flag == 0)
		print "PLEMd2PopUpChooseFile: Selected Path is not valid. Check code."
		return ""
	endif

	//Display /D ialog for /R eading from File
	//Path was magically set by the /S flag from PathInfo.
	Open/Z=2/D/F=fileFilters/R/M=strPrompt refNum
	strOutputFile = S_fileName	
	if (V_flag == 0) 
		GetFileFolderInfo/Q/Z=1 ParseFilePath(1, strOutputFile, ":", 1, 0)
		if (V_isFolder == 1)
			//print "PLEMd2PopUpChooseFile: Remembering Current Path"
			prefs.strMapsPath = S_Path
		endif
	endif
	
	return strOutputFile
	
End 

//imports Maps and corresponding files from 
//old PLE-Map displayer created by Tilman Hain from ~2013-2015
//Old Maps Data have to be in current project root:
Function PLEMd2d1Import(numKillWavesAfterwards)
	Variable numKillWavesAfterwards
	//if (ParamIsDefault(numKillWavesAfterwards))
	//	numKillWavesAfterwards = 0
	//endif
	PLEMd2init()	
	SVAR gstrMapsFolder
	SVAR gstrMapsAvailable
	NVAR gnumMapsAvailable	

	Struct PLEMd2Stats stats
	
	String strMaps, strMap
	String strWaves, strWave
	String strSearchStrings, strSearchString
	
	Variable numMaps, numWaves, numSearchstrings, numFiles
	Variable numTotalX, numTotalY	 //used for measuring the Dimensions of the Map
	Variable i,j,k
	
	strMaps = PLEMd2d1Find()
	numMaps = ItemsInList(strMaps)
	
	print "PLEMd2d1Import: found " + num2str(numMaps) + " old map(s)"
	
	// copy all the map data to the new project structure
	for (i=0;i<numMaps;i+=1)
		SetDataFolder $gstrMapsFolder
		strMap 		= StringFromList(i, strMaps)
		numFiles	= PLEMd2d1CountFiles("root:" + strMap)
		print "PLEMd2d1Import: Importing " + strMap + " with " + num2str(numFiles) + " data waves."
		
		//In MapsFolder we create subdirectories for the waves.
		if (DataFolderExists(strMap))
			SetDataFolder $strMap
		else
			NewDataFolder/S $strMap
			PLEMd2statsInitialize(strMap)
		endif
		
		//Load Stats
		PLEMd2statsLoad(stats, strMap)
		
		//Copy Original Data Waves in Subdirectory
		strSearchStrings	 = "_bg_;_corr_m_;_"
		numSearchstrings = ItemsInList(strSearchStrings)		
		if (DataFolderExists("ORIGINAL"))
			SetDataFolder ORIGINAL
		else
			NewDataFolder/O/S ORIGINAL
		endif
		for (j=0;j<numSearchstrings;j+=1)
			strSearchString = StringFromList(j, strSearchStrings)
			for (k=0;k<numFiles;k+=1)
				strWave = strMap + strSearchString + num2str(k)
				wave wavDummy = $("root:" + strWave)
				if (WaveExists(wavDummy))
					Duplicate/O wavDummy $strWave
					if (numKillWavesAfterwards == 1)
						Killwaves/Z wavDummy
					endif
				endif				
			endfor
		endfor
		SetDataFolder $gstrMapsFolder
		SetDataFolder $strMap
		
		//Copy Map for dimensions.
		wave wavPLEM = $("root:PLE_map_" + strMap)		
		if (WaveExists(wavPLEM))
			numTotalX	= DimSize(wavPLEM,0)
			numTotalY	= DimSize(wavPLEM,1)
			if (numTotalY != numFiles)
				print "PLEMd2d1Import: Size Missmatch in Map: " + strMap
			endif
			Duplicate/O wavPLEM PLEM
			if (numKillWavesAfterwards == 1)
				Killwaves/Z wavPLEM
			endif
			
			wave wavPLEM = PLEM		
			//Create Measurement Wave from Files.
			Duplicate/O wavPLEM MEASURE
			wave wavMeasure	= MEASURE
			
			for (j=0;j<numTotalY;j+=1)
				strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_" + num2str(j)
				wave wavCurrent = $strWave
				if (WaveExists(wavCurrent))
					for (k=0;k<numTotalX;k+=1)
						wavMeasure[k][j] = wavCurrent[k]
					endfor
				endif
			endfor
			
			//Create 2D-Background Wave from Files.
			Duplicate/O wavPLEM BACKGROUND
			wave wavBackground	= BACKGROUND			
			//count background files
			numFiles	= PLEMd2d1CountFiles(gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg")
			for (j=0;j<numTotalY;j+=1)
				if (numFiles > 1)
					strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg_" + num2str(j)
				else
					//single background
					strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg_0"
				endif
				wave wavCurrent = $strWave
				if (WaveExists(wavCurrent))
					for (k=0;k<numTotalX;k+=1)
						wavBackground[k][j] = wavCurrent[k]
					endfor
				else
					//background file not found. Zero it out.
					for (k=0;k<numTotalX;k+=1)
						wavBackground[k][j] = 0
					endfor				
				endif
			endfor

			//Create Corrected Wave from Files.
			Duplicate/O wavPLEM CORRECTED
			wave wavBackground	= CORRECTED
			
			for (j=0;j<numTotalY;j+=1)
				strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_corr_m_" + num2str(j)
				wave wavCurrent = $strWave
				if (WaveExists(wavCurrent))
					for (k=0;k<numTotalX;k+=1)
						wavBackground[k][j] = wavCurrent[k]
					endfor
				endif
			endfor			
		endif
		
		//Copy Wavelength Wave
		wave wavWavelength = $("root:wavelength_" + strMap)
		if (WaveExists(wavWavelength))
			Duplicate/O wavWavelength WAVELENGTH
			if (numKillWavesAfterwards == 1)
				Killwaves/Z wavWavelength
			endif			
		endif
		
		//Copy Power Wave
		wave wavPower = $("root:" + strMap + "_power")
		if (WaveExists(wavPower))
			Duplicate/O wavPower POWER
			if (numKillWavesAfterwards == 1)
				Killwaves/Z wavPower
			endif
		endif
		
		//Copy Photon Wave
		wave wavPhoton = $("root:" + strMap + "_photon")
		if (WaveExists(wavPhoton))
			Duplicate/O wavPhoton PHOTON
			if (numKillWavesAfterwards == 1)
				Killwaves/Z wavPhoton
			endif
		endif
		
		//Append Current Map to List of Maps
		PLEMd2AddMap(strMap)
		//Save stats.
		PLEMd2statsCalculate(stats)
		PLEMd2statsSave(stats)
	endfor
	PLEMd2exit()
End

Function PLEMd2AddMap(strMap)
	String strMap

	String strSaveDataFolder = GetDataFolder(1)		
	SetDataFolder root:
	SVAR gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsAvailable	
	NVAR gnumMapsAvailable

	Variable numFind

	numFind = FindListItem(strMap,gstrMapsAvailable)
	if (numFind == -1)
		gstrMapsAvailable += strMap + ";"
		numFind = ItemsInList(gstrMapsAvailable)
		gnumMapsAvailable = numFind
	else
		gnumMapsAvailable = ItemsInList(gstrMapsAvailable)
	endif
	
	
	SetDataFolder $strSaveDataFolder	
	return numFind
End

Function PLEMd2KillMap(strMap)
	String strMap

	String strSaveDataFolder = GetDataFolder(1)		
	SetDataFolder root:
	SVAR gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsAvailable	
	NVAR gnumMapsAvailable
	
	String strKillDataFolder = gstrPLEMd2root + strMap

	if (FindListItem(strMap, gstrMapsAvailable) != -1)
		gstrMapsAvailable = RemoveFromList(strMap, gstrMapsAvailable)
		gnumMapsAvailable = ItemsInList(gstrMapsAvailable)
	endif
	If (DataFolderExists(strKillDataFolder))	
		KillDataFolder/Z $strKillDataFolder
		if (V_flag != 0)
			// don't care if Folder could not be killed. Items might be in use.
			print "PLEMd2KillMap: DataFolder could not be deleted."
		endif
		
	endif

	SetDataFolder $strSaveDataFolder	
End

Function PLEMd2KillMapByNum(numPLEM)
	Variable numPLEM
	if (numPLEM < 0)
		print "PLEMd2KillMapByNum: Wrong Function Call numPLEM out of range"
		return 0
	endif	
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	PLEMd2KillMap(strPLEM)
End

Function PLEMd2MapExists(strMap)
	String strMap

	String strSaveDataFolder = GetDataFolder(1)		
	SetDataFolder root:
	SVAR gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsAvailable	
	NVAR gnumMapsAvailable

	Variable numReturn = 0
	
	if (FindListItem(strMap,gstrMapsAvailable) != -1)
		numReturn = 1
	endif

	SetDataFolder $strSaveDataFolder	
	
	return numReturn
End

Function PLEMd2MapStringReInit()
	String strSaveDataFolder = GetDataFolder(1)		
	SetDataFolder root:
	SVAR gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsFolder
	SVAR gstrMapsAvailable	
	NVAR gnumMapsAvailable

	Variable i, numMapsAvailable
	String strMap
	gstrMapsAvailable 	= ""
	gnumMapsAvailable 	= 0
	numMapsAvailable = CountObjects(gstrMapsFolder, 4) // number of data folders
	
	for (i=0;i<numMapsAvailable;i+=1)
		strMap = GetIndexedObjName(gstrMapsFolder,4,i)
		gstrMapsAvailable += strMap + ";"
	endfor
	gnumMapsAvailable = ItemsInList(gstrMapsAvailable)	
	SetDataFolder $strSaveDataFolder	
End

Function PLEMd2d1Kill(strWhichOne)
	String strWhichOne
	PLEMd2Init()

	SVAR gstrPLEMd1root
	SetDataFolder $gstrPLEMd1root
	SVAR gstrPLEMd1strings, gstrPLEMd1variables, gstrPLEMd1waves
	String strStringsAvailable, strVariablesAvailable, strWavesAvailable
	
	Variable numKillme
	String strListKillMe, strKillMe
	Variable numAvailable
	String strListAvailable, strAvailable
	
	Variable numCount, i
	Variable numWhichOne

	strswitch(strWhichOne)
		case "waves":
			numWhichOne= 3
			break
		case "variables":
			numWhichOne= 2
			break
		case "strings":
			numWhichOne= 1
			break			
		default:
			numWhichOne= 0
		break
	endswitch

	SetDataFolder root:
	strWavesAvailable = WaveList("*",";","")
	strVariablesAvailable = VariableList("!gnum*",";",4)		
	strStringsAvailable = StringList("!gstr*",";")
	switch(numWhichOne)
		case 3:
			strListKillMe = gstrPLEMd1waves
			strListAvailable = strWavesAvailable
			break
		case 2:
			strListKillMe = gstrPLEMd1variables
			strListAvailable = strVariablesAvailable
			break
		case 1:
			strListKillMe = gstrPLEMd1strings
			strListAvailable = strStringsAvailable
			break			
		default:
			strListKillMe = gstrPLEMd1waves + gstrPLEMd1variables + gstrPLEMd1strings
			strListAvailable = gstrPLEMd1waves + strVariablesAvailable + strStringsAvailable
		break
	endswitch
	
	numAvailable = ItemsInList(strListAvailable)
	numKillme = ItemsInList(strListKillMe)
	numCount = 0
	for (i=0;i<numAvailable;i+=1)
		strAvailable = StringFromList(i, strListAvailable)
		if (FindListItem(strAvailable, strListKillMe) != -1)
			switch(numWhichOne)
				case 3:
					Killwaves/Z $("root:"+strAvailable)
					break
				case 2:
					Killvariables/Z $("root:"+strAvailable)
					break
				case 1:
					Killstrings/Z $("root:"+strAvailable)
					break			
				default:
					//we don't know what type it was so we kill every type. We have strong cpus!
					if (WaveExists($("root:"+strAvailable)))
						Killwaves/Z $("root:"+strAvailable)
					endif
					if (FindListItem(strAvailable, strVariablesAvailable) != -1)
						Killvariables/Z $("root:"+strAvailable)					
					endif
					if (FindListItem(strAvailable, strStringsAvailable) != -1)
						Killstrings/Z $("root:"+strAvailable)
					endif					
					break
			endswitch
			numCount +=1
		endif
	endfor
	print "PLEMd2d1Kill: deleted " + strWhichOne + ": " + num2str(numCount) + " "
	PLEMd2exit()
End

Function/S PLEMd2d1Find()
	String strSaveDataFolder = GetDataFolder(1)	
	
	String strWaves, strPLEMd1
	String strWave, strTestString
	Variable numIndex
	Variable numStrLen

	SetDataFolder root:
	strWaves 	= WaveList("PLE_map_*",";","")
	strPLEMd1 	= ""
	//loop adopted from igor manual. though <<for>> loops are normally prefered.
	do
		strWave = StringFromList(numIndex, strWaves)
		numStrLen = strlen(strWave)
		//break condition
		if (numStrLen == 0)
			break
		endif
		strTestString = strWave[8,numStrLen-1]
		if (WaveExists($("root:"+"PLE_map_"+strTestString)))
			strPLEMd1 = strTestString + ";"
		endif			
		numIndex += 1
	while (1)
	SetDataFolder $strSaveDataFolder	
	return strPLEMd1
End

Function PLEMd2d1CountFiles(strBaseName)
	String strBaseName
	Variable numIndex = 0
	do
		if (WaveExists($(strBaseName + "_" + num2str(numIndex))) == 0)
			break
		endif
		numIndex += 1		
	while (1)
	return numIndex
End

Function PLEMd2d1isInit()
	//directory persistent: function does not switch the current directory.
	if (PLEMd2isInit() == 0)
		return 0
	else
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SVAR gstrPLEMd1root = $(gstrPLEMd2root + ":gstrPLEMd1root")
		NVAR gnumPLEMd1IsInit = $(gstrPLEMd1root + ":gnumPLEMd1IsInit")
		return gnumPLEMd1IsInit
	endif
End

Function PLEMd2d1reset()
	//directory persistent: function does not switch the current directory.
	print "PLEMd2d1reset: reset in progress"
	If (PLEMd2d1isInit() == 1)
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SVAR gstrPLEMd1root = $(gstrPLEMd2root + ":gstrPLEMd1root")
		NVAR gnumPLEMd1IsInit = $(gstrPLEMd1root + ":gnumPLEMd1IsInit")
		gnumPLEMd1IsInit = 0
	endif
	PLEMd2d1Init()
	print "PLEMd2d1reset: reset ended"
End

Function PLEMd2d1Init() 
	//directory persistent: function restores current dir on exit.
	
	//check if Init() is necessary. And if the global variables are relibably there.
	If (PLEMd2d1isInit() == 0)
		//switch to current working dir. Keep old directory in memory.
		String strSaveDataFolder = GetDataFolder(1)
 		
 		//GLOBAL VARS
 		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SVAR gstrPLEMd1root = $(gstrPLEMd2root + ":gstrPLEMd1root")
		SetDataFolder $gstrPLEMd1root
		SVAR gstrPLEMd1CorrectionToLoad, gstrPLEMd1CorrectionAvailable, gstrPLEMd1PathBase
		NVAR gnumPLEMd1IsInit
		
		//LOCAL VARS
		String strPLEMd1CorrectionWaves, strPLEMd1CorrectionWave
		String strFiles, strFile
		String strFilesLoaded
		Variable numPLEMd1CorrectionWaves, numFiles
		Variable i
	
		GetFileFolderInfo/Q/Z=1 gstrPLEMd1PathBase
		if (V_flag != 0)
			print "PLEMd2d1Init: Error loading correction waves from " + gstrPLEMd1PathBase
			gnumPLEMd1IsInit = 1 // do not try again.
			SetDataFolder $strSaveDataFolder
			return 0
		endif
				
		NewPath/O/Q path, gstrPLEMd1PathBase
		strFiles = IndexedFile(path,-1,".txt")
		numFiles = ItemsInList(strFiles)
		//print "PLEMd2d1Init: found " + num2str(numFiles) + " files"
		numPLEMd1CorrectionWaves = ItemsInList(gstrPLEMd1CorrectionToLoad)

		//if there were no waves specified, load all Files from the current directory.		
		if (numPLEMd1CorrectionWaves == 0)
			numPLEMd1CorrectionWaves 	= numFiles
			strPLEMd1CorrectionWave 	= strFiles
		else
			strPLEMd1CorrectionWaves	 = gstrPLEMd1CorrectionToLoad
		endif

		gstrPLEMd1CorrectionAvailable = ""
		strFilesLoaded = ""
		for (i=0;i<numFiles;i+=1)
			strFile = StringFromList(i, strFiles)
			if (FindListItem(strFile, strPLEMd1CorrectionWaves) != -1)
				LoadWave/P=path/O/J/D/W/A/K=0/Q (strFile)
					//P	Path Variable
					//O	Overwrite existing waves in case of a name conflict.
					//J	Indicates that the file uses the delimited text format.
					//D	Creates double precision waves.
					//A	"Auto-name and go" (used with subsequent W)
					//W	Looks for wave names in file
					//K=k	Controls how to determine whether a column in the file is numeric or text (only for delimited text and fixed field text files).
					//	k = 0:	Deduce the nature of the column automatically.
					///Q	Suppresses the normal messages in the history area.

					//LoadWave sets the following variables:
					//V_flag		Number of waves loaded.
					//S_fileName	Name of the file being loaded.
					//S_path		File system path to the folder containing the file.
					//S_waveNames	Semicolon-separated list of the names of loaded waves.
					
					if (V_flag > 0)
						gstrPLEMd1CorrectionAvailable += S_waveNames
						strFilesLoaded += S_fileName + ";"
					endif
			endif			
		endfor
		print "PLEMd2d1Init: Loaded " + num2str(ItemsInList(strFilesLoaded)) + "/"+ num2str(ItemsInList(gstrPLEMd1CorrectionToLoad)) + " files from " + gstrPLEMd1PathBase
		print "PLEMd2d1Init: Loaded " + num2str(ItemsInList(gstrPLEMd1CorrectionAvailable)) + " waves (x and y) "		
		gnumPLEMd1IsInit = 1
		SetDataFolder $strSaveDataFolder
	endif
End

Function/S PLEMd2d1CorrectionWave(strWave)
	//WAVES:wavelength_chroma_abs,transmission_chroma_abs,wavelength_chroma_em,transmission_chroma_em,WL_500_CCD_minus90,E_500_CCD_minus90,WL_1250_CCD_minus90,E_1250_CCD_minus90,WL_1200_CCD_plus20,E_1200_CCD_plus20,WL_1200_InGaAs_minus25,E_1200_InGaAs_minus25,WL_1200_InGaAs_minus90,E_1200_InGaAs_minus90,WL_1200_CCD_minus90,E_1200_CCD_minus90,WL_1200_InGaAs_plus25,E_1200_InGaAs_plus25,WL_1250_InGaAs_minus90,E_1250_InGaAs_minus90,WL_500_CCD_plus20,E_500_CCD_plus20;
	String strWave
	String strSaveDataFolder = GetDataFolder(1)

	if (PLEMd2d1Init() == 0)
		print "PLEMd2d1CorrectionWave: Initialization Failure"
	endif
	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SVAR gstrPLEMd1root = $(gstrPLEMd2root + ":gstrPLEMd1root")
	SetDataFolder $gstrPLEMd1root
	SVAR gstrPLEMd1CorrectionAvailable

	String strReturn = ""
	
	strReturn = gstrPLEMd1root + ":" + strWave
	
	SetDataFolder $strSaveDataFolder
	
	if (WaveExists($strReturn))
		wave wavReturn = $strReturn
		return GetWavesDataFolder(wavReturn, 2)
	else
		//Too much noise in command prompt if every wave would be displayed
		//print "PLEMd2d1CorrectionWave: correction (" + strWave +") not found in gstrPLEMd1CorrectionAvailable"
		return ""
	endif
End

Function/S PLEMd2d1CorrectionConstructor(intGrating, intDetector, intTemperature)
	Variable intGrating, intTemperature, intDetector
	
	String strDetector = ""
	//Grating:
	//1 = 500nm Blaze
	//2 = 800nm Blaze
	//3 = 1250nm Blaze
	if (intGrating == 1)
		intGrating = 500
	elseif (intGrating == 2)
		intGrating = 800
	elseif (intGrating == 3)
		intGrating = 1250
	else
		print "PLEMd2d1CorrectionConstructor: Grating not found"
		intGrating = 0
	endif
	//Filter:
	//1 = Langpass 320nm
	//2 = Langpass 475nm
	//3 = Langpass 715nm
	//4 = Langpass 900nm
	//5 = Leer
	print "PLEMd2d1CorrectionConstructor: Filter not handled"
	//Detektor:
	//0 = CCD
	//1 = InGaAs	
	if (intDetector == 0)
		strDetector = "CCD"
	elseif (intDetector == 1)
		strDetector = "InGaAs"
	else
		print "PLEMd2d1CorrectionConstructor: Detector not found"
		strDetector = ""
	endif

	String strReturn = ""
	String strConstructor = ""
	String strX, strY
	Variable lenReturn = 0
	Variable intTemperatureNear = 0
	Variable intTemperatureRange = 0
	String strConstructorNear = ""
	
	strConstructor = num2str(intGrating) + "_" + strDetector + "_"
	intTemperature = floor(intTemperature/10)*10
	intTemperatureRange = 0
	strConstructorNear = strConstructor
	do
		intTemperatureNear = (intTemperature + intTemperatureRange)
		if ((intTemperatureNear < -273) || (intTemperatureNear > 100))
			lenReturn = 0
		else

			if (intTemperatureNear<0)
				strConstructorNear = strConstructor + "minus"
			elseif  (intTemperatureNear>0)
				strConstructorNear = strConstructor + "plus"
			else
				strConstructorNear = strConstructor
			endif
			strConstructorNear += num2str(abs(intTemperatureNear))
			strReturn = PLEMd2d1CorrectionWave("WL_" + strConstructorNear)
			lenReturn = strlen(strReturn)
		endif
		if ((lenReturn == 0) && (intTemperatureRange > 0))
			intTemperatureNear = (intTemperature - intTemperatureRange)
			if ((intTemperatureNear < -273) || (intTemperatureNear > 100))
				lenReturn = 0
			else
				if (intTemperatureNear<0)
					strConstructorNear = strConstructor + "minus"
				elseif  (intTemperatureNear>0)
					strConstructorNear = strConstructor + "plus"
				else
					strConstructorNear = strConstructor
				endif
				strConstructorNear += num2str(abs(intTemperatureNear))
				strReturn = PLEMd2d1CorrectionWave("WL_" + strConstructorNear)
				lenReturn = strlen(strReturn)
			endif
		endif
		if ( ((((intTemperature - intTemperatureRange) < -273) || ((intTemperature - intTemperatureRange) > 100))) && ((((intTemperature + intTemperatureRange) < -273) || ((intTemperature + intTemperatureRange) > 100))) )
			print "PLEMd2d1CorrectionConstructor: Correction Wave not found for Grating: " + num2str(intGrating) + ", Detector: " + num2str(intDetector) + ", Temperature: " + num2str(intTemperature)
			return ""
		endif

		if (lenReturn == 0)
			intTemperatureRange = intTemperatureRange + 5
		else
			break
		endif
	while (lenReturn == 0)	
	strConstructor = strConstructorNear
	print "PLEMd2d1CorrectionConstructor: Correction Wave used: " + strConstructor
	
	strX = PLEMd2d1CorrectionWave("WL_" + strConstructor)
	strY =  PLEMd2d1CorrectionWave("E_" + strConstructor)
	if ((WaveExists($strX)) && (WaveExists($strY)))
		return (GetWavesDataFolder($strX,1) + "DUMMY" + strConstructor)
	else
		return ""
	endif

End



//Helper Function

Function/S PLEMd2SetWaveScale(wavX, wavY, strOut)
	Wave wavX, wavY
	String strOut
	Variable numSize, numOffset, numDelta
	if (!waveExists(wavX) && !waveExists(wavY))
		print "Error: Waves Do not exist or user cancelled at Prompt"
		return ""		
	endif
	
	if (!WaveExists($strOut))
		Duplicate/O wavY $strOut
	else
		if (!StringMatch(GetWavesDataFolder(wavY, 2),GetWavesDataFolder($strOut, 2)))
			Duplicate/O wavY $strOut		
		endif
	endif
	wave wavOut = $strOut
	

	numSize		= DimSize(wavX,0)
	numOffset	= wavX[0]
	numDelta 	= (wavX[(numSize-1)] - wavX[0]) / (numSize-1)
	
	SetScale/P x, numOffset, numDelta, "", wavOut
	SetScale/P y, 1, 1, "", wavOut

	return GetWavesDataFolder(wavOut, 2)
End

//Function sorts two Numbers
Function PLEMd2sort(left, right)
Variable &left,&right
	if (left>right)
		Variable temp=left
		left=right
		right=temp
		temp=0
	endif
End

//Get number of map. in Menu-List.
Function PLEMd2numPLEM(strPLEM)
	String strPLEM

	String strSaveDataFolder = GetDataFolder(1)

	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsAvailable	

	Variable numFound
	numFound = FindListItem(strPLEM, gstrMapsAvailable)	
	
	SetDataFolder $strSaveDataFolder
	return numFound
End

Function/S PLEMd2strPLEM(numPLEM)
	Variable numPLEM
	
	String strSaveDataFolder = GetDataFolder(1)	
	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsAvailable, gstrMapsFolder
	
	String strMap = StringFromList(numPLEM, gstrMapsAvailable)

	SetDataFolder $strSaveDataFolder	
	return strMap
End

Function PLEMd2DisplayByNum(numPLEM)
	Variable numPLEM
	if (numPLEM < 0)
		print "PLEMd2DisplayByNum: Wrong Function Call numPLEM out of range"
		return 0
	endif	
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	PLEMd2Display(strPLEM)
End

Function PLEMd2Display(strPLEM)
	String strPLEM
	
	Struct PLEMd2Stats stats
	String winPLEM	
	PLEMd2statsLoad(stats, strPLEM)
	
	// check if spectrum is a valid input
	if ((strlen(stats.strPLEMfull)==0) || (strlen(stats.strPLEM)==0))
		print "PLEMd2Display: Error stats.strPLEMfull not set for Map: " + strPLEM + " check code"
		return 0
	endif
	if (WaveExists($(stats.strPLEMfull)) == 0)
		print "PLEMd2Display: Wave Not Found"
		return 0
	endif	
	
	// check if window already exists
	winPLEM = "win_" + stats.strPLEM
	DoWindow/F $winPLEM
	// DoWindow sets the variable V_flag: 
	// 	1 window existed
	// 	0 no such window
	// 	2 window is hidden. 	
	if (V_flag == 1)
		//print "PLEMd2Display: Graph already exists" //verbosity problem on atlas show
		return 0
	elseif (V_flag == 2)
		print "PLEMd2Display: Graph was hidden. Case not handled. check code"
	elseif (V_flag == 0)
		Display
		DoWindow/C/N/R $winPLEM
		if (stats.numCalibrationMode == 1)
			AppendToGraph $(stats.strPLEMfull)		
			ModifyGraph/W=$winPLEM standoff=0
			SetAxis/W=$winPLEM/A left
			Label/W=$winPLEM left "intensity / a.u."
			Label/W=$winPLEM bottom "wavelength / nm (Excitation at "+num2str(stats.numEmissionStart)+"-"+num2str(stats.numEmissionEnd)+")"
		else
			AppendImage $stats.strPLEMfull
			PLEMd2Decorate(strWinPLEM = winPLEM)
		endif
		PLEMd2Panel(strWinPLEM = winPLEM)
		PLEMd2PanelAtlas(strWinPLEM = winPLEM)
	endif
End

Function PLEMd2Decorate([strWinPLEM])
	String strWinPLEM	
	Variable numZmin, numZmax
	Variable numXmin, numXmax
	Variable numYmin, numYmax
	String strImages
	
	// if no argument was selected, take top graph window
	if (ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if (strlen(strWinPLEM) == 0)
		Print "PLEMd2Decorate: No window to append to"
		return 0
	endif	
	
	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEM, ";")
	if (ItemsInList(strImages) != 1)
		Print "PLEMd2Decorate: No Image found in top graph or More than one Image present"
	endif
	wave wavImage = ImageNameToWaveRef(strWinPLEM,StringFromList(0,strImages))
	
	// get min and max of wave (statistically corrected)
	WaveStats/Q/W wavImage	
	wave M_WaveStats
	numZmin = M_WaveStats[10]	//minimum
	numZmin = M_WaveStats[3]-sign(M_WaveStats[3])*2*M_WaveStats[4] //statistical minimum
	if (numZmin<0)
		numZmin = 0
	endif
	numZmax = M_WaveStats[12]	//maximum
	//Images start a little earlier as the minimum due to the quadratic size of a pixel.
	numYmin 	= DimOffset(wavImage,1) + sign(DimOffset(wavImage,1)) * (-1) * DimDelta(wavImage,1)/2
	numYmax 	= DimOffset(wavImage,1) + DimDelta(wavImage,1)*(DimSize(wavImage,1)-1) + sign(DimOffset(wavImage,1)) * (+1) * DimDelta(wavImage,1)/2
	numXmin 	= DimOffset(wavImage,0) + sign(DimOffset(wavImage,0)) * (-1) * DimDelta(wavImage,0)/2
	numXmax 	= DimOffset(wavImage,0) + DimDelta(wavImage,0)*(DimSize(wavImage,0)-1) + sign(DimOffset(wavImage,0)) * (+1) * DimDelta(wavImage,0)/2
	Killwaves/Z M_Wavestats
	
	ModifyImage/W=$strWinPLEM ''#0 ctab= {numZmin,numZmax,Terrain256,0}
	ModifyGraph/W=$strWinPLEM standoff=0, height={Aspect,((numYmax-numYmin)/(numXmax-numXmin))}
	SetAxis/W=$strWinPLEM left,numYmin, numYmax
	SetAxis/W=$strWinPLEM bottom,numXmin,numXmax
	Label/W=$strWinPLEM left "center of excitation / nm"
	Label/W=$strWinPLEM bottom "emission / nm"				
End

Function PLEMd2ShowNote([strWinPLEM])
	String strWinPLEM
	String strWinPLEMbase
	String strImages, strTraces, strDataFolderMap, strDataFolderInfo
	// if no argument was selected, take top graph window
	if (ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if (strlen(strWinPLEM) == 0)
		Print "PLEMd2ShowNote: base window not found"
		return 0
	endif
	// take parent window
	strWinPLEMbase = strWinPLEM[0,(strsearch(strWinPLEM, "#",0)-1)]
	
	// if the panel is already shown, do nothing
	DoUpdate /W=$strWinPLEMbase#PLEMd2WaveNote
	if (V_flag != 0)
		Print "PLEMd2ShowNote: Panel already exists."
		return 0
	endif	

	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEMbase, ";")
	if (ItemsInList(strImages) != 1)
		Print "PLEMd2ShowNote: Image not found."
		return 0
	else	
		wave wavPLEM = ImageNameToWaveRef(strWinPLEMbase,StringFromList(0,strImages))	
	endif 
	String strWavenote = note(wavPLEM)
	NewPanel /N=PLEMd2WaveNote/W=(0,0,300,400) /EXT=0 /HOST=$strWinPLEMbase
	NewNotebook/F=0 /N=Note /W=(0,0,300,400) /HOST=$(strWinPLEMbase + "#PLEMd2WaveNote") as ("wavenote " + GetWavesDataFolder(wavPLEM,2))
	Notebook # text=strWavenote
	//TitleBox/Z gstrPLEMfull	title=strWavenote,	pos={10,10}, size={50,50}, frame=0, font="Helvetica"
End

Function PLEMd2Panel([strWinPLEM])
	String strWinPLEM
	String strImages, strTraces, strDataFolderMap, strDataFolderInfo
	// if no argument was selected, take top graph window
	if (ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if (strlen(strWinPLEM) == 0)
		Print "PLEMd2Panel: No window to append to"
		return 0
	endif	
	
	// if the panel is already shown, do nothing
	DoUpdate /W=$strWinPLEM#PLEMd2Panel
	if (V_flag != 0)
		Print "PLEMd2Panel: Panel already exists."
		return 0
	endif	

	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEM, ";")
	if (ItemsInList(strImages) == 0)
		strTraces = TraceNameList(strWinPLEM, ";",1)
		if (ItemsInList(strTraces) == 1)
			wave wavPLEM = TraceNameToWaveRef(strWinPLEM,StringFromList(0,strTraces))	
		else
			Print "PLEMd2Panel: No Image found. More than one or no trace found in top graph."
			return 0
		endif
	elseif (ItemsInList(strImages) > 1)
		Print "PLEMd2Panel: More than one image found in top graph."
		return 0
	else	
		wave wavPLEM = ImageNameToWaveRef(strWinPLEM,StringFromList(0,strImages))	
	endif
	// check for INFO folder
	strDataFolderMap = GetWavesDataFolder(wavPLEM,1)
	strDataFolderInfo = strDataFolderMap + "INFO:"
	if (DataFolderExists(strDataFolderInfo) == 0)
		Print "PLEMd2Panel: INFO Data Folder for Image in top graph not found."
		return 0
	endif
	NewPanel /N=PLEMd2Panel/W=(0,0,300,250) /EXT=0 /HOST=$strWinPLEM
	TitleBox/Z gstrPLEMfull	variable=$(strDataFolderInfo + "gstrPLEMfull"), pos={0,0}, 	size={130,0}, disable=0, frame=0, font="Helvetica"
	SetVariable gnumNormalization,			value=$(strDataFolderInfo + "gnumNormalization"),		pos={10,30}, 	size={130,0}
	SetVariable gnumBackground,			value=$(strDataFolderInfo + "gnumBackground"),			pos={10,50}, 	size={130,0}	
	SetVariable gnumGrating,				value=$(strDataFolderInfo + "gnumGrating"),				pos={10,70}, 	size={130,0}
	SetVariable gnumFilter,				value=$(strDataFolderInfo + "gnumFilter"),				pos={10,90}, 	size={130,0}	
	SetVariable gnumDetector,				value=$(strDataFolderInfo + "gnumDetector"),			pos={10,110}, 	size={130,0}
	SetVariable gnumCooling,				value=$(strDataFolderInfo + "gnumCooling"),				pos={10,130}, 	size={130,0}	
	SetVariable gnumScans,				value=$(strDataFolderInfo + "gnumScans"),				pos={10,150}, 	size={130,0}
	SetVariable gnumEmissionPower,		value=$(strDataFolderInfo + "gnumEmissionPower"),		pos={10,170}, 	size={130,0}	
	SetVariable gnumEmissionDelta,		value=$(strDataFolderInfo + "gnumEmissionDelta"),		pos={10,190}, 	size={130,0}
	SetVariable gnumEmissionStep,		value=$(strDataFolderInfo + "gnumEmissionStep"),		pos={10,210}, 	size={130,0}
	CheckBox gbooBackground 		variable=$(strDataFolderInfo + "gbooBackground"), 		pos={150,60}, title="background"
	CheckBox gbooPower 			variable=$(strDataFolderInfo + "gbooPower"), 			pos={150,80}, title="power"
	CheckBox gbooPhoton				variable=$(strDataFolderInfo + "gbooPhoton"), 			pos={150,100}, title="photon"
	CheckBox gbooGrating 			variable=$(strDataFolderInfo + "gbooGrating"), 			pos={150,120}, title="grating"
	CheckBox gbooQuantumEfficiency	variable=$(strDataFolderInfo + "gbooQuantumEfficiency"), 	pos={150,140}, title="detector"
	CheckBox gbooFilter				variable=$(strDataFolderInfo + "gbooFilter"), 				pos={150,160}, title="filter"
	Button ProcessIBW, pos={150, 30}, size={130,30}, proc=ButtonProcProcessIBW,title="Re-Process IBW"
	Button BuildMaps, pos={150, 180}, size={130,30}, proc=ButtonProcBuildMaps,title="Re-Build Map"
	Button ShowNote, pos={150, 210}, size={130,30}, proc=ButtonProcShowNote,title="WaveNote"	
	// deactivated
	//TitleBox/Z gstrDate		variable=$(strDataFolderInfo + "gstrDate"), 							pos={10,30}, 	size={130,0}, disable=0, frame=0, font="Helvetica"
	//TitleBox/Z gstrUser		variable=$(strDataFolderInfo + "gstrUser"), 							pos={10,50}, 	size={130,0}, disable=0, frame=0, font="Helvetica"
	//TitleBox/Z gstrFileName	variable=$(strDataFolderInfo + "gstrFileName"), 						pos={10,70}, 	size={130,0}, disable=0, frame=0, font="Helvetica"
	//SetVariable gnumSlit,				value=$(strDataFolderInfo + "gnumSlit"),					pos={10,110}, 	size={130,0}
	//SetVariable gnumShutter,				value=$(strDataFolderInfo + "gnumShutter"),				pos={10,170}, 	size={130,0}
	//SetVariable gnumWLcenter,			value=$(strDataFolderInfo + "gnumWLcenter"),			pos={10,190}, 	size={130,0}
	//SetVariable gnumExposure,			value=$(strDataFolderInfo + "gnumExposure"),			pos={10,250}, 	size={130,0}
	//SetVariable gnumBinning,				value=$(strDataFolderInfo + "gnumBinning"),				pos={10,270}, 	size={130,0}
	//SetVariable gnumEmissionStart,		value=$(strDataFolderInfo + "gnumEmissionStart"),		pos={150,150}, 	size={130,0}
	//SetVariable gnumEmissionEnd,			value=$(strDataFolderInfo + "gnumEmissionEnd"),			pos={150,170}, 	size={130,0}
	// available
	//gnumPLEM;gnumVersion;gstrPLEM;gstrPLEMfull;gstrDataFolder;gstrDataFolderOriginal;gstrDate;gstrUser;gstrFileName;
	//gnumPLEMTotalX;gnumPLEMLeftX;gnumPLEMDeltaX;gnumPLEMRightX;gnumPLEMTotalY;gnumPLEMBottomY;gnumPLEMDeltaY;gnumPLEMTopY;gnumCalibrationMode;
	//gnumBackground; gnumSlit;gnumGrating;gnumFilter;
	//gnumShutter;gnumWLcenter;gnumDetector;gnumCooling;gnumExposure;gnumBinning;gnumScans;gnumWLfirst;gnumWLlast;gnumWLdelta;
	//gnumEmissionMode;gnumEmissionPower;gnumEmissionStart;gnumEmissionEnd;gnumEmissionDelta;gnumEmissionStep;
	DoWindow PLEMd2Panel
End

Function PLEMd2PanelAtlas([strWinPLEM])
	String strWinPLEM
	String strImages, strTraces, strDataFolderMap, strDataFolderInfo
	// if no argument was selected, take top graph window
	if (ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if (strlen(strWinPLEM) == 0)
		Print "PLEMd2Atlas: No window to append to"
		return 0
	endif	
	
	// if the panel is already shown, do nothing
	DoUpdate /W=$strWinPLEM#PLEMd2PanelAtlas
	if (V_flag != 0)
		Print "PLEMd2Atlas: Panel already exists."
		return 0
	endif	

	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEM, ";")
	if (ItemsInList(strImages) == 0)
		strTraces = TraceNameList(strWinPLEM, ";",1)
		if (ItemsInList(strTraces) == 1)
			wave wavPLEM = TraceNameToWaveRef(strWinPLEM,StringFromList(0,strTraces))	
			Print "PLEMd2Atlas: Traces not yet handled"
			return 0
		else
			Print "PLEMd2Atlas: No Image found. More than one or no trace found in top graph."
			return 0
		endif
	elseif (ItemsInList(strImages) > 1)
		Print "PLEMd2Atlas: More than one image found in top graph."
		return 0
	else	
		wave wavPLEM = ImageNameToWaveRef(strWinPLEM,StringFromList(0,strImages))	
	endif
	// check for INFO folder
	strDataFolderMap = GetWavesDataFolder(wavPLEM,1)
	strDataFolderInfo = strDataFolderMap + "INFO:"
	if (DataFolderExists(strDataFolderInfo) == 0)
		Print "PLEMd2Panel: INFO Data Folder for Image in top graph not found."
		return 0
	endif
	NewPanel /N=PLEMd2PanelAtlas/W=(0,0,300,100) /EXT=2 /HOST=$strWinPLEM
	SetVariable 	gnumS1offset,	proc=VariableProcAtlasRecalculate,	value=$(strDataFolderInfo + "gnumS1offset"),	pos={10,10}, 	size={130,0}
	SetVariable 	gnumS2offset,	proc=VariableProcAtlasRecalculate,	value=$(strDataFolderInfo + "gnumS2offset"),	pos={10,30}, 	size={130,0}
	Button 		AtlasReset,		proc=ButtonProcAtlasReset,	title="reset",			pos={10, 50},	size={50,25}
	Button 		AtlasShow,		proc=ButtonProcAtlasShow,	title="show",			pos={150, 10},	size={50,25}
	Button		AtlasHide,		proc=ButtonProcAtlasHide,		title="hide",			pos={150, 40},	size={50,25}
	Button		AtlasFit2D,		proc=ButtonProcAtlasFit2D,	title="fit2D",			pos={200, 10},	size={50,25}
	Button		AtlasFit1D,		proc=ButtonProcAtlasFit1D,	title="fit1D",			pos={200, 40},	size={50,25}
	Button		AtlasEdit,		proc=ButtonProcAtlasEdit,		title="edit",		pos={250, 10},	size={50,25}
	Button		AtlasClean,		proc=ButtonProcAtlasClean,	title="clean",		pos={250, 40},	size={50,25}
	//gnumPLEM;gnumVersion;gstrPLEM;gstrPLEMfull;gstrDataFolder;gstrDataFolderOriginal;gstrDate;gstrUser;gstrFileName;
	//gnumPLEMTotalX;gnumPLEMLeftX;gnumPLEMDeltaX;gnumPLEMRightX;gnumPLEMTotalY;gnumPLEMBottomY;gnumPLEMDeltaY;gnumPLEMTopY;gnumCalibrationMode;
	//gnumBackground; gnumSlit;gnumGrating;gnumFilter;
	//gnumShutter;gnumWLcenter;gnumDetector;gnumCooling;gnumExposure;gnumBinning;gnumScans;gnumWLfirst;gnumWLlast;gnumWLdelta;
	//gnumEmissionMode;gnumEmissionPower;gnumEmissionStart;gnumEmissionEnd;gnumEmissionDelta;gnumEmissionStep;
	DoWindow PLEMd2PanelAtlas
End

Function ButtonProcAtlasShow(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasShow(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function ButtonProcAtlasHide(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasHide(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function ButtonProcAtlasReset(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasInit(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function VariableProcAtlasRecalculate(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(sva.win)
			PLEMd2AtlasRecalculate(strPLEM)			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
Function ButtonProcAtlasFit2D(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasFit2D(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function ButtonProcAtlasFit1D(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasFit1D(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function ButtonProcAtlasEdit(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasEdit(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function ButtonProcAtlasClean(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasClean(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function ButtonProcProcessIBW(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2ProcessIBW(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
Function ButtonProcShowNote(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			//String strPLEM
			//strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2ShowNote(strWinPLEM=ba.win)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function ButtonProcBuildMaps(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2BuildMaps(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function/S PLEMd2window2strPLEM(strWindow)
	String strWindow
	Variable numStart, numEnd
	
	numEnd = strsearch(strWindow, "#",0)
	numStart = strsearch(strWindow, "win_", 0)
	return strWindow[numStart+4,numEnd-1]
End

