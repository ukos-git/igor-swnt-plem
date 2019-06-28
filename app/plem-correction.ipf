#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Constant PLEM_SYSTEM_LIQUID = 0
Constant PLEM_SYSTEM_MICROSCOPE = 1

// @hacky system identification.
Function PLEMd2getSystem(strUser)
	String strUser

	strswitch(TrimString(strUser))
		case "the master of microscopy":
		case "unknown":
			return PLEM_SYSTEM_MICROSCOPE
		case "":
			return -1
		default:
			return PLEM_SYSTEM_LIQUID
	endswitch
End

Function/S PLEMd2getGratingString(numGrating, numSystem)
	Variable numGrating, numSystem

	switch(numSystem)
		case PLEM_SYSTEM_LIQUID:
			switch(numGrating)
				case 1: // 150 l/mm 1055nm Blaze wl
					return "grating150blz1055pplane"
				case 2: // 150 l/mm 800nm Blaze wl
					return "grating150blz800pplane"
				case 3: // 150 l/mm 1250nm Blaze wl
					return "grating150blz1250pplane"
				default:
					break
			endswitch
			break
		case PLEM_SYSTEM_MICROSCOPE:
			switch(numGrating)
				case 1: // 300 l/mm 500nm Blaze wl
					return "grating300blz500"
				case 2: // 300 l/mm 1200nm Balze wl
					return "grating300blz1200"
				case 3: // 150 l/mm 1250nm Blaze wl
					return "grating150blz1250pplane"
				default:
					break
			endswitch
			break
		default:
	endswitch

	return "_none_"
End

// get the file to load as quantum efficiency correction
// @todo: cooling is currently fixed.
Function/S PLEMd2getDetectorQEString(numDetector, numCooling, numSystem)
	Variable numDetector, numCooling, numSystem

	switch(numSystem)
		case PLEM_SYSTEM_LIQUID:
			switch(numDetector)
				case 0: // Andor Newton (70°C)
					return "qeNewtonDU920POEm75"
				case 1: // Andor iDus
					return "qeIdusDU491A17m90"
				default:
					break
			endswitch
			break
		case PLEM_SYSTEM_MICROSCOPE:
			switch(numDetector)
				case 0: // Andor Newton (90 °C)
					return "qeNewtonDU920POEm100"
				case 1: // Andor iDus
					return "qeIdusDU491A17m90"
				case 2: // Andor Clara
				case 3: // Xenics Xeva
				default:
					break
			endswitch
			break
		default:
	endswitch

	return "_none_"
End

// get the filter for correcting excitation
Function/S PLEMd2getFilterExcString(numSystem, numDetector)
	Variable numSystem, numDetector

	switch(numSystem)
		case PLEM_SYSTEM_LIQUID:
			break
		case PLEM_SYSTEM_MICROSCOPE:
			switch(numDetector)
				case 0: // Andor Newton
				case 1: // Andor iDus
					return "filterChroma760refl"
				case 2: // Andor Clara
				case 3: // Xenics Xeva
				default:
					break
			endswitch
			break
		default:
	endswitch

	return "_none_"
End

// get the filter for correcting excitation
Function/S PLEMd2getFilterEmiString(numSystem, numDetector)
	Variable numSystem, numDetector

	switch(numSystem)
		case PLEM_SYSTEM_LIQUID:
			break // currently no check for liquid system filter wheel
		case PLEM_SYSTEM_MICROSCOPE:
			switch(numDetector)
				case 0: // Andor Newton
				case 1: // Andor iDus
					return "fg830"
				case 2: // Andor Clara
				case 3: // Xenics Xeva
				default:
					break
			endswitch
			break
		default:
	endswitch

	return "_none_"
End

// Get the (un-interpolated) grating wave for the current PLEM
// Loads the wave from PLEMCorrectionPath if not present in the current experiment
Function/WAVE PLEMd2getGrating(stats)
	Struct PLEMd2stats &stats

	String strGrating
	
	if(stats.numDetector == 2 || stats.numDetector == 3)
		return $"" // clara and xeva
	endif

	strGrating = PLEMd2getGratingString(stats.numGrating, PLEMd2getSystem(stats.strUser))

	DFREF dfr = DataFolderReference(cstrPLEMd2correction)
	WAVE/Z wv = dfr:$strGrating
	if(WaveExists(wv))
		return wv
	endif

	PLEMd2LoadCorrectionWaves(strGrating)

	WAVE wv = dfr:$strGrating
	return wv
End

// Get the (un-interpolated) quantum efficiency wave for the current PLEM
// Loads the wave from PLEMCorrectionPath if not present in the current experiment
Function/WAVE PLEMd2getQuantumEfficiency(stats)
	Struct PLEMd2stats &stats

	String strDetector

	if(stats.numDetector == 2 || stats.numDetector == 3)
		return $"" // clara and xeva
	endif

	strDetector = PLEMd2getDetectorQEstring(stats.numDetector, stats.numCooling, PLEMd2getSystem(stats.strUser))

	DFREF dfr = DataFolderReference(cstrPLEMd2correction)
	WAVE/Z wv = dfr:$strDetector
	if(WaveExists(wv))
		return wv
	endif

	PLEMd2LoadCorrectionWaves(strDetector)

	WAVE wv = dfr:$strDetector
	return wv
End

Function/WAVE PLEMd2getFilterExc(stats)
	Struct PLEMd2stats &stats

	String strFilter

	if(stats.numDetector == 2 || stats.numDetector == 3)
		return $"" // clara and xeva
	endif

	strFilter = PLEMd2getFilterExcString(PLEMd2getSystem(stats.strUser), stats.numDetector)

	DFREF dfr = DataFolderReference(cstrPLEMd2correction)
	WAVE/Z wv = dfr:$strFilter
	if(WaveExists(wv))
		return wv
	endif

	PLEMd2LoadCorrectionWaves(strFilter)

	WAVE wv = dfr:$strFilter
	return wv
End

Function/WAVE PLEMd2getFilterEmi(stats, [strFilter])
	Struct PLEMd2stats &stats
	String strFilter

	if(stats.numDetector == 2 || stats.numDetector == 3)
		return $"" // clara and xeva
	endif

	if(ParamIsDefault(strFilter))
		strFilter = PLEMd2getFilterEmiString(PLEMd2getSystem(stats.strUser), stats.numDetector)
	endif

	DFREF dfr = DataFolderReference(cstrPLEMd2correction)
	WAVE/Z wv = dfr:$strFilter
	if(WaveExists(wv))
		return wv
	endif

	PLEMd2LoadCorrectionWaves(strFilter)

	WAVE wv = dfr:$strFilter
	return wv
End

Function/WAVE PLEMd2getReflMirror()
	String strMirror = "reflSilver"

	DFREF dfr = DataFolderReference(cstrPLEMd2correction)
	WAVE/Z wv = dfr:$strMirror
	if(WaveExists(wv))
		return wv
	endif

	PLEMd2LoadCorrectionWaves(strMirror)

	WAVE wv = dfr:$strMirror
	return wv
End


Function PLEMd2SetEmissionFilter(stats, [filter])
	Struct PLEMd2stats &stats
	String filter

	// emission filter
	if(ParamIsDefault(filter))
		WAVE/Z wv = PLEMd2getFilterEmi(stats)
	else
		WAVE/Z wv = PLEMd2getFilterEmi(stats, strFilter = filter)
	endif

	WAVE/Z wvX = $(GetWavesDataFolder(wv, 2) + "_wl")
	if(WaveExists(wvX))
		Interpolate2/T=1/I=3/Y=stats.wavFilterEmi/X=stats.wavWavelength wvX, wv
	else
		Interpolate2/T=1/I=3/Y=stats.wavFilterEmi/X=stats.wavWavelength wv
	endif
	WAVE mirror = PLEMd2getReflMirror()
	WAVE mirrorX = $(GetWavesDataFolder(mirror, 2) + "_wl")
	Duplicate/FREE stats.wavFilterEmi mirrorEmi
	Interpolate2/T=1/I=3/Y=mirrorEmi/X=stats.wavExcitation mirrorX, mirror
	stats.wavFilterEmi /= (mirrorEmi[p]^2)
	if(PLEMd2getSystem(stats.strUser) == PLEM_SYSTEM_MICROSCOPE)
		stats.wavFilterEmi /= mirrorEmi[p] // one more mirror on Microscope
	endif
End

Function PLEMd2LoadCorrectionWaves(strCorrectionWave)
	String strCorrectionWave

	Variable err, i, j, numFiles
	Variable numLoaded = 0
	String ibwList, ibwFile

	PLEMd2LoadGratingPath()
	PathInfo PLEMCorrectionPath
	if(!V_flag)
		Abort "could not find path"
	endif

	ibwList = IndexedFile(PLEMCorrectionPath, -1, ".ibw")
	ibwList = ListMatch(ibwList, strCorrectionWave + "*")
	numFiles = ItemsInList(ibwList)

	DFREF saveDFR = GetDataFolderDFR()
	DFREF dfr = DataFolderReference(cstrPLEMd2correction)
	SetDataFolder dfr
	for(i = 0; i < numFiles; i += 1)
		ibwFile = StringFromList(i, ibwList)
		try
			GetFileFolderInfo/P=PLEMCorrectionPath/Q/Z=1 ibwFile
			if(!V_flag && V_isFile)
				LoadWave/Q/N/O/H/P=PLEMCorrectionPath ibwFile; AbortOnRTE
				numLoaded += V_Flag
			endif
		catch
			err = GetRTError(1)
		endtry
	endfor
	SetWaveLock 1, allinCDF
	SetDataFolder saveDFR

	PathInfo PLEMCorrectionPath
	printf "%d/%d files matching %s loaded from %s.\r", numLoaded, numFiles, strCorrectionWave, S_path
	return numLoaded
End

// create PLEMCorrectionPath from package prefs
Function PLEMd2LoadGratingPath()
	String strPath

	Struct PLEMd2Prefs prefs

	PathInfo PLEMCorrectionPath
	if(V_flag)
		return 0
	endif

	PLEMd2LoadPackagePrefs(prefs)
			
	// DisplayHelpTopic "Symbolic Paths"
	strPath = prefs.strCorrectionPath
	GetFileFolderInfo/Q/Z=1 strPath
	if(V_flag && !V_isFolder)
		Abort "Could not load symbolic path for gratings"
	endif

	PathInfo strPath
	if(!V_flag)
		NewPath/O/Q/Z PLEMCorrectionPath, strPath
	endif

	return 0
End
