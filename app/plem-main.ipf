//Programmed by Matthias Kastner
//Date 16.03.2015
//Version 0: 	Skeleton
//Version 1: 	Global Settings in binary file
//Version 2: 	Dynamic paths for User Procedures directory
//			Dynamic Delimited Text Load for old Gratings and other Correction Files.
//Version 3:	Specified fixed Format for Loading Maps, Background etc.

#pragma rtGlobals=3		// Use modern global access method and strict wave access.

static Constant PLEMd2Version = 3
static StrConstant PLEMd2PackageName = "PLEM-displayer2"
static StrConstant PLEMd2PrefsFileName = "PLEMd2Preferences.bin"
static Constant PLEMd2PrefsRecordID = 0

Menu "PLE-Map", dynamic //create menu bar entry
	"PLEMapDisplayer2", PLEMd2()
	SubMenu "PLEMapDisplayer1"
		"Import", PLEMd2d1Import()
		"Import and Kill", PLEMd2d1Import(1)
	End
	SubMenu "PLEM"
	//List all available Maps in current project (max 15)
		PLEMd2Menu(0), PLEMd2Display(0)
		PLEMd2Menu(1), PLEMd2Display(1)
		PLEMd2Menu(2), PLEMd2Display(2)
		PLEMd2Menu(3), PLEMd2Display(3)
		PLEMd2Menu(4), PLEMd2Display(4)		
		PLEMd2Menu(5), PLEMd2Display(5)
		PLEMd2Menu(6), PLEMd2Display(6)
		PLEMd2Menu(7), PLEMd2Display(7)
		PLEMd2Menu(8), PLEMd2Display(8)
		PLEMd2Menu(9), PLEMd2Display(9)
		PLEMd2Menu(10), PLEMd2Display(10)
		PLEMd2Menu(11), PLEMd2Display(11)
		PLEMd2Menu(12), PLEMd2Display(12)
		PLEMd2Menu(13), PLEMd2Display(13)
		PLEMd2Menu(14), PLEMd2Display(14)				
	End
End

// Variables for current Project only. See also the LoadPreferences towards the end of the procedure for additional settings that are saved system-wide.
Function PLEMd2initVar()
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
	String/G gstrPathBased1	= SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:Korrekturkurven:"
	
	//Global Wave Names for correction files (maybe this is better done dynamically)
	String/G gstrCCD1250		= gstrPLEMd2root + ":" + "CCD1250"
	String/G gstrInGaAs1250	= gstrPLEMd2root + ":" + "InGaAs1250"
	
	//Data from old PLEM-displayer1
	String/G gstrPLEMd1Folder = gstrPLEMd2root + ":" + "PLEMd1"
	//Load only specified waves from folder. Leave blank if all waves should be loaded.
	String/G gstrD1CorrectionWaves = "500 nm Blaze & CCD @ +20 °C.txt;500 nm Blaze & CCD @ -90 °C.txt;1200 nm Blaze & CCD @ +20 °C.txt;1200 nm Blaze & CCD @ -90 °C.txt;1250 nm Blaze & CCD @ -90 °C.txt;1200 nm Blaze & InGaAs @ +25 °C.txt;1200 nm Blaze & InGaAs @ -90 °C.txt;1250 nm Blaze & InGaAs @ -90 °C.txt;760 nm Strahlenteiler (Chroma) abs.txt;760 nm Strahlenteiler (Chroma) em.txt"
	NewDataFolder/O	 $gstrPLEMd1Folder	
	Variable/G gnumPLEMd1IsInit = 0
	
	//Maps: Create Folder and Initialize Strings where we store the maps of the current project
	String/G gstrMapsFolder = gstrPLEMd2root + ":" + "maps"
	NewDataFolder/O	 $gstrMapsFolder	
	String/G gstrMapsAvailable = ""
	Variable/G gnumMapsAvailable	= 0

		
	//set a variable in root folder to recognize if the module was initialized.
	SetDataFolder root:
	Variable/G gnumPLEMd2IsInit = 1
	SetDataFolder $gstrPLEMd2root
End

Function/S PLEMd2Menu(numPLEM)
	Variable numPLEM		

	String strReturn = ""
	String strSaveDataFolder = GetDataFolder(1)
	SetDataFolder root:		

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
	//no else needed. strReturn was delclared initially. So fall back to that.
	endif
	
	SetDataFolder $strSaveDataFolder	
	return strReturn
End

Function PLEMd2isInit()
	Variable numInit
	
	String strSaveDataFolder = GetDataFolder(1)
	SetDataFolder root:	
	
	if (FindListItem("gnumPLEMd2IsInit",VariableList("*",";",4)) != -1)
		NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
		numInit = gnumPLEMd2IsInit
	else
		//Do not declare Global Variable here. Use InitVar instead
		numInit = 0
	endif
	
	SetDataFolder $strSaveDataFolder	
	return numInit
End

//The Init and exit Function should be called before and after a menu item is called.
Function PLEMd2init()
	//remember current path
	String strSaveDataFolder = GetDataFolder(1)			

	if (PLEMd2isInit()==0)
		PLEMd2initVar()
		print "PLEMd2init: intialization"
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
	STRUCT PLEMd2Prefs prefs
	LoadPackagePrefs(prefs)
	//reset for testing purose
	PLEMd2reset()
	PLEMd2init()
	PLEMd2exit()
	SavePackagePrefs(prefs)
End

Function PLEMd2d1Import([numKillWavesAfterwards])
	Variable numKillWavesAfterwards
	if (ParamIsDefault(numKillWavesAfterwards))
		numKillWavesAfterwards = 0
	endif
	//imports Maps and corresponding files from 
	//old PLE-Map displayer created by Tilman Hain from ~2013-2015
	PLEMd2init()
	SVAR gstrMapsFolder
	SVAR gstrMapsAvailable
	NVAR gnumMapsAvailable	
	
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
			NewDataFolder/O/S $strMap //option O probably not needed.
		endif

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
		
		//Copy Map
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
			
			//Create Background Wave from Files.
			Duplicate/O wavPLEM BACKGROUND
			wave wavBackground	= BACKGROUND			
			numFiles	= PLEMd2d1CountFiles(gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg")

			for (j=0;j<numTotalY;j+=1)
				if (numFiles > 1)
					strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg_" + num2str(j)
				else
					strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg_0"
				endif
				wave wavCurrent = $strWave
				if (WaveExists(wavCurrent))
					for (k=0;k<numTotalX;k+=1)
						wavBackground[k][j] = wavCurrent[k]
					endfor
				else
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
			Duplicate/O wavWavelength WL
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
		if (FindListItem(strMap,gstrMapsAvailable) == -1)
			gstrMapsAvailable += strMap + ";"
		endif
	endfor
	gnumMapsAvailable = PLEMd2GetListSize(gstrMapsAvailable)
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
	if (PLEMd2isInit() == 0)
		return 0
	else
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		NVAR gnumPLEMd1IsInit = $(gstrPLEMd2root + ":gnumPLEMd1IsInit")
		return gnumPLEMd1IsInit
	endif
End

Function PLEMd2d1reset()
	print "PLEMd2d1reset: reset in progress"
	If (PLEMd2d1isInit() == 1)
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		NVAR gnumPLEMd1IsInit = $(gstrPLEMd2root + ":gnumPLEMd1IsInit")	
		gnumPLEMd1IsInit = 0
	endif
	PLEMd2d1Init()
End

Function PLEMd2d1Init()
	//check if Init() is necessary. And if the global variables are relibably there.
	If (PLEMd2d1isInit() == 0)
		//switch to current working dir. Keep old directory in memory.
		String strSaveDataFolder = GetDataFolder(1)
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SetDataFolder $gstrPLEMd2root		
		
		//now we fetch the global vars.
		SVAR gstrD1CorrectionWaves, gstrPLEMd1Folder, gstrPathBased1
		NVAR gnumPLEMd1IsInit
	
		//and define some local.
		String strD1CorrectionWaves, strD1CorrectionWave
		String strFiles, strFile
		Variable numD1CorrectionWaves, numFiles
		Variable i
	
		//waves should be saved in PLEMd1 Folder.
		SetDataFolder $gstrPLEMd1Folder	
		NewPath/O/Q path, gstrPathBased1
		print "PLEMd2d1Init: loading Files from " + gstrPathBased1
		strFiles = IndexedFile(path,-1,".txt")
		numFiles = PLEMd2GetListSize(strFiles)
		print "PLEMd2d1Init: found " + num2str(numFiles) + " files: " + strFiles		
		numD1CorrectionWaves = PLEMd2GetListSize(gstrD1CorrectionWaves)

		//if there were no waves specified, load all Files from the current directory.		
		if (numD1CorrectionWaves == 0)
			numD1CorrectionWaves = numFiles
			strD1CorrectionWaves = strFiles
		else
			strD1CorrectionWaves	 = gstrD1CorrectionWaves
		endif

		for (i=0;i<numFiles;i+=1)
			strFile = StringFromList(i, strFiles)
			if (FindListItem(strFile,strD1CorrectionWaves) != -1)
				print "Loading from " + strFile
				//LoadWave/P=path/O/J/D/W/A/K=0 (strFile + ".txt")
					//P	Path Variable
					//O	Overwrite existing waves in case of a name conflict.
					//J	Indicates that the file uses the delimited text format.
					//D	Creates double precision waves.
					//A	"Auto-name and go" (used with subsequent W)
					//W	Looks for wave names in file
					//K=k	Controls how to determine whether a column in the file is numeric or text (only for delimited text and fixed field text files).
					//	k = 0:	Deduce the nature of the column automatically.
			endif
		endfor
	gnumPLEMd1IsInit = 1
	SetDataFolder $strSaveDataFolder
	endif
End



//Helper Functions

//Function returns the Number of Items in a list.
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
variable &left,&right
	if (left>right)
		variable temp=left
		left=right
		right=temp
		temp=0
	endif
End

//Structure for storing Information about a PLE-Map
Structure PLEMd2stats
	String strPLEM
	String strFullPath
	wave wavPLEM
		
	Variable floPLEMTotalX, floPLEMLeftX, floPLEMDeltaX, floPLEMRightX, floPLEMTotalY, floPLEMBottomY, floPLEMDeltaY, floPLEMTopY
Endstructure

Function PLEMd2statsInit(stats, strPLEM)
	Struct PLEMd2stats &stats
	String strPLEM
	
	//Help Variables for sorting
	//Sorting of pointers. But pointers do not seem to work at runtime within a function: left = &test
	Variable left, right

	//check if wave exists
	wave wavPLEM = $strPLEM	
	if (WaveExists(wavPLEM)==0)
		print "PLEMd2statsInit: Input Error Wave does not exist."
		stats.strPLEM = ""
		return 0
	else
		stats.strPLEM = NameOfWave(wavPLEM)
		stats.strFullPath = GetWavesDataFolder(wavPLEM,2)
		wave stats.wavPLEM = wavPLEM
	endif
	
	//collect Information about the wave and sort it.
	stats.floPLEMTotalX	= DimSize(wavPLEM,0)
	stats.floPLEMLeftX	= DimOffset(wavPLEM,0)
	stats.floPLEMDeltaX 	= DimDelta(wavPLEM,0)	
	stats.floPLEMRightX	= stats.floPLEMLeftX + stats.floPLEMTotalX * stats.floPLEMDeltaX
	stats.floPLEMTotalY	= DimSize(wavPLEM,1)
	stats.floPLEMBottomY=DimOffset(wavPLEM,1)
	stats.floPLEMDeltaY	= DimDelta(wavPLEM,1)
	stats.floPLEMTopY	= stats.floPLEMBottomY + stats.floPLEMTotalY * stats.floPLEMDeltaY
	
	left = stats.floPLEMLeftX
	right = stats.floPLEMRightX
	PLEMd2sort(left,right)
	stats.floPLEMLeftX = left
	stats.floPLEMRightX=right
	
	left = stats.floPLEMBottomY
	right = stats.floPLEMTopY
	PLEMd2sort(left,right)
	stats.floPLEMBottomY = left
	stats.floPLEMTopY=right	
	
	print "PLEMd2statsInit: PLE-Map: " + stats.strPLEM
	print "PLEMd2statsInit: Absorption: " + num2str(stats.floPLEMLeftX) + "nm - " + num2str(stats.floPLEMRightX) + "nm"	
	print "PLEMd2statsInit: Emission: "+ num2str(stats.floPLEMBottomY) + "nm - " + num2str(stats.floPLEMTopY) + "nm"	
	print "PLEMd2statsInit: Size: "+num2str(stats.floPLEMTotalX) + "x" + num2str(stats.floPLEMTotalY) + " Data Points."
End

Function/S PLEMd2FullPath(numPLEM)
	Variable numPLEM	
	PLEMd2init()
	SVAR gstrMapsAvailable, gstrMapsFolder
	String strMap = gstrMapsFolder + ":" + StringFromList(numPLEM, gstrMapsAvailable) + ":PLEM"
	PLEMd2exit()
	return strMap
End

Function PLEMd2Display(numPLEM)
	Variable numPLEM
	String strMap	
	strMap = PLEMd2FullPath(numPLEM)
	Display	
	AppendImage $strMap
End

// Global Preferences stored in igor Folder
// adopted from igor manual
Structure PLEMd2Prefs
//use uint, double, uchar as NVAR SVAR etc are not yet initialized
	uint32	version			// Preferences structure version number. 1,2,3,4,...
	double	panelCoords[4]	// left, top, right, bottom
	uint32	reserved[100]	// Reserved for future use
EndStructure

//	Sets prefs structure to default values.
static Function DefaultPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	prefs.version = PLEMd2Version

	prefs.panelCoords[0] = 5			// Left
	prefs.panelCoords[1] = 40		// Top
	prefs.panelCoords[2] = 5+190	// Right
	prefs.panelCoords[3] = 40+125	// Bottom

	Variable i
	for(i=0; i<100; i+=1)
		prefs.reserved[i] = 0
	endfor
End

// SyncPackagePrefsStruct(prefs)
// Syncs package prefs structures to match state of panel. Call this only if the panel exists.
static Function SyncPackagePrefsStruct(prefs)
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
static Function InitPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	DoWindow PLEMd2Panel
	if (V_flag == 0)
		// Panel does not exist. Set prefs struct to default.
		DefaultPackagePrefsStruct(prefs)
	else
		// Panel does exists. Sync prefs struct to match panel state.
		SyncPackagePrefsStruct(prefs)
	endif
End

static Function LoadPackagePrefs(prefs)
	STRUCT PLEMd2Prefs &prefs

	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences PLEMd2PackageName, PLEMd2PrefsFileName, PLEMd2PrefsRecordID, prefs

	// If error or prefs not found or not valid, initialize them.
	if (V_flag!=0 || V_bytesRead==0 || prefs.version!= PLEMd2Version)
		print "PLEMd2:LoadPackagePrefs: Loading from " + SpecialDirPath("Packages", 0, 0, 0)
		InitPackagePrefsStruct(prefs)	// Set based on panel if it exists or set to default values.
		SavePackagePrefs(prefs)		// Create initial prefs record.
	endif
End

static Function SavePackagePrefs(prefs)
	STRUCT PLEMd2Prefs &prefs
	print "PLEMd2:SavePackagePrefs: Saving to " + SpecialDirPath("Packages", 0, 0, 0)
	SavePackagePreferences PLEMd2PackageName, PLEMd2PrefsFileName, PLEMd2PrefsRecordID, prefs
End