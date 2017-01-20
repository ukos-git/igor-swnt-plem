//PLEM-displayer2_v0
//Programmed by Matthias Kastner
//Date 13.03.2015
//Version 0: Skeleton

#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "PLE-Map", dynamic //create menu bar entry
	"PLEMapDisplayer2", PLEMd2()
	SubMenu "PLEMapDisplayer1"
		"Import", PLEMd2DeprecatedImport()
		"Import and Kill", PLEMd2DeprecatedImport(1)
	End
	SubMenu "PLEM" //List all available Maps in current project
		PLEMd2Menu(0), PLEMd2Display(0)
		PLEMd2Menu(1), PLEMd2Display(1)
		PLEMd2Menu(2), PLEMd2Display(2)
		PLEMd2Menu(3), PLEMd2Display(3)
	End
End

Function PLEMd2initVar()
	//Init Data Folder
	String strSaveDataFolder = GetDataFolder(1)
	SetDataFolder root:
	String/G gstrPLEMd2root 	= "root:PLEMd2"
	NewDataFolder/O/S $gstrPLEMd2root
	String/G gstrMapsFolder = gstrPLEMd2root + ":" + "maps"
	NewDataFolder/O	 $gstrMapsFolder
	String/G gstrSaveDataFolder = strSaveDataFolder	//only for initialization. really set in PMRinit()
	
	//Specify source for correction files	
	String/G gstrPathBase	= "C:Users:mak24gg:Documents:WaveMetrics:Igor Pro 6 User Files:User Procedures:PLEMd2"

	//Global Wave Names for correction files
	String/G gstrCCD1250		= gstrPLEMd2root + ":" + "CCD1250"
	String/G gstrInGaAs1250	= gstrPLEMd2root + ":" + "InGaAs1250"
	
	//Present Maps
	String/G gstrMapsAvailable = ""	
	Variable/G gnumMapsAvailable	= 0

		
	//set a variable in root folder to recognize if the module was initialized.
	//if initialized then don't overwrite with standard values.
	SetDataFolder root:
	Variable/G gnumPLEMd2IsInit = 1
	SetDataFolder $gstrPLEMd2root
End

Function/S PLEMd2Menu(numPLEM)
	Variable numPLEM		

	String strReturn = ""
	String strSaveDataFolder = GetDataFolder(1)
	SetDataFolder root:		

	if (FindListItem("gnumPLEMd2IsInit",VariableList("*",";",4)) != -1)
		NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
		SVAR gstrPLEMd2root = root:gstrPLEMd2root
		SVAR gstrMapsAvailable = $(gstrPLEMd2root + ":gstrMapsAvailable")
		NVAR gnumMapsAvailable	 = $(gstrPLEMd2root + ":gnumMapsAvailable")
	
		if (gnumPLEMd2IsInit == 1)
			if (numPLEM<gnumMapsAvailable)
				strReturn = StringFromList(numPLEM, gstrMapsAvailable)
			endif
		endif
	endif
	
	SetDataFolder $strSaveDataFolder	
	return strReturn
End

Function PLEMd2isInit()
	NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
	if (gnumPLEMd2IsInit==1)
		return 1
	else
		return 0
	endif
End

//The Init and exit Function should be called before and after a menu item is called.
Function PLEMd2init()
	//remember current path
	String strSaveDataFolder = GetDataFolder(1)			

	if (PLEMd2isInit()==0)
		PLEMd2initVar()
		print "PLEMd2: intialization"
	endif
	
	//Change DataFolder to Project Root
	SVAR gstrPLEMd2root	= root:gstrPLEMd2root	
	SetDataFolder $gstrPLEMd2root	
	
	//Save Original Path in Project Root
	SVAR gstrSaveDataFolder	= strSaveDataFolder			
End

Function PLEMd2reset()
	print "PLEMd2: reset"
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
	//reset for testing purose
	PLEMd2reset()
	PLEMd2init()
	PLEMd2exit()
End

Function PLEMd2DeprecatedImport([numKillWavesAfterwards])
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
	
	Variable numMaps, numWaves, numSearchstrings
	
	Variable i,j,k
	
	strMaps = PLEMd2DeprecatedFind()
	numMaps = PLEMd2GetListSize(strMaps)
	
	print "found " + num2str(numMaps) + " old map(s): " + strMaps
	
	//there should now also be the following waves
	//*_0
	//*_bg_0
	//*_corr_m_0
	//PLE_map_*
	strSearchStrings	 = "_bg_*;_corr_m_*;_*"
	numSearchstrings = PLEMd2GetListSize(strSearchStrings)
	for (i=0;i<numMaps;i+=1)
		SetDataFolder $gstrMapsFolder
		strMap = StringFromList(i, strMaps)
		//Copy Map
		wave wavPLEM = $("root:PLE_map_" + strMap)
		if (WaveExists(wavPLEM))
			NewDataFolder/O/S $strMap
			Duplicate/O wavPLEM PLEM
			if (numKillWavesAfterwards == 1)
				Killwaves/Z wavPLEM
			endif
		endif
		//Copy Wavelength Wave
		wave wavWavelength = $("root:wavelength_" + strMap)
		if (WaveExists(wavWavelength))
			if (!WaveExists(wavPLEM))
				NewDataFolder/O/S $strMap
			endif
			Duplicate/O wavWavelength WL
			if (numKillWavesAfterwards == 1)
				Killwaves/Z wavWavelength
			endif			
		endif
		//Copy Original Data Waves
		for (k=0;k<numSearchstrings;k+=1)
			strSearchString = StringFromList(k, strSearchStrings)
			SetDataFolder root:
			strWaves = WaveList(strMap + strSearchString,";","")
			numWaves = PLEMd2GetListSize(strWaves)
			SetDataFolder $(gstrMapsFolder + ":" + strMap)
			for (j=0;j<numWaves;j+=1)
				strWave = StringFromList(j, strWaves)
				wave wavDummy = $("root:" + strWave)
				if (WaveExists(wavDummy))
					Duplicate/O wavDummy $(strWave)
					if (numKillWavesAfterwards == 1)
						Killwaves/Z wavDummy
					endif
				endif				
			endfor
		endfor
		//Append Current Map to List of Maps
		if (FindListItem(strMap,gstrMapsAvailable) == -1)
			gstrMapsAvailable += strMap + ";"
		endif
	endfor
	gnumMapsAvailable = PLEMd2GetListSize(gstrMapsAvailable)
	PLEMd2exit()
End

Function/S PLEMd2DeprecatedFind()
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