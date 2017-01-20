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
//Version 13: Added buggy power correction for all waves in Data Folder PLEMd2PowerCorrection and DataLoop
//Added Power Correction Wave, search for next correction wave which is available.
//hier weiterarbeiten. Interpolate
// Datei noch nicht endgültig als v13 gespeichert.



//			ToDo. Create Panel for Map-Updates
//			ToDo: Mapper for Global Vars in PLEMd2 Folder?
//			ToDo: Power Correction

#pragma rtGlobals=3		// Use modern global access method and strict wave access.

static Constant PLEMd2Version = 1302
static StrConstant PLEMd2PackageName = "PLEM-displayer2"
static StrConstant PLEMd2PrefsFileName = "PLEMd2Preferences.bin"
static StrConstant PLEMd2WorkingDir = "C:users:matthias:Meine Dokumente:Documents:programs:local:igor:matthias:PLEM-displayer2:"
static Constant PLEMd2PrefsRecordID = 0

Menu "PLE-Map", dynamic //create menu bar entry
//	SubMenu "Displayer1"
//		"Init", PLEMd2d1Init()	
//		"Open", PLEMd2d1Open()
//		"-"
//		"Open depricated", PLEMapDisplayer()
//		"Import: Maps", PLEMd2d1Import(0)
//		"-"
//		"Kill: Maps and Import", PLEMd2d1Import(1)	
//		"-"
//		"Kill: CorrectionWaves", PLEMd2d1Kill("waves")
//		"Kill: Variables", PLEMd2d1Kill("variables")
//		"Kill: Strings", PLEMd2d1Kill("strings")
//		"-"
//		"Kill: All", PLEMd2d1Kill("all")
//	End
//	SubMenu "Displayer2"
//		"Init", PLEMd2()
		"Open", PLEMd2open()
//		"Configuration", PLEMd2Panel()
//		"-"
//		"Clean up Variables", PLEMd2Clean()
//	End
	SubMenu "PLEMap"
	//List all available Maps in current project (max 15)
		PLEMd2Menu(0), PLEMd2DisplayByNum(0)
		PLEMd2Menu(1), PLEMd2DisplayByNum(1)
		PLEMd2Menu(2), PLEMd2DisplayByNum(2)
		PLEMd2Menu(3), PLEMd2DisplayByNum(3)
		PLEMd2Menu(4), PLEMd2DisplayByNum(4)		
		PLEMd2Menu(5), PLEMd2DisplayByNum(5)
		PLEMd2Menu(6), PLEMd2DisplayByNum(6)
		PLEMd2Menu(7), PLEMd2DisplayByNum(7)
		PLEMd2Menu(8), PLEMd2DisplayByNum(8)
		PLEMd2Menu(9), PLEMd2DisplayByNum(9)
		PLEMd2Menu(10), PLEMd2DisplayByNum(10)
		PLEMd2Menu(11), PLEMd2DisplayByNum(11)
		PLEMd2Menu(12), PLEMd2DisplayByNum(12)
		PLEMd2Menu(13), PLEMd2DisplayByNum(13)
		PLEMd2Menu(14), PLEMd2DisplayByNum(14)		
	End
	SubMenu "duplicate"
		PLEMd2Menu(0), PLEMd2DuplicateByNum(0)
		PLEMd2Menu(1), PLEMd2DuplicateByNum(1)
		PLEMd2Menu(2), PLEMd2DuplicateByNum(2)
		PLEMd2Menu(3), PLEMd2DuplicateByNum(3)
		PLEMd2Menu(4), PLEMd2DuplicateByNum(4)		
		PLEMd2Menu(5), PLEMd2DuplicateByNum(5)
		PLEMd2Menu(6), PLEMd2DuplicateByNum(6)
		PLEMd2Menu(7), PLEMd2DuplicateByNum(7)
		PLEMd2Menu(8), PLEMd2DuplicateByNum(8)
		PLEMd2Menu(9), PLEMd2DuplicateByNum(9)
		PLEMd2Menu(10), PLEMd2DuplicateByNum(10)
		PLEMd2Menu(11), PLEMd2DuplicateByNum(11)
		PLEMd2Menu(12), PLEMd2DuplicateByNum(12)
		PLEMd2Menu(13), PLEMd2DuplicateByNum(13)
		PLEMd2Menu(14), PLEMd2DuplicateByNum(14)		
	End	
	
	//SubMenu "Fixes"
//	SubMenu "FixWaveNotes"
	//List all available Maps in current project (max 15)
//		PLEMd2Menu(0), PLEMd2FixWavenotesByNum(0)
//		PLEMd2Menu(1), PLEMd2FixWavenotesByNum(1)
//		PLEMd2Menu(2), PLEMd2FixWavenotesByNum(2)
//		PLEMd2Menu(3), PLEMd2FixWavenotesByNum(3)
//		PLEMd2Menu(4), PLEMd2FixWavenotesByNum(4)		
//		PLEMd2Menu(5), PLEMd2FixWavenotesByNum(5)
//		PLEMd2Menu(6), PLEMd2FixWavenotesByNum(6)
//		PLEMd2Menu(7), PLEMd2FixWavenotesByNum(7)
//		PLEMd2Menu(8), PLEMd2FixWavenotesByNum(8)
//		PLEMd2Menu(9), PLEMd2FixWavenotesByNum(9)
//		PLEMd2Menu(10), PLEMd2FixWavenotesByNum(10)
//		PLEMd2Menu(11), PLEMd2FixWavenotesByNum(11)
//		PLEMd2Menu(12), PLEMd2FixWavenotesByNum(12)
//		PLEMd2Menu(13), PLEMd2FixWavenotesByNum(13)
//		PLEMd2Menu(14), PLEMd2FixWavenotesByNum(14)		
	//End
//	End
End

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

	//save current init-version in project folder.
	Variable/G gnumPLEMd2Version = PLEMd2Version
	//set a variable in root folder to recognize if the module was initialized.
	SetDataFolder root:
	Variable/G gnumPLEMd2IsInit = 1
	SetDataFolder $gstrPLEMd2root
End

Function/S PLEMd2Menu(numPLEM)
	//directory persistent
	Variable numPLEM
	String strReturn = ""

	//dynamic Menus are called every time the menu bar is pressed.
	//global Variables should not automatically occur in other projects. so don't create them.
	if (PLEMd2isInit())
		NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SVAR gstrMapsAvailable = $(gstrPLEMd2root + ":gstrMapsAvailable")
		NVAR gnumMapsAvailable	 = $(gstrPLEMd2root + ":gnumMapsAvailable")
	
		if (gnumPLEMd2IsInit == 1)
			if (numPLEM<gnumMapsAvailable)
				strReturn = StringFromList(numPLEM, gstrMapsAvailable)
			endif
		endif
	//no else needed. strReturn was declared initially. So fall back to that.	Try() - Except() Could be an option here.
	endif
	
	return strReturn
End

Function PLEMd2isInit()
	//numInit only chages if all the tests are ok.
	Variable numInit = 0
	String strGlobalVariables = ""
	String strSaveDataFolder = GetDataFolder(1)

	SetDataFolder root:

	if (FindListItem("gnumPLEMd2IsInit", VariableList("gnum*",";",4)) != -1)
		NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
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
	SVAR gstrSaveDataFolder	= strSaveDataFolder		
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
	
	numAvailable = PLEMd2GetListSize(strVariables)	
	for (i=0;i<numAvailable;i+=1)
		strAvailable = StringFromList(i, strVariables)		
		Killvariables/Z $("root:" + strAvailable)
	endfor
	
	numAvailable = PLEMd2GetListSize(strStrings)
	for (i=0;i<numAvailable;i+=1)
		strAvailable = StringFromList(i, strStrings)		
		Killstrings/Z $("root:" + strAvailable)
	endfor
	
	SetDataFolder $strSaveDataFolder	
End

Function PLEMd2Open()
	//INIT
	Struct PLEMd2Prefs prefs
	Struct PLEMd2Stats stats
	PLEMd2LoadPackagePrefs(prefs)
	PLEMd2init()
	SVAR gstrMapsFolder, gstrMapsAvailable
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

		strPLEM = ReplaceString(" ",strFileName,"")
		//ReplaceString(replaceThisStr, inStr, withThisStr  [, caseSense  [, maxReplace ] ])
		//The ReplaceString function returns inStr  after replacing any instance of replaceThisStr  with withThisStr.
		SetDataFolder $gstrMapsFolder
		if (DataFolderExists(strPLEM))
			print "PLEMd2Open: DataFolder already exists. Overwriting."
		endif
		NewDataFolder/O/S $strPLEM
		strDataFolder = GetDataFolder(1)
		print "PLEMd2Open: Using Data Folder " + strDataFolder
		strswitch(strFileType)
			case "ibw":	// literal string or string constant
				LoadWave/Q/A/N=temp strFile
				if (PLEMd2GetListSize(S_waveNames) == 1)
					strWave	= StringFromList(0, S_waveNames)
					numCurrentMap = PLEMd2AddMap(strPLEM)
					
					PLEMd2statsInitialize(strPLEM)
					PLEMd2statsLoad(stats, strPLEM)
					stats.numPLEM = numCurrentMap
					stats.strPLEM = strPLEM
					stats.strPath = strDataFolder
					PLEMd2statsSave(stats)
					
					SetDataFolder $strDataFolder
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
	PLEMd2ProcessIBW(stats.strPLEM) //currently only ibw files available
	//EXIT
	PLEMd2exit()
	PLEMd2SavePackagePrefs(prefs)
End

Function PLEMd2ProcessIBW(strPLEM)
	String strPLEM
	//INIT
	Struct PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)
	Struct PLEMd2Stats stats
	PLEMd2statsLoad(stats, strPLEM)
	
	String strDataFolder, strWave
	String strWaveNames, strWaveExtract
	Variable numTotalX, numTotalY, i, j

	strDataFolder = stats.strPath
	strWave = strDataFolder + "IBW"
	SetDataFolder $strDataFolder
	NewDataFolder/O/S ORIGINAL
	strDataFolder = GetDataFolder(1)
	wave wavIBW = $(strWave)
	if (WaveExists(wavIBW)==0)
		print "PLEMd2ProcessIBW: IBW Wave does not exist. Check Code."
	endif
	strWaveNames = PLEMd2ExtractWaveList(wavIBW)
	numTotalX	= DimSize(wavIBW,0)
	numTotalY	= DimSize(wavIBW,1)	
	if (numTotalY != ItemsInList(strWaveNames))
		print "PLEMd2ProcessIBW: Error WaveNames not found in WaveNotes. Trying to correct WaveNotes"
		print strWaveNames
		print num2str(numTotalY)
		PLEMd2FixWavenotes(strPLEM)
		strWaveNames = PLEMd2ExtractWaveList(wavIBW)
	endif	
	if (numTotalY == ItemsInList(strWaveNames))
		print "PLEMd2ProcessIBW: Binary File has " + num2str(numTotalY) + " waves"
		//Extract Columns from Binary Wave and give them proper names
		for (i=0; i<numTotalY; i+=1)
			strWaveExtract = StringFromList(i, strWaveNames)
			Make/D/O/N=(numTotalX) $strWaveExtract
			wave wavExtract = $strWaveExtract
			for (j=0; j<numTotalX; j+=1)
				wavExtract[j] = wavIBW[j][i]
			endfor
			wave wavExtract=$""
		endfor
		PLEMd2ExtractInfo(wavIBW, stats)
		String strPower = PLEMd2ExtractPower(wavIBW)
		Make/O/N=(ItemsInList(strPower, ";")) PW
		PW = str2num(StringFromList(p, strPower, ";"))
		PLEMd2statsSave(stats)
		PLEMd2BuildMaps(strPLEM)
		PLEMd2MapsAppendNotes(strPLEM, wavIBW)
		PLEMd2Display(stats.strPLEM)
	else
		print "PLEMd2ProcessIBW: Error WaveNames not found in WaveNotes. Check and correct manually Igor0,Igor1,Igor2,Igor3"
	endif
End

Function PLEMd2MapsAppendNotes(strPLEM, wavIBW)
	String strPLEM
	Wave wavIBW
	
	Struct PLEMd2stats stats
	String strHeader
	
	PLEMd2statsLoad(stats, strPLEM)
	
	strHeader = Note(wavIBW)
	Note/K/NOCR stats.wavPLEM strHeader
	Note/K/NOCR stats.wavMeasure strHeader
	Note/K/NOCR stats.wavBackground strHeader
	Note/K/NOCR stats.wavCorrected strHeader
	Note/K/NOCR stats.wavExcitation strHeader
	Note/K/NOCR stats.wavPower strHeader
	Note/K/NOCR stats.wavPhoton strHeader
	Note/K/NOCR stats.wavWavelength strHeader
End
strHeader = Note(wavIBW)

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

	String strDataFolderOriginal
	Variable i,j, numItems
	
	if (PLEMd2MapExists(strPLEM))
		//There are 3 different structures for DATA
		//1) WAVES: WL, BG, PL ...
		//2) WAVES: WL, BG_498_502, PL_498_502,BG_502_506,PL_502_506 ...
		//3) WAVES: WL, BG, PL_498_502,PL_502_506,PL_506_510,PL_510_514 ...
		PLEMd2statsLoad(stats, strPLEM)
		print "PLEMd2BuildMaps: Map found. Background is " + num2str(stats.numBackground)

		//Bedingungen:
		//1)+3) stats.strbackground = single --> wavexists(background)
		//2) stats. strBackground = multiple --> count(BG_*) = count (PL_*)
		
		SetDataFolder $(gstrMapsFolder + ":" + strPLEM + ":ORIGINAL:")
		
		wave wavBackground = BG
		if ((stats.numbackground == 1) && (WaveExists(wavBackground)))
			//correct obviously wrong background (LabView Error)
			//maybe check stats.numCalibrationMode
			print "PLEMd2BuildMaps: Error: Background was set wrong in LabView. Using single Background to proceed" + num2str(stats.numBackground)
			stats.numbackground = 0
			PLEMd2statsSave(stats)
		endif
		wave wavBackground = $("")
		
		switch(stats.numbackground)
			case 0: //single background
				wave wavBackground = BG
				if (WaveExists(wavBackground))					
					strWavePL = WaveList("PL*",";","") //must also match 1)condition
					numItems = ItemsInList(strWavePL, ";")
					strWaveBG = ""
					for (i=0; i<numItems; i+=1)
						strWaveBG += "BG;"
					endfor
				endif
				wave wavBackground = $("")
				break
			case 1: //multiple background
				strWaveBG = WaveList("BG_*",";","")
				strWavePL = WaveList("PL_*",";","")				
				break
			default:
				break
		endswitch
		wave wavWavelength = WL
		if (!WaveExists(wavWavelength))
			print "PLEMd2BuildMaps: Wavelength Wave not found within ORIGINAL Folder"
			return 0
		endif
		print "PLEMd2BuildMaps: Building Maps..."
		if (ItemsInList(strWaveBG, ";") != ItemsInList(strWavePL, ";"))
			print "PELMd2BuildMaps: Error Size Missmatch between Background Maps and PL Maps"
			return 0
		else
			stats.numPLEMTotalY = ItemsInList(strWavePL, ";")
		endif
		stats.strPLEM 	= strPLEM
		stats.strPath		= gstrMapsFolder + ":" + strPLEM + ":"
		
		strDataFolderOriginal 	= stats.strPath + "ORIGINAL:"
		stats.numPLEMTotalX = NumPnts($(StringFromList(0,strWaveBG)))
		
		SetDataFolder $(stats.strPath)
		if (stats.numPLEMTotalY==1)
			stats.numCalibrationMode = 1
			Make/D/O/N=(stats.numPLEMTotalX) PLEM
			Make/D/O/N=(stats.numPLEMTotalX) MEASURE
			Make/D/O/N=(stats.numPLEMTotalX) BACKGROUND
			Make/D/O/N=(stats.numPLEMTotalX) CORRECTED						
		else
			stats.numCalibrationMode = 0
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) PLEM
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) MEASURE
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) BACKGROUND
			Make/D/O/N=((stats.numPLEMTotalX),(stats.numPLEMTotalY)) CORRECTED			
		endif
		Make/D/O/N=(stats.numPLEMTotalX) WAVELENGTH
		Make/D/O/N=(stats.numPLEMTotalY) EXCITATION
		Make/D/O/N=(stats.numPLEMTotalY) POWER
		Make/D/O/N=(stats.numPLEMTotalY) PHOTON

		//reload wave references
		PLEMd2statsSave(stats)
		PLEMd2statsLoad(stats, strPLEM) 

		stats.numPLEMLeftX	= wavWavelength[0]
		stats.numPLEMRightX	= wavWavelength[(stats.numPLEMTotalX-1)]
		

		for (j=0; j<stats.numPLEMTotalX; j+=1)
			stats.wavWavelength[j] = wavWavelength[j]
			stats.numPLEMDeltaX += wavWavelength[j]
		endfor
		stats.numPLEMDeltaX	= 0
		for (j=0; j<(stats.numPLEMTotalX-1); j+=1)
			stats.numPLEMDeltaX += abs(wavWavelength[j]-wavWavelength[j+1])
		endfor
		stats.numPLEMDeltaX /= (stats.numPLEMTotalX - 1)

		String strGratingWave = PLEMd2d1CorrectionConstructor(stats.numGrating,stats.numDetector,stats.numCooling, "correction")
		
		if (stats.numCalibrationMode == 1)
			stats.wavExcitation 	= (stats.numEmissionStart + stats.numEmissionEnd) / 2
			wave wavMeasure 	= $(strDataFolderOriginal + StringFromList(0,strWavePL))
			wave wavBackground 	= $(strDataFolderOriginal + StringFromList(0,strWaveBG))			
			stats.wavMeasure		= wavMeasure
			stats.wavBackground	= wavBackground
			if (waveExists($strGratingWave))
				String wl_temp = GetWavesDataFolder(stats.wavWavelength,2)
				print "hier weitermachen"
				//interpolate2/T=1/I=3/Y=correction_L/X=stats.wavWavelength, $(strGratingWave + WL), $strGratingWave
				stats.wavCorrected	= 0 //ToDo
			else
				print "PLEMd2BuildMaps: Correction not possible. Please Add apropriate Correction Waves"
				stats.wavCorrected	= 0 //ToDo
			endif
			stats.numPLEMDeltaY 	= stats.numEmissionDelta
			stats.numPLEMBottomY 	= stats.numEmissionStart
			stats.numPLEMTopY 		= stats.numEmissionEnd
			SetScale/I x stats.numPLEMLeftX, stats.numPLEMRightX, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground, stats.wavCorrected
		else
			stats.numPLEMBottomY	= (str2num(StringFromList(1,StringFromList(0,strWavePL),"_")) + str2num(StringFromList(2,StringFromList(0,strWavePL),"_"))) / 2
			stats.numPLEMTopY		= (str2num(StringFromList(1,StringFromList((stats.numPLEMTotalY-1),strWavePL),"_")) + str2num(StringFromList(2,StringFromList((stats.numPLEMTotalY-1),strWavePL),"_"))) / 2		
			stats.numPLEMDeltaY 	= 0		
			for (i=0; i<stats.numPLEMTotalY; i+=1)
				numExcitationFrom 	= str2num(StringFromList(1,StringFromList(i,strWavePL),"_"))
				numExcitationTo 		= str2num(StringFromList(2,StringFromList(i,strWavePL),"_"))
				stats.numPLEMDeltaY	+= abs(numExcitationFrom - numExcitationTo)
				stats.wavExcitation[i] 	= (numExcitationFrom + numExcitationTo) / 2
				wave wavMeasure 	= $(strDataFolderOriginal + StringFromList(i,strWavePL))
				wave wavBackground 	= $(strDataFolderOriginal + StringFromList(i,strWaveBG))			
				for (j=0; j<stats.numPLEMTotalX; j+=1)
					stats.wavMeasure[j][i] 		= wavMeasure[j]
					stats.wavBackground[j][i] 	= wavBackground[j]
					stats.wavCorrected[j][i]		= 0 //ToDo: Will Contain Grating Correction
				endfor
				wave wavBackground 	= $("")
				wave wavMeasure 	= $("")
			endfor
			stats.numPLEMDeltaY /= stats.numPLEMTotalY
			SetScale/I x stats.numPLEMLeftX, stats.numPLEMRightX, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground, stats.wavCorrected
			SetScale/I y stats.numPLEMBottomY, stats.numPLEMTopY, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground, stats.wavCorrected			
		endif
		
		// power correction 
		// requires stats.wavExcitation
		wave wavPower 	= $(strDataFolderOriginal + "PW")
		stats.wavPower 		= wavPower
		stats.wavPhoton 		= (stats.wavPower * 1e-6) / (6.62606957e-34 * 2.99792458e+8 / (stats.wavExcitation * 1e-9)) 		// power is in uW and Excitation is in nm
		stats.wavPLEM = stats.wavMeasure - stats.wavBackground
		PLEMd2statsSave(stats)
	endif
	SetDataFolder $strSaveDataFolder	
End

Function PLEMd2ExtractInfo(wavIBW, stats)
	Wave wavIBW
	Struct PLEMd2Stats &stats
	String strFound
	
	stats.strDate 		= PLEMd2ExtractSearch(wavIBW, "Date")
	stats.strUser 		= PLEMd2ExtractSearch(wavIBW, "User")
	stats.strFileName = PLEMd2ExtractSearch(wavIBW, "File")

	stats.numCalibrationMode = PLEMd2ExtractVariables(wavIBW,"numCalibrationMode")
	stats.numSlit = PLEMd2ExtractVariables(wavIBW,"numSlit")
	stats.numGrating = PLEMd2ExtractVariables(wavIBW,"numGrating")
	stats.numFilter = PLEMd2ExtractVariables(wavIBW,"numFilter")
	stats.numShutter = PLEMd2ExtractVariables(wavIBW,"numShutter")
	stats.numWLcenter = PLEMd2ExtractVariables(wavIBW,"numWLcenter")
	stats.numDetector = PLEMd2ExtractVariables(wavIBW,"numDetector")
	stats.numCooling = PLEMd2ExtractVariables(wavIBW,"numCooling")
	stats.numExposure = PLEMd2ExtractVariables(wavIBW,"numExposure")
	stats.numBinning = PLEMd2ExtractVariables(wavIBW,"numBinning")
	stats.numScans = PLEMd2ExtractVariables(wavIBW,"numScans")
	stats.numBackground = PLEMd2ExtractVariables(wavIBW,"numBackground")
	stats.numWLfirst = PLEMd2ExtractVariables(wavIBW,"numWLfirst")
	stats.numWLlast = PLEMd2ExtractVariables(wavIBW,"numWLlast")
	stats.numWLdelta = PLEMd2ExtractVariables(wavIBW,"numWLdelta")
	stats.numEmissionMode = PLEMd2ExtractVariables(wavIBW,"numEmissionMode")
	stats.numEmissionPower = PLEMd2ExtractVariables(wavIBW,"numEmissionPower")
	stats.numEmissionStart = PLEMd2ExtractVariables(wavIBW,"numEmissionStart")
	stats.numEmissionEnd = PLEMd2ExtractVariables(wavIBW,"numEmissionEnd")
	stats.numEmissionDelta = PLEMd2ExtractVariables(wavIBW,"numEmissionDelta")
	stats.numEmissionStep = PLEMd2ExtractVariables(wavIBW,"numEmissionStep")
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

Function/S PLEMd2ExtractPower(wavIBW)
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
	
	numCount = PLEMd2GetListSize(strListParse)
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

Function 	PLEMd2Duplicate(strPLEM)
	String strPLEM

	Struct PLEMd2Stats stats
	PLEMd2statsLoad(stats, strPLEM)

	SetDataFolder $(stats.strPath)
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
	print "PLEMd2Duplicate: WaveName is " + strWavename	
	SetDataFolder root:	
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
	PLEMd2statsLoad(stats, strPLEM)

	String strSaveDataFolder = GetDataFolder(1)		
	SetDataFolder root:
	String strHeader	
	wave wavIBW = $(stats.strPath + "IBW")
	
	strHeader = Note(wavIBW)

	if ((StringMatch(strHeader, "*IGOR2:*")) == 0)
		//IGOR2 not found so the error is probably related to that. (caused by early version of LabView program)
		//I rename IGOR4 to IGOR3 and IGOR3 to IGOR2.
		print "PLEMd2FixWavenotes: Error: Did not find IGOR2 in WaveNote. Fixing...."
		strHeader = ReplaceString("IGOR3:",strHeader,"IGOR2:")
		strHeader = ReplaceString("IGOR4:",strHeader,"IGOR3:")
		Note/K/NOCR wavIBW strHeader
	Endif

	
	SetDataFolder $strSaveDataFolder
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
	numCount = ItemsInList(strHeader, "\r\n")

	i=0
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r\n")
	while ((StringMatch(strReadLine, "*IGOR2*") != 1) && (i<numCount))
	strListWaveNumbers = StringFromList(1, strReadLine, ":")	
	do
		i += 1
		strReadLine = StringFromList(i, strHeader, "\r\n")
	while ((StringMatch(strReadLine, "*IGOR3*") != 1) && (i<numCount))
	strListWaveNames = StringFromList(1, strReadLine, ":")	
	//print strListWaveNumbers
	//print strListWaveNames
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

Function PLEMd2Panel()
	DoWindow PLEMd2Panel
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
	numMaps = PLEMd2GetListSize(strMaps)
	
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
		numSearchstrings = PLEMd2GetListSize(strSearchStrings)		
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
		PLEMd2statsAction(stats, strMap)
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
		numFind = PLEMd2GetListSize(gstrMapsAvailable)
		gnumMapsAvailable = numFind
	else
		gnumMapsAvailable = PLEMd2GetListSize(gstrMapsAvailable)
	endif
	
	
	SetDataFolder $strSaveDataFolder	
	return numFind
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
	
	numAvailable = PLEMd2GetListSize(strListAvailable)
	numKillme = PLEMd2GetListSize(strListKillMe)
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
	//loop adopted from igor manual. though for loops are normally prefered.
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
	

				
		NewPath/O/Q path, gstrPLEMd1PathBase
		print "PLEMd2d1Init: loading Files from " + gstrPLEMd1PathBase
		strFiles = IndexedFile(path,-1,".txt")
		numFiles = PLEMd2GetListSize(strFiles)
		print "PLEMd2d1Init: found " + num2str(numFiles) + " files"
		print strFiles
		numPLEMd1CorrectionWaves = PLEMd2GetListSize(gstrPLEMd1CorrectionToLoad)

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
		print "PLEMd2d1Init: Loaded " + num2str(PLEMd2GetListSize(strFilesLoaded)) + "/"+ num2str(PLEMd2GetListSize(gstrPLEMd1CorrectionToLoad)) + " files"
		print "PLEMd2d1Init: Loaded " + num2str(PLEMd2GetListSize(gstrPLEMd1CorrectionAvailable)) + " waves: "		
		gnumPLEMd1IsInit = 1
		SetDataFolder $strSaveDataFolder
	endif
End

Function/S PLEMd2d1CorrectionWave(strWave)
	//WAVES:wavelength_chroma_abs,transmission_chroma_abs,wavelength_chroma_em,transmission_chroma_em,WL_500_CCD_minus90,E_500_CCD_minus90,WL_1250_CCD_minus90,E_1250_CCD_minus90,WL_1200_CCD_plus20,E_1200_CCD_plus20,WL_1200_InGaAs_minus25,E_1200_InGaAs_minus25,WL_1200_InGaAs_minus90,E_1200_InGaAs_minus90,WL_1200_CCD_minus90,E_1200_CCD_minus90,WL_1200_InGaAs_plus25,E_1200_InGaAs_plus25,WL_1250_InGaAs_minus90,E_1250_InGaAs_minus90,WL_500_CCD_plus20,E_500_CCD_plus20;
	String strWave
	String strSaveDataFolder = GetDataFolder(1)

	PLEMd2d1Init()
	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SVAR gstrPLEMd1root = $(gstrPLEMd2root + ":gstrPLEMd1root")
	SetDataFolder $gstrPLEMd1root
	SVAR gstrPLEMd1CorrectionAvailable

	String strReturn = ""
	
	strReturn = gstrPLEMd1root + ":" + strWave
	wave wavReturn = $strReturn
	
	SetDataFolder $strSaveDataFolder
	
	if (WaveExists(wavReturn))
		return GetWavesDataFolder(wavReturn, 2)
	else
		print "PLEMd2d1CorrectionWave: correction (" + strWave +") not found in gstrPLEMd1CorrectionAvailable"
		return ""
	endif
End

Function/S PLEMd2d1CorrectionConstructor(intGrating, intDetector, intTemperature, strOutputWave)
	Variable intGrating, intTemperature, intDetector
	String strOutputWave
	
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
		intTemperatureNear = intTemperature - intTemperatureRange
		if (intTemperatureNear<0)
			strConstructorNear = strConstructor + "minus"
		elseif  (intTemperatureNear>0)
			strConstructorNear = strConstructor + "plus"
		else
			strConstructorNear = strConstructor
		endif
		strConstructorNear += num2str(abs(intTemperatureNear))
		strReturn = PLEMd2d1CorrectionWave("WL_" + strConstructorNear)
		lenReturn =strlen(strReturn)
		if (lenReturn == 0)
			intTemperatureRange *= -1
			intTemperatureNear = intTemperature - intTemperatureRange
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
		if (intTemperatureNear<-273)
			print "PLEMd2d1CorrectionConstructor: Correction Wave not found."
			return ""
		endif
		if (lenReturn == 0)
			intTemperatureRange = abs(intTemperatureRange) + 5
		else
			break
		endif
	while (lenReturn == 0)	
	strConstructor = strConstructorNear
	print "PLEMd2d1CorrectionConstructor: Found Correction Wave " + strConstructor
	
	strX = PLEMd2d1CorrectionWave("WL_" + strConstructor)
	strY =  PLEMd2d1CorrectionWave("E_" + strConstructor)
	
	//strReturn = PLEMd2SetWaveScale($strX, $strY, strOutputWave)
	duplicate/O $strY $strOutputWave
	duplicate/O $strX $(strOutputWave + "_WL")
	return GetWavesDataFolder($strOutputWave,2)
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

//Function returns the Number of Items in a list.
//only items of size greater than zero are counted. ItemsInList returns even those.
Function PLEMd2GetListSize(strList)
	String strList
	
	String strItem = ""
	Variable numIndex = 0
	do
		strItem = StringFromList(numIndex, strList)
		//break condition
		if (strlen(strItem) == 0)
			break
		endif
		numIndex += 1
	while (1)	
	return numIndex
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

//Structure for storing Information about a PLE-Map
Structure PLEMd2stats
	//Versioning System to update/create new Global vars.
	Variable numVersion
	//strFullPath is path containing wave name
	//strPath is Folder to Map
	//strPLEM is Name of Map	
	//numPLEM is number of Map in Menu Entry-List
	//wavPLEM is the wave reference to :PLEM
	String strPLEM, strFullPath, strPath
	Variable numPLEM
	Wave wavPLEM, wavMeasure, wavBackground, wavCorrected, wavExcitation
	Wave wavWavelength, wavPower, wavPhoton
		
	Variable numPLEMTotalX, numPLEMLeftX, numPLEMDeltaX, numPLEMRightX
	Variable numPLEMTotalY, numPLEMBottomY, numPLEMDeltaY, numPLEMTopY 	//stats.numPLEMDeltaY

	String strDate, strUser, strFileName
	Variable numCalibrationMode, numSlit, numGrating, numFilter, numShutter, numWLcenter, numDetector, numCooling, numExposure, numBinning, numWLfirst, numWLlast, numWLdelta, numEmissionMode, numEmissionPower, numEmissionStart, numEmissionEnd, numEmissionDelta, numEmissionStep, numScans, numBackground
Endstructure

Function PLEMd2statsCreateVar()
	Variable/G gnumPLEM, gnumVersion
	String/G gstrPLEM, gstrFullPath, gstrPath
	
	Variable/G gnumPLEMTotalX, gnumPLEMLeftX, gnumPLEMDeltaX, gnumPLEMRightX
	Variable/G gnumPLEMTotalY, gnumPLEMBottomY, gnumPLEMDeltaY, gnumPLEMTopY
	
	String/G gstrDate, gstrUser, gstrFileName
	Variable/G gnumCalibrationMode, gnumSlit, gnumGrating, gnumFilter, gnumShutter, gnumWLcenter, gnumDetector, gnumCooling, gnumExposure, gnumBinning, gnumScans, gnumBackground
	Variable/G gnumWLfirst, gnumWLlast, gnumWLdelta
	Variable/G gnumEmissionMode, gnumEmissionPower, gnumEmissionStart, gnumEmissionEnd, gnumEmissionDelta, gnumEmissionStep	
End

Function PLEMd2statsLoad(stats, strMap)
	Struct PLEMd2stats &stats
	String strMap
	
	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SVAR gstrMapsFolder = $(gstrPLEMd2root + ":gstrMapsFolder")
	
	String strMapFolder = gstrMapsFolder + ":" + strMap + ":"
	String strMapInfoFolder = strMapFolder + "INFO:"
	String strSaveDataFolder

	if (!DataFolderExists(strMapFolder))
		print "PLEMd2statsLoad: No Map Folder found for map: " + strMap
	else
		strSaveDataFolder = GetDataFolder(1)
		SetDataFolder $strMapFolder
		Wave stats.wavPLEM = PLEM, stats.wavMeasure = MEASURE
		Wave stats.wavBackground = BACKGROUND, stats.wavCorrected = CORRECTED
		Wave stats.wavExcitation = EXCITATION
		Wave stats.wavWavelength = WAVELENGTH
		Wave stats.wavPower = POWER, stats.wavPhoton = PHOTON
		SetDataFolder $strSaveDataFolder
	endif	
	if (!DataFolderExists(strMapInfoFolder))
		print "PLEMd2statsLoad: Wrong call. Please Initialize stats with PLEMd2statsInitialize(" + strMap + ")"
		//PLEMd2statsInitialize(strMap) Load is called from initialize. --> Circle reference!
	endif
	if (DataFolderExists(strMapInfoFolder))
		//it could be that someone deleted all the vars. never mind this case. Maybe later with /Z flag and NVAR_Exists
		strSaveDataFolder = GetDataFolder(1)
		SetDataFolder $strMapInfoFolder		
		NVAR/Z gnumPLEM, gnumVersion
		SVAR/Z gstrPLEM, gstrFullPath, gstrPath
		NVAR/Z gnumPLEMTotalX, gnumPLEMLeftX, gnumPLEMDeltaX, gnumPLEMRightX
		NVAR/Z gnumPLEMTotalY, gnumPLEMBottomY, gnumPLEMDeltaY, gnumPLEMTopY
		SVAR/Z gstrDate, gstrUser, gstrFileName
		NVAR/Z gnumCalibrationMode, gnumSlit, gnumGrating, gnumFilter, gnumShutter, gnumWLcenter, gnumDetector, gnumCooling, gnumExposure, gnumBinning, gnumScans, gnumBackground
		NVAR/Z gnumWLfirst, gnumWLlast, gnumWLdelta
		NVAR/Z gnumEmissionMode, gnumEmissionPower, gnumEmissionStart, gnumEmissionEnd, gnumEmissionDelta, gnumEmissionStep
		
		stats.numVersion = SelectNumber(NVAR_Exists(gnumVersion),0,gnumVersion)
		
		stats.numPLEM 	= SelectNumber(NVAR_Exists(gnumPLEM),-1,gnumPLEM)
		stats.strPLEM	= SelectString(SVAR_Exists(gstrPLEM),"",gstrPLEM)	//could be forced to strMap but keep it simple for once.
		stats.strFullPath 	= SelectString(SVAR_Exists(gstrFullPath),"",gstrFullPath)
		stats.strPath 		= SelectString(SVAR_Exists(gstrPath),"",gstrPath)
		
		stats.numPLEMTotalX = gnumPLEMTotalX
		stats.numPLEMLeftX	= gnumPLEMLeftX
		stats.numPLEMDeltaX 	= gnumPLEMDeltaX
		stats.numPLEMRightX	= gnumPLEMRightX
		
		stats.numPLEMTotalY	= gnumPLEMTotalY
		stats.numPLEMBottomY = gnumPLEMBottomY
		stats.numPLEMDeltaY	= gnumPLEMDeltaY
		stats.numPLEMTopY	= gnumPLEMTopY
		
		stats.strDate 		= gstrDate
		stats.strUser		= gstrUser
		stats.strFileName = gstrFileName
		
		stats.numCalibrationMode = SelectNumber(NVAR_Exists(gnumCalibrationMode),-1,gnumCalibrationMode)
		stats.numSlit = SelectNumber(NVAR_Exists(gnumSlit),-1,gnumSlit)
		stats.numGrating = SelectNumber(NVAR_Exists(gnumGrating),-1,gnumGrating)
		stats.numFilter = SelectNumber(NVAR_Exists(gnumFilter),-1,gnumFilter)
		stats.numShutter = SelectNumber(NVAR_Exists(gnumShutter),-1,gnumShutter)
		stats.numWLcenter = SelectNumber(NVAR_Exists(gnumWLcenter),-1,gnumWLcenter)
		stats.numDetector = SelectNumber(NVAR_Exists(gnumDetector),-1,gnumDetector)
		stats.numCooling = SelectNumber(NVAR_Exists(gnumCooling),-1,gnumCooling)
		stats.numExposure = SelectNumber(NVAR_Exists(gnumExposure),-1,gnumExposure)
		stats.numBinning = SelectNumber(NVAR_Exists(gnumBinning),-1,gnumBinning)
		stats.numWLfirst = SelectNumber(NVAR_Exists(gnumWLfirst),-1,gnumWLfirst)
		stats.numWLlast = SelectNumber(NVAR_Exists(gnumWLlast),-1,gnumWLlast)
		stats.numWLdelta = SelectNumber(NVAR_Exists(gnumWLdelta),-1,gnumWLdelta)
		stats.numEmissionMode = SelectNumber(NVAR_Exists(gnumEmissionMode),-1,gnumEmissionMode)
		stats.numEmissionPower = SelectNumber(NVAR_Exists(gnumEmissionPower),-1,gnumEmissionPower)
		stats.numEmissionStart = SelectNumber(NVAR_Exists(gnumEmissionStart),-1,gnumEmissionStart)
		stats.numEmissionEnd = SelectNumber(NVAR_Exists(gnumEmissionEnd),-1,gnumEmissionEnd)
		stats.numEmissionDelta = SelectNumber(NVAR_Exists(gnumEmissionDelta),-1,gnumEmissionDelta)
		stats.numEmissionStep = SelectNumber(NVAR_Exists(gnumEmissionStep),-1,gnumEmissionStep)
		stats.numScans = SelectNumber(NVAR_Exists(gnumScans),-1,gnumScans)
		stats.numBackground = SelectNumber(NVAR_Exists(gnumBackground),-1,gnumBackground)
		
		SetDataFolder $strSaveDataFolder
	endif
End

Function PLEMd2statsSave(stats)
	Struct PLEMd2stats &stats
	String strMap = stats.strPLEM
	
	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SVAR gstrMapsFolder = $(gstrPLEMd2root + ":gstrMapsFolder")
	
	String strMapFolder = gstrMapsFolder + ":" + strMap + ":"
	String strMapInfoFolder = strMapFolder + "INFO:"
	String strSaveDataFolder

	if (!DataFolderExists(strMapFolder))
		print "PLEMd2statsSave: No Map Folder found for map: " + strMap
	else
		strSaveDataFolder = GetDataFolder(1)
		SetDataFolder $strMapFolder
		//wavPLEM = PLEM, wavMeasure = MEASURE, wavBackground = BACKGROUND, wavCorrected = CORRECTED
		//wavWavelength = WAVELENGTH, wavPower = POWER, wavPhoton = PHOTON
		//wavPLEM 	= stats.wavPLEM
		//wavMeasure 	= stats.wavMeasure
		//Waveexists(stats.wavBackground) ? wavBackground = stats.wavBackground
		//wavCorrected 	= stats.wavCorrected
		//wavWavelength 	= stats.wavWavelength
		//wavPower 	= stats.wavPower
		//wavPhoton 	= stats.wavPhoton
		SetDataFolder $strSaveDataFolder
	endif
	if (!DataFolderExists(strMapInfoFolder))
		print "PLEMd2statsSave: No Info Folder found for map: " + strMap
	else
		//it could be that someone deleted all the vars. never mind this case.
		strSaveDataFolder = GetDataFolder(1)
		SetDataFolder $strMapInfoFolder
		NVAR/Z gnumPLEM, gnumVersion
		SVAR/Z gstrPLEM, gstrFullPath, gstrPath
		NVAR/Z gnumPLEMTotalX, gnumPLEMLeftX, gnumPLEMDeltaX, gnumPLEMRightX
		NVAR/Z gnumPLEMTotalY, gnumPLEMBottomY, gnumPLEMDeltaY, gnumPLEMTopY
		SVAR/Z gstrDate, gstrUser, gstrFileName
		NVAR/Z gnumCalibrationMode, gnumSlit, gnumGrating, gnumFilter, gnumShutter, gnumWLcenter, gnumDetector, gnumCooling, gnumExposure, gnumBinning, gnumScans, gnumBackground
		NVAR/Z gnumWLfirst, gnumWLlast, gnumWLdelta
		NVAR/Z gnumEmissionMode, gnumEmissionPower, gnumEmissionStart, gnumEmissionEnd, gnumEmissionDelta, gnumEmissionStep
		
		gnumVersion		= stats.numVersion
		
		gnumPLEM		= stats.numPLEM
		gstrPLEM		= stats.strPLEM
		gstrFullPath		= stats.strFullPath
		gstrPath			= stats.strPath
		
		gnumPLEMTotalX	= stats.numPLEMTotalX
		gnumPLEMLeftX	= stats.numPLEMLeftX
		gnumPLEMDeltaX = stats.numPLEMDeltaX
		gnumPLEMRightX	= stats.numPLEMRightX
		
		gnumPLEMTotalY		= stats.numPLEMTotalY
		gnumPLEMBottomY 	= stats.numPLEMBottomY
		gnumPLEMDeltaY		= stats.numPLEMDeltaY
		gnumPLEMTopY		= stats.numPLEMTopY
		
		gstrDate 		= stats.strDate
		gstrUser			= stats.strUser
		gstrFileName 	= stats.strFileName
		
		gnumCalibrationMode = stats.numCalibrationMode
		gnumSlit = stats.numSlit
		gnumGrating = stats.numGrating
		gnumFilter = stats.numFilter
		gnumShutter = stats.numShutter
		gnumWLcenter = stats.numWLcenter
		gnumDetector = stats.numDetector
		gnumCooling = stats.numCooling
		gnumExposure = stats.numExposure
		gnumBinning = stats.numBinning
		gnumScans = stats.numScans
		gnumBackground = stats.numBackground
		gnumWLfirst = stats.numWLfirst
		gnumWLlast = stats.numWLlast
		gnumWLdelta = stats.numWLdelta
		gnumEmissionMode = stats.numEmissionMode
		gnumEmissionPower = stats.numEmissionPower
		gnumEmissionStart = stats.numEmissionStart
		gnumEmissionEnd = stats.numEmissionEnd
		gnumEmissionDelta = stats.numEmissionDelta
		gnumEmissionStep = stats.numEmissionStep

		SetDataFolder $strSaveDataFolder
	endif
End

Function PLEMd2statsInitialize(strPLEM)
//Initialize the stats struct 
//**on Version-Missmatch 
//**if Folder INFO is not there.
	String strPLEM
	
	Struct PLEMd2stats stats		
	String strDataFolder
	
	if (PLEMd2isInit())	
		String strSaveDataFolder = GetDataFolder(1)

		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SetDataFolder $gstrPLEMd2root
		SVAR gstrMapsAvailable, gstrMapsFolder
		SetDataFolder $gstrMapsFolder
		
		if (FindListItem(strPLEM, gstrMapsAvailable) != -1)
			strDataFolder = gstrMapsFolder + ":" + strPLEM
			if (!DataFolderExists(strDataFolder))
				print "PLEMd2statsInitVar: Current Map (" + strPLEM + ")is not in conventional Data Folder strucure. Check Code"
				NewDataFolder/O $strDataFolder
			endif
			SetDataFolder $strDataFolder
			strDataFolder += ":INFO"
			if (!DataFolderExists(strDataFolder))
				print "PLEMd2statsInitVar: Initializing Info Variables for Map"
				NewDataFolder/O/S $strDataFolder
				PLEMd2statsCreateVar()
			else
				//folder exists so we are in a previous Version of the program.
				SetDataFolder $strDataFolder				
				PLEMd2statsLoad(stats, strPLEM)
				if (stats.numVersion<PLEMd2Version)
					print "PLEMd2statsInitVar: Version Missmatch. Initializing. Information loss hopefuly prevented."
					//clear folder and set new waves
					KillVariables/A/Z
					KillStrings/A/Z
					KillWaves/A/Z			
					PLEMd2statsCreateVar()
					//set to new Version
					stats.numVersion = PLEMd2Version
					//save stats that were loaded before.
					PLEMd2statsSave(stats)
				endif
			endif

		endif
	endif
	SetDataFolder $strSaveDataFolder
End

Function PLEMd2statsMenu(numMap)
	Variable numMap
	
	Struct PLEMd2stats stats
	String strMap = PLEMd2Menu(numMap)
	PLEMd2statsAction(stats, strMap)
End

Function PLEMd2statsAction(stats, strMap)
	Struct PLEMd2stats &stats
	String strMap
	PLEMd2statsInitialize(strMap)
	PLEMd2statsLoad(stats, strMap)
	PLEMd2statsMap(stats, strMap)
	PLEMd2statsCalculate(stats)
	PLEMd2statsSave(stats)
End

Function PLEMd2statsMap(stats, strMap)
	Struct PLEMd2stats &stats
	String strMap
	String strPath = ""
	
	String strSaveDataFolder = GetDataFolder(1)

	if (strlen(stats.strPLEM)==0)
		print "PLEMd2statsInit: WaveName not valid"
		return 0
	endif
	//check if wave exists
	strPath = PLEMd2FullPathByString(stats.strPLEM)
	wave wavPLEM = $strPath
	if (WaveExists(wavPLEM)==0)
		print "PLEMd2statsInit: Input Error Wave does not exist."
		return 0
	endif
	stats.strFullPath	= GetWavesDataFolder(wavPLEM,2)
	stats.strPath 		= GetWavesDataFolder(wavPLEM,1)
	wave stats.wavPLEM = wavPLEM

	print "PLEMd2statsMap: PLE-Map: "	+ stats.strPLEM
	print "PLEMd2statsMap: Folder: " 	+ stats.strPath
	print "PLEMd2statsMap: Full Path: " 	+ stats.strFullPath
	SetDataFolder $strSaveDataFolder
End

Function PLEMd2statsCalculate(stats)
	Struct PLEMd2stats &stats
	
	//Help Variables for sorting
	//Sorting of pointers. But pointers do not seem to work at runtime within a function: left = &test
	Variable left, right
		
	wave wavPLEM = stats.wavPLEM
	
	//collect Information about the wave and sort it.
	stats.numPLEMTotalX	= DimSize(wavPLEM,0)
	stats.numPLEMLeftX	= DimOffset(wavPLEM,0)
	stats.numPLEMDeltaX 	= DimDelta(wavPLEM,0)	
	stats.numPLEMRightX	= stats.numPLEMLeftX + stats.numPLEMTotalX * stats.numPLEMDeltaX
	stats.numPLEMTotalY	= DimSize(wavPLEM,1)
	stats.numPLEMBottomY=DimOffset(wavPLEM,1)
	stats.numPLEMDeltaY	= DimDelta(wavPLEM,1)
	stats.numPLEMTopY	= stats.numPLEMBottomY + stats.numPLEMTotalY * stats.numPLEMDeltaY
	
	left = stats.numPLEMLeftX
	right = stats.numPLEMRightX
	PLEMd2sort(left,right)
	stats.numPLEMLeftX = left
	stats.numPLEMRightX=right
	
	left = stats.numPLEMBottomY
	right = stats.numPLEMTopY
	PLEMd2sort(left,right)
	stats.numPLEMBottomY = left
	stats.numPLEMTopY=right	
	
	print "PLEMd2statsCalculate: Absorption: " + num2str(stats.numPLEMLeftX) + "nm - " + num2str(stats.numPLEMRightX) + "nm"	
	print "PLEMd2statsCalculate: Emission: "+ num2str(stats.numPLEMBottomY) + "nm - " + num2str(stats.numPLEMTopY) + "nm"	
	print "PLEMd2statsCalculate: Size: "+num2str(stats.numPLEMTotalX) + "x" + num2str(stats.numPLEMTotalY) + " Data Points."
End

Function/S PLEMd2FullPathByString(strPLEM)
	String strPLEM	

	String strSaveDataFolder = GetDataFolder(1)

	SVAR gstrPLEMd2root = root:gstrPLEMd2root
	SetDataFolder $gstrPLEMd2root
	SVAR gstrMapsFolder

	String strMap = gstrMapsFolder + ":" + strPLEM + ":PLEM"

	SetDataFolder $strSaveDataFolder
	return strMap
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
		
	if (strlen(stats.strFullPath)==0)
		print "PLEMd2Display: Calculating Path for PLEM " + strPLEM
		PLEMd2statsMap(stats, strPLEM)
	endif
	if (WaveExists($(stats.strFullPath)))
		if (stats.numCalibrationMode == 1)
			Display $(stats.strFullPath)
			winPLEM = "win_" + stats.strPLEM
			DoWindow/F $winPLEM
			if (V_Flag == 0)
				DoWindow/C/T $winPLEM, stats.strPLEM
				ModifyGraph/W=$winPLEM standoff=0
				SetAxis/W=$winPLEM/A left
				Label/W=$winPLEM left "intensity / a.u."
				Label/W=$winPLEM bottom "wavelength / nm (Excitation at "+num2str(stats.numEmissionStart)+"-"+num2str(stats.numEmissionEnd)+")"
			endif
		else
			Display	
			AppendImage $stats.strFullPath
			winPLEM = "win_" + stats.strPLEM
			DoWindow/F $winPLEM
			if (V_Flag == 0)
				DoWindow/C/T $winPLEM, stats.strPLEM
				ModifyImage/W=$winPLEM ''#0 ctab= {*,*,Terrain256,0}
				ModifyGraph/W=$winPLEM standoff=0
				SetAxis/W=$winPLEM/A left
				Label/W=$winPLEM left "center of excitation / nm"
				Label/W=$winPLEM bottom "emission / nm"				
			endif
			
		endif
	else
		print "PLEMd2Display: Wave Not Found"
	endif
End

// Global Preferences stored in igor Folder
// adopted from igor manual
Structure PLEMd2Prefs
//use uint, double, uchar as NVAR SVAR etc are not yet initialized
	uint32	version			// Preferences structure version number. 1,2,3,4,...
	double	panelCoords[4]	// left, top, right, bottom
	uchar	strMapsPath[256]
	uint32	reserved[100]	// Reserved for future use
EndStructure

//	Sets prefs structure to default values.
static Function PLEMd2DefaultPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	prefs.version = PLEMd2Version

	prefs.panelCoords[0] = 5			// Left
	prefs.panelCoords[1] = 40		// Top
	prefs.panelCoords[2] = 5+190	// Right
	prefs.panelCoords[3] = 40+125	// Bottom
	
	prefs.strMapsPath = PLEMd2WorkingDir

	Variable i
	for(i=0; i<100; i+=1)
		prefs.reserved[i] = 0
	endfor
End

// SyncPackagePrefsStruct(prefs)
// Syncs package prefs structures to match state of panel. Call this only if the panel exists.
static Function PLEMd2SyncPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	// Panel does exists. Set prefs to match panel settings.
	prefs.version = PLEMd2Version
	
	GetWindow  PLEMd2Panel wsize
	// NewPanel uses device coordinates. We therefore need to scale from
	// points (returned by GetWindow) to device units for windows created
	// by NewPanel.
	Variable scale = ScreenResolution / 72
	prefs.panelCoords[0] = V_left * scale
	prefs.panelCoords[1] = V_top * scale
	prefs.panelCoords[2] = V_right * scale
	prefs.panelCoords[3] = V_bottom * scale
	
//	ControlInfo /W=PLEMd2Panel PhaseLock
//	prefs.phaseLock = V_Value		// 0=unchecked; 1=checked
	
End

// InitPackagePrefsStruct(prefs)
// Sets prefs structures to match state of panel or to default values if panel does not exist.
static Function PLEMd2InitPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	DoWindow PLEMd2Panel
	if (V_flag == 0)
		// Panel does not exist. Set prefs struct to default.
		PLEMd2DefaultPackagePrefsStruct(prefs)
	else
		// Panel does exists. Sync prefs struct to match panel state.
		PLEMd2SyncPackagePrefsStruct(prefs)
	endif
End

static Function PLEMd2LoadPackagePrefs(prefs)
	STRUCT PLEMd2Prefs &prefs

	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences PLEMd2PackageName, PLEMd2PrefsFileName, PLEMd2PrefsRecordID, prefs

	// If error or prefs not found or not valid, initialize them.
	if (V_flag!=0 || V_bytesRead==0 || prefs.version!= PLEMd2Version)
		//print "PLEMd2:LoadPackagePrefs: Loading from " + SpecialDirPath("Packages", 0, 0, 0)
		PLEMd2InitPackagePrefsStruct(prefs)	// Set based on panel if it exists or set to default values.
		PLEMd2SavePackagePrefs(prefs)		// Create initial prefs record.
	endif
End

static Function PLEMd2SavePackagePrefs(prefs)
	STRUCT PLEMd2Prefs &prefs
	//print "PLEMd2:SavePackagePrefs: Saving to " + SpecialDirPath("Packages", 0, 0, 0)
	SavePackagePreferences PLEMd2PackageName, PLEMd2PrefsFileName, PLEMd2PrefsRecordID, prefs
End


//adapt these two Functions delete them by time

Function PLEMd2PowerCorrection(wavName)
wave wavName
Variable numPower
numPower = str2num(StringFromList(0,PLEMd2ExtractPower(wavName)))
if (numPower>0)
	wavName/=numPower
	Print "corrected Wave " + GetWavesDataFolder(wavName, 2) + " to Power " + num2str(numPower)
endif
End

Function PLEMd2DataLoop()
string strWaves, strWave
variable i
strWaves = WaveList("*",";","")
for (i=0;i<ItemsInList(strWaves);i+=1)	
	strWave = StringFromList(i, strWaves)
	PLEMd2PowerCorrection($strWave)
endfor
End