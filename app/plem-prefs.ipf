﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3

StrConstant PLEMd2PackageName = "PLEM-displayer2"
static StrConstant PLEMd2PrefsFileName = "PLEMd2Preferences.bin"
static Constant PLEMd2PrefsRecordID = 0
static Constant reserved = 70  // Reserved uint32 capacity for future use

// Global Preferences stored in Igor Folder
Structure PLEMd2Prefs
	uint32 version
	double panelCoords[4]
	uchar  strLastPath[256]
	char   strBasePath[40]
	char   strCorrectionPath[80]
	uint32 reserved[reserved]
EndStructure

//	Sets prefs structure to default values.
static Function PLEMd2DefaultPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	prefs.version = cPLEMd2Version

	prefs.panelCoords[0] = 5			// Left
	prefs.panelCoords[1] = 40		// Top
	prefs.panelCoords[2] = 5+190	// Right
	prefs.panelCoords[3] = 40+125	// Bottom

	prefs.strLastPath = SpecialDirPath("Documents", 0, 0, 0)
	prefs.strBasePath = ""
	prefs.strCorrectionPath = ""
	Variable i
	for(i = 0; i < reserved; i += 1)
		prefs.reserved[i] = 0
	endfor
End

// SyncPackagePrefsStruct(prefs)
// Syncs package prefs structures to match state of panel. Call this only if the panel exists.
static Function PLEMd2SyncPackagePrefsStruct(prefs)
	STRUCT PLEMd2Prefs &prefs

	// Panel does exists. Set prefs to match panel settings.
	prefs.version = cPLEMd2Version

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
	if(V_flag == 0)
		// Panel does not exist. Set prefs struct to default.
		PLEMd2DefaultPackagePrefsStruct(prefs)
	else
		// Panel does exists. Sync prefs struct to match panel state.
		PLEMd2SyncPackagePrefsStruct(prefs)
	endif
End

Function PLEMd2LoadPackagePrefs(prefs)
	STRUCT PLEMd2Prefs &prefs

	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences PLEMd2PackageName, PLEMd2PrefsFileName, PLEMd2PrefsRecordID, prefs

	// If error or prefs not found or not valid, initialize them.
	if(V_flag!=0 || V_bytesRead==0 || prefs.version!= cPLEMd2Version)
		//print "PLEMd2:LoadPackagePrefs: Loading from " + SpecialDirPath("Packages", 0, 0, 0)
		PLEMd2InitPackagePrefsStruct(prefs)	// Set based on panel if it exists or set to default values.
		PLEMd2SavePackagePrefs(prefs)		// Create initial prefs record.
	endif
End

Function PLEMd2SavePackagePrefs(prefs)
	STRUCT PLEMd2Prefs &prefs
	//print "PLEMd2:SavePackagePrefs: Saving to " + SpecialDirPath("Packages", 0, 0, 0)
	SavePackagePreferences PLEMd2PackageName, PLEMd2PrefsFileName, PLEMd2PrefsRecordID, prefs
End

// Save the location of the base path where all ibw files are saved.
//
// DisplayHelpTopic "Symbolic Paths"
Function PLEMd2SetBasePath()
	String strBasePath

	Struct PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)

	strBasePath = prefs.strBasePath
	NewPath/O/Q/Z PLEMbasePath, strBasePath
	if(!V_flag)
		PathInfo/S PLEMbasePath
	endif

	NewPath/O/Q/Z/M="Set PLEM base path" PLEMbasePath
	if(V_flag)
		return 0 // user canceled
	endif

	PathInfo PLEMbasePath
	strBasePath = S_path
	if(!V_flag)
		return 0 // invalid path
	endif

	GetFileFolderInfo/Q/Z=1 strBasePath
	if(!V_flag && V_isFolder)
		prefs.strBasePath = strBasePath
		PLEMd2SavePackagePrefs(prefs)
	endif
End

// Save the location of the base path where all ibw files are saved.
//
// DisplayHelpTopic "Symbolic Paths"
Function PLEMd2SetCorrectionPath()
	String strCorrectionPath

	Struct PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)

	strCorrectionPath = prefs.strCorrectionPath
	NewPath/O/Q/Z PLEMCorrectionPath, strCorrectionPath
	if(!V_flag)
		PathInfo/S PLEMCorrectionPath
	endif

	NewPath/O/Q/Z/M="Set PLEMCorrectionPath path" PLEMCorrectionPath
	if(V_flag)
		return 0 // user canceled
	endif

	PathInfo PLEMCorrectionPath
	strCorrectionPath = S_path
	if(!V_flag)
		return 0 // invalid path
	endif

	GetFileFolderInfo/Q/Z=1 strCorrectionPath
	if(!V_flag && V_isFolder)
		prefs.strCorrectionPath = strCorrectionPath
		PLEMd2SavePackagePrefs(prefs)
	endif
End