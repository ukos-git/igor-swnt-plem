//Programmed by Matthias Kastner
//Date 16.03.2015
//Version 0: 	Skeleton
//Version 1: 	Global Settings in binary file
//Version 2: 	Dynamic paths for User Procedures directory
//			Dynamic Delimited Text Load for old Gratings and other Correction Files.
//Version 3:	Specified fixed Format for Loading Maps, Background etc.
//Version 4:	Loading of PLEMd1 Correction Waves completed. Versioning System also for Global Variables Initialization.
//Version 5:	Global Variables of PLEMd1 are saved in Subdirectory (avoid trash)
//			Versioning System extended for subversions. Loading Procedure Corrected.
//Version 6	Created Loading Dialog for Choosing the correct file Names.
//Version 7:	ToDo. Create Panel for Map-Updates, Save Parameters for Map-Update in PARAMETER-Folder. set PLEMd=1 for old Maps and PLEMd=2 for new Maps. Maybe save it as a STRUCT.

#pragma rtGlobals=3		// Use modern global access method and strict wave access.

static Constant PLEMd2Version = 0608
static StrConstant PLEMd2PackageName = "PLEM-displayer2"
static StrConstant PLEMd2PrefsFileName = "PLEMd2Preferences.bin"
static StrConstant PLEMd2WorkingDir = "C:users:matthias:Meine Dokumente:Dokumente:programs:local:igor:matthias:PLEM-displayer2:"
static Constant PLEMd2PrefsRecordID = 0

Menu "PLE-Map", dynamic //create menu bar entry
	SubMenu "Displayer1"
		"Init", PLEMd2d1Init()	
		"Open", PLEMd2d1Open()
		"-"
		"Open depricated", PLEMapDisplayer()
		"Maps: Import", PLEMd2d1Import()
		"Maps: Import and Kill", PLEMd2d1Import(1)		
	End
	SubMenu "Displayer2"
		"Init", PLEMd2()
		"Open", PLEMd2open()
		"Configuration", PLEMd2Panel()
	End
	SubMenu "PLEMap"
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
	
	//
	String/G gstrPLEMd1root = gstrPLEMd2root + ":" + "PLEMd1"
	String/G gstrMapsFolder = gstrPLEMd2root + ":" + "maps"
	SetDataFolder $gstrPLEMd2root  //folder should already be there.	
	//Correction Waves from old PLEM-displayer1

	NewDataFolder/O/S	 $gstrPLEMd1root
	String/G gstrPLEMd1PathBase	 = SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:Korrekturkurven:"	
	//Load only specified waves from folder. Leave blank if all waves from directory above should be loaded.	
	String/G gstrPLEMd1CorrectionToLoad = "500 nm Blaze & CCD @ +20 °C.txt;500 nm Blaze & CCD @ -90 °C.txt;1200 nm Blaze & CCD @ +20 °C.txt;1200 nm Blaze & CCD @ -90 °C.txt;1250 nm Blaze & CCD @ -90 °C.txt;1200 nm Blaze & InGaAs @ +25 °C.txt;1200 nm Blaze & InGaAs @ -90 °C.txt;1250 nm Blaze & InGaAs @ -90 °C.txt;760 nm Strahlenteiler (Chroma) Abs.txt;760 nm Strahlenteiler (Chroma) Em.txt"
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
	//no else needed. strReturn was delclared initially. So fall back to that.	
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

Function PLEMd2Open()
	//INIT
	STRUCT PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)
	PLEMd2init()
	
	String strFile, strFileName
	
	strFile=PLEMd2PopUpChooseFile(prefs)
	print strFile
	if (strlen(strFile)>0)
		strFileName = ParseFilePath(3, strFile, ":", 0, 0)
		//numEnd = strsearch(strFile, ".",(strlen(strFile)-1),1)-1
		//numStart=strsearch(strFile, ":",numEnd,1)
		//strFileName = strFile[numStart, numEnd]		
		//neuen Ordner erstellen mit Map-Name, Map hinzufügen zum globalen String.
		
		//Headings are in 2nd(0-1-2-->1) line, data starts in 2nd line, load all (0) from 1 to 2 columns, where d		
		LoadWave/A/D/J/K=1/L={1,2,0,0,2}/O/Q strFile 
		wave wavWaveLength	= $stringfromlist(0,S_waveNames)
		wave wavIntensity = $stringfromlist(1,S_waveNames)
	endif
	
	//EXIT
	PLEMd2exit()
	PLEMd2SavePackagePrefs(prefs)
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
	String fileFilters = "General Text Files (*.txt):.txt;"
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
Function PLEMd2d1Import([numKillWavesAfterwards])
	Variable numKillWavesAfterwards
	if (ParamIsDefault(numKillWavesAfterwards))
		numKillWavesAfterwards = 0
	endif
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



//Helper Functions

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

//return igor path to PLE-Map with the Number numPLEM in gstrMapsAvailable
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