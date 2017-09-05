#pragma TextEncoding = "UTF-8"		// For details execute DisplayHelpTopic "The TextEncoding Pragma"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.20 // use sdfr

static StrConstant cstrPLEMd2maps 	= ":maps"
static StrConstant cstrPLEMd2info 	= ":INFO"
static StrConstant cstrPLEMd2chirality = ":CHIRALITY"
static StrConstant cstrPLEMd2originals = ":ORIGINAL"

static Function/DF returnDataFolderReference(strDataFolder)
	String strDataFolder
	NewDataFolder/O $strDataFolder
	DFREF myDFR = $strDataFolder
	if(DataFolderRefStatus(myDFR) == 0) // DFR is invalid
		Abort "Data Folder could not be created"
	endif
	return myDFR
End

// Function returns DataFolder reference to package root.
static Function/DF returnPackageRoot()
	DFREF dfrPackage = returnDataFolderReference(cstrPLEMd2root)
	return dfrPackage
End

// Function returns DataFolder reference to base directory where maps are stored
static Function/DF returnMapsFolder()
	DFREF dfrPackage = returnPackageRoot()
	DFREF dfrMaps = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps)
	return dfrMaps
End

// Function returns DataFolder reference to base directory of map specified by strMap
Function/DF returnMapFolder(strMap)
	String strMap
	if(strlen(strMap) == 0)
		Abort "Can not create such a folder"
	endif
	DFREF dfrMaps = returnMapsFolder()
	DFREF dfrMap = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap)
	return dfrMap
End

// Function returns DataFolder reference to current map's info folder where NVAR and SVAR are saved
static Function/DF returnMapInfoFolder(strMap)
	String strMap
	if(strlen(strMap) == 0)
		abort
	endif
	DFREF dfrMap = returnMapFolder(strMap)
	DFREF dfrInfo = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap + cstrPLEMd2info)
	return dfrInfo
End

// Function returns DataFolder reference to current map's info folder where NVAR and SVAR are saved
Function/DF returnMapChiralityFolder(strMap)
	String strMap
	DFREF dfrMap = returnMapFolder(strMap)
	DFREF dfrChirality = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap + cstrPLEMd2chirality)
	return dfrChirality
End

// Function returns DataFolder reference where original data is stored
Function/DF returnMapOriginalFolder(strMap)
	String strMap
	DFREF dfrMap = returnMapFolder(strMap)
	DFREF dfrOriginal = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap + cstrPLEMd2originals)
	return dfrOriginal
End

// Function returns value of Global String "name" in "dataFolder"
static Function/S getGstring(name, dataFolder)
	String name
	DFREF dataFolder
	SVAR/Z/SDFR=dataFolder myVar = $name
	if(!SVAR_EXISTS(myVar))
		String/G dataFolder:$name = ""
		return ""
	else
		return myVar
	endif
End

// Function returns value of Global (numeric) Variable "name" in "dataFolder"
static Function getGvar(name, dataFolder)
	String name
	DFREF dataFolder
	NVAR/Z/SDFR=dataFolder myVar = $name
	if(!NVAR_EXISTS(myVar))
		Variable/G dataFolder:$name = NaN
		return NaN
	else
		return myVar
	endif
End

static Function/WAVE getWAVE(strWave, dfrMap)
	String strWave
	DFREF dfrMap
	WAVE/Z/SDFR=dfrMap myWave = $strWave
	if(!WaveExists(myWave))
		Make/N=0 dfrMap:$strWave
		WAVE/Z/SDFR=dfrMap myWave = $strWave
		if(!WaveExists(myWave))
			Abort "could not create wave"
		EndIf
	endif
	return myWave
End

static Function/WAVE getDoubleWAVE(strWave, dfrMap)
	String strWave
	DFREF dfrMap
	WAVE/D/Z/SDFR=dfrMap myWave = $strWave
	if(!WaveExists(myWave))
		Make/D/N=0 dfrMap:$strWave
		WAVE/D/Z/SDFR=dfrMap myWave = $strWave
		if(!WaveExists(myWave))
			Abort "could not create wave"
		EndIf
	endif
	return myWave
End

static Function/WAVE getTextWAVE(strWave, dfrMap)
	String strWave
	DFREF dfrMap
	WAVE/T/Z/SDFR=dfrMap myWave = $strWave
	if(!WaveExists(myWave))
		Make/T/N=0 dfrMap:$strWave
		WAVE/T/Z/SDFR=dfrMap myWave = $strWave
		if(!WaveExists(myWave))
			Abort "could not create wave"
		EndIf
	endif
	return myWave
End

// Function sets Global String "name" in "dataFolder" to "value"
static Function setGstring(name, value, dataFolder)
	String name, value
	DFREF dataFolder

	SVAR/Z/SDFR=dataFolder myVar = $name
	if(!SVAR_EXISTS(myVar))
		String/G dataFolder:$name
		SVAR/Z/SDFR=dataFolder myVar = $name
		if(!SVAR_EXISTS(myVar))
			Abort "Could not create global String"
		endif
	endif

	myVar = value
End

// Function sets Global Variable "name" in "dataFolder" to "value"
static Function setGvar(name, value, dataFolder)
	String name
	Variable value
	DFREF dataFolder

	NVAR/Z/SDFR=dataFolder myVar = $name
	if(!NVAR_EXISTS(myVar))
		Variable/G dataFolder:$name
		NVAR/Z/SDFR=dataFolder myVar = $name
		if(!NVAR_EXISTS(myVar))
			Abort "Could not create global Variable"
		endif
	endif

	myVar = value
End

// Abbreviated Functions for returning Variables from Package root.
Function/S getPackageString(name)
	String name
	DFREF dfrPackage = returnPackageRoot()
	return getGstring(name, dfrPackage)
End

Function getPackageVariable(name)
	String name
	DFREF dfrPackage = returnPackageRoot()
	return getGvar(name, dfrPackage)
End

Function setPackageString(name, value)
	String name, value
	DFREF dfrPackage = returnPackageRoot()
	setGstring(name, value, dfrPackage)
End

Function setPackageVariable(name, value)
	String name
	Variable value
	DFREF dfrPackage = returnPackageRoot()
	setGvar(name, value, dfrPackage)
End

// Abbreviated Functions for returning Variables from current map.
Function/S getMapString(strMap, var)
	String strMap, var
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	return getGstring(var, dfrInfo)
End

Function getMapVariable(strMap, var)
	String strMap, var
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	return getGvar(var, dfrInfo)
End

Function/WAVE getMapWave(strMap, strWave)
	String strMap, strWave
	DFREF dfrMap = returnMapFolder(strMap)
	WAVE myWave = getWAVE(strWave, dfrMap)
	return getWAVE(strWave, dfrMap)
End

Function setMapString(strMap, var, value)
	String strMap, var, value
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	setGstring(var, value, dfrInfo)
End

Function setMapVariable(strMap, var, value)
	String strMap, var
	Variable value
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	setGvar(var, value, dfrInfo)
End

// Abbreviated Functions for returning Variables from CHIRALITY FOLDER
Function/S getAtlasString(strMap, var)
	String strMap, var
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	return getGstring(var, dfrInfo)
End

Function getAtlasVariable(strMap, var)
	String strMap, var
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	return getGvar(var, dfrAtlas)
End

Function/WAVE getAtlasWave(strMap, strWave)
	String strMap, strWave
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	WAVE/D myWave = getDoubleWAVE(strWave, dfrAtlas)
	return myWave
End

Function/WAVE getAtlasTextWave(strMap, strWave)
	String strMap, strWave
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	WAVE/T myWave = getTextWAVE(strWave, dfrAtlas)
	return myWave
End

Function setAtlasString(strMap, var, value)
	String strMap, var, value
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	setGstring(var, value, dfrAtlas)
End

Function setAtlasVariable(strMap, var, value)
	String strMap, var
	Variable value
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	setGvar(var, value, dfrAtlas)
End

// Abbreviated Functions for Debugging
Function MapWaveSize(strMap, strWave, dimension)
	String strMap, strWave
	Variable dimension
	return Dimsize(getMapWave(strMap, strWave), dimension)
End

Function MapWaveExists(strMap, strWave)
	String strMap, strWave
	Variable dimension
	Wave myWave = getMapWave(strMap, strWave)
	return WaveExists(myWave)
End
