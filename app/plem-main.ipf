#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma IgorVersion=8

// Programmed by Matthias Kastner
// mail@matthias-kastner.de
// https://github.com/ukos-git/igor-swnt-plem
//
// LICENSE: MIT
//

// requires igor-common-utilites
// https://github.com/ukos-git/igor-common-utilities
#include "common-utilities"

// Variables for current Project only. See also the LoadPreferences towards the end of the procedure for additional settings that are saved system-wide.
Constant 	cPLEMd2Version = 3003
StrConstant cstrPLEMd2root = "root:PLEMd2"

Function PLEMd2initVar()
	print "PLEMd2initVar: intialization of global variables"
	//Init Data Folder
	String strSaveDataFolder = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S $cstrPLEMd2root

	//Save Data Folder befor execution of this program so we can always switch after our program terminates
	//definition here only for initialization.
	//during run time it is set in PMRinit() but we will already switch folders here. so better also here safe the path.
	String/G gstrSaveDataFolder = strSaveDataFolder

	//Specify source for new correction files (displayer2) and old files (displayer1 or Tilman's original)
	String/G gstrPathBase	= SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:PLEMd2:"

	//Global Wave Names for correction files (maybe this is better done dynamically)
	String/G gstrCCD1250		= cstrPLEMd2root + ":" + "CCD1250"
	String/G gstrInGaAs1250	= cstrPLEMd2root + ":" + "InGaAs1250"

	String/G gstrPLEMd1root = cstrPLEMd2root + ":" + "PLEMd1"
	String/G gstrMapsFolder = cstrPLEMd2root + ":" + "maps"

	//Correction Waves from old PLEM-displayer1
	NewDataFolder/O/S	 $gstrPLEMd1root
	String/G gstrPLEMd1PathBase	 = SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:Korrekturkurven:"
	//Load only specified waves from folder. Leave blank if all waves from directory above should be loaded.
	String/G gstrPLEMd1CorrectionToLoad = "1200 nm Blaze & CCD @ +20 °C.txt;" + "1200 nm Blaze & CCD @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "1200 nm Blaze & InGaAs @ +25 °C.txt;" + "1200 nm Blaze & InGaAs @ -25 °C.txt;" + "1200 nm Blaze & InGaAs @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "1250 nm Blaze & CCD @ -90 °C.txt;" + "1250 nm Blaze & InGaAs @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "500 nm Blaze & CCD @ +20 °C.txt;" + "500 nm Blaze & CCD @ -90 °C.txt;"
	gstrPLEMd1CorrectionToLoad += "760 nm Strahlenteiler (Chroma) Abs.txt;" + "760 nm Strahlenteiler (Chroma) Em.txt;"

	String/G gstrPLEMd2corrections = SpecialDirPath("Igor Pro User Files", 0, 0, 0 ) + "User Procedures:corrections:"

	//the following waves and strings should be loaded to root if PLEMd1 is loaded. We use the info for killing the vars.
	String/G gstrPLEMd1strings = "file_path;file_extension;file_name;left_PLE;right_PLE;"
	String/G gstrPLEMd1variables = "background;start_wl;end_wl;increment;multiple;single;chroma_abs;chroma_em;nkt;power;photon;fermi_parameter;grating_detector;checked_a;checked_b;checked_c;checked_d;checked_e;mode;"
	String/G gstrPLEMd1waves = "WL_500_CCD_minus90;E_500_CCD_minus90;WL_1200_CCD_minus90;E_1200_CCD_minus90;WL_1250_CCD_minus90;E_1250_CCD_minus90;WL_1200_InGaAs_minus90;E_1200_InGaAs_minus90;WL_1250_InGaAs_minus90;E_1250_InGaAs_minus90;chroma_x_abs;chroma_y_abs;chroma_x_em;chroma_y_em;correction_x;correction_y;"
	String/G gstrPLEMd1CorrectionAvailable = ""
	Variable/G gnumPLEMd1IsInit = 0

	SetDataFolder $cstrPLEMd2root
	//Maps: Create Folder and Initialize Strings where we store the maps of the current project

	NewDataFolder/O	 $gstrMapsFolder
	String/G gstrMapsAvailable = ""
	Variable/G gnumMapsAvailable = 0
	PLEMd2MapStringReInit()

	//save current init-version in project folder.
	Variable/G gnumPLEMd2Version = cPLEMd2Version
	//set a variable in root folder to recognize if the module was initialized.
	SetDataFolder root:
	Variable/G gnumPLEMd2IsInit = 1
	SetDataFolder $cstrPLEMd2root
End

Function PLEMd2isInitialized()
	NVAR/Z gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
	if(!NVAR_EXISTS(gnumPLEMd2IsInit))
		return 0
	endif
	return gnumPLEMd2IsInit
End

// check if the Experiment was created with the same version as the program.
//
// Note: use PLEMd2init() for initialization
Function PLEMd2CheckExperimentVersion()
	DFREF packageRoot = $cstrPLEMd2root
	if(!DataFolderRefStatus(packageRoot))
		return 0
	endif

	NVAR/Z ExperimentVersion = packageRoot:gnumPLEMd2Version
	if(ExperimentVersion == cPLEMd2Version)
		return 1
	endif
End

// automatically initialize the current experiment to default values if necessary
Function PLEMd2initialize()
	if(PLEMd2isInitialized() && PLEMd2CheckExperimentVersion())
		return 0 // already initialized.
	endif

	PLEMd2Clean()
	PLEMd2initVar()
End

Function PLEMd2reset()
	print "PLEMd2reset: reset"

	Variable i, numMaps

	if(PLEMd2isInitialized())
		NVAR gnumPLEMd2IsInit = root:gnumPLEMd2IsInit
		gnumPLEMd2IsInit = 0
	endif
	PLEMd2initialize()

	// reset IBW files
	numMaps = PLEMd2MapStringReInit()
	for(i = 0; i < numMaps; i += 1)
		PLEMd2ProcessIBW(PLEMd2strPLEM(i))
	endfor
End

// cleanup package root
Function PLEMd2Clean()
	String strVariables, strStrings, strAvailable
	Variable i, numAvailable

	DFREF dfrSave = GetDataFolderDFR()
	DFREF packageRoot = $cstrPLEMd2root

	// we assume that all paths belong to previous versions of the program.
	if(PLEMd2CheckExperimentVersion())
		KillPath/A/Z
	endif

	if(!DataFolderRefStatus(packageRoot))
		return 0
	endif

	SetDataFolder packageRoot

	strVariables  = VariableList("V_*", ";", 4)	 // Scalar Igor Variables
	strVariables += VariableList("*", ";", 2)	//System Variables
	strStrings    = StringList("S_*", ";") // Scalar Igor Strings

	// @todo add all variables except those that are needed in the current Experiment Version

	numAvailable = ItemsInList(strVariables)
	for(i = 0; i < numAvailable; i += 1)
		strAvailable = StringFromList(i, strVariables)
		Killvariables/Z $strAvailable
	endfor

	numAvailable = ItemsInList(strStrings)
	for(i = 0; i < numAvailable; i += 1)
		strAvailable = StringFromList(i, strStrings)
		Killstrings/Z $strAvailable
	endfor

	SetDataFolder dfrSave
End

Function PLEMd2Open([strFile, display])
	String strFile
	Variable display

	String strFileName, strFileType, strPartialPath
	String strWave, strPLEM

	// this function serves as entrypoint for most activities
	PLEMd2initialize()

	if(ParamIsDefault(strFile))
		strFile = PLEMd2PopUpChooseFile()
	endif
	if(ParamIsDefault(display))
		display = 1
	endif

	// check for valid filename
	GetFileFolderInfo/Q/Z=1 strFile
	if(!!V_Flag || !V_isFile)
		Abort "PLEMd2Open: Invalid filename"
	endif

	strFileName = ParseFilePath(3, strFile, ":", 0, 0)
	strFileType = ParseFilePath(4, strFile, ":", 0, 0)
	strPLEM = CleanupName(strFileName, 0)

	// create dfr for loaded data
	DFREF dfrPLEM = PLEMd2MapFolder(strPLEM)
	NewDataFolder/O dfrPLEM:ORIGINAL
	DFREF dfrLoad = dfrPLEM:ORIGINAL

	// Loading Procedure (LoadWave is not dfr aware)
	strswitch(strFileType)
		case "ibw":
			// remove lock
			if(CountObjectsDFR(dfrLoad, 1) == 1)
				WAVE wavIBW = dfrLoad:$GetIndexedObjNameDFR(dfrLoad, 1, 0)
				SetWaveLock 0, wavIBW
			endif

			// load wave to dfrLoad using original name from IBW (overwrite)
			DFREF dfrSave = GetDataFolderDFR()
			SetDataFolder dfrLoad
			KillWaves/A
			KillStrings/A
			LoadWave/Q/N/O strFile
			if(V_flag != 1)
				KillWaves/A
				SetDataFolder dfrSave
				Abort "PLEMd2Open: Error Loaded more than one or no Wave from Igor Binary File"
			endif
			SetDataFolder dfrSave

			// reference loaded wave and lock it.
			WAVE/Z wavIBW = PLEMd2wavIBW(strPLEM)
			SetWaveLock 1, wavIBW
			String/G dfrLoad:$NameOfWave(wavIBW) = WaveHash(wavIBW, 1)

			break
		default:
			Abort "PLEMd2Open: Could not open file"
		break
	endswitch

	// cleanup old IBW
	WAVE/Z oldIBW = dfrPLEM:IBW
	if(WaveExists(oldIBW))
		SetWaveLock 0, oldIBW
		KillWaves/Z oldIBW
	endif

	// init stats
	PLEMd2statsInitialize(strPLEM)

	// create and display waves
	PLEMd2ProcessIBW(strPLEM)
	if(display)
		PLEMd2Display(strPLEM)
	endif
End

Function PLEMd2ProcessIBW(strPLEM)
	String strPLEM

	WAVE/Z wavIBW = PLEMd2wavIBW(strPLEM)
	if(WaveExists(wavIBW))
		PLEMd2ExtractInfo(strPLEM, wavIBW)
		PLEMd2ExtractIBW(strPLEM, wavIBW)
	else
		print "Error: Reload IBW from disk using Plemd2Open() for full IBW processing"
	endif

	PLEMd2BuildMaps(strPLEM)
End

Function/DF PLEMd2ExtractWaves(wavIBW)
	WAVE wavIBW

	String strWaveNames, strWaveExtract
	Variable numTotalX, numTotalY, i, j

	// load waves from IBW file to dfr
	DFREF dfr = NewFreeDataFolder()

	// check consistency
	strWaveNames = PLEMd2ExtractWaveList(wavIBW)
	numTotalX	= DimSize(wavIBW, 0)
	numTotalY	= DimSize(wavIBW, 1)
	if(numTotalY == 0 || numTotalX == 0)
		Abort "PLEMd2ExtractWaves: Binary File has no waves"
	endif
	if(numTotalY != ItemsInList(strWaveNames))
		print "PLEMd2ExtractWaves: Error WaveNames not correct in WaveNotes."
		PLEMd2FixWavenotes(wavIBW)
		strWaveNames = PLEMd2ExtractWaveList(wavIBW)
	endif
	if(numTotalY != ItemsInList(strWaveNames))
		printf "PLEMd2ExtractWaves: Missmatch in wavenames:\r%s\rWaveNames not correct in WaveNote. Counting %d data columns and %d labels.\rManual interaction needed.", strWaveNames, numTotalY, ItemsInList(strWaveNames)
	endif

	//Extract Columns from Binary Wave and give them proper names
	for(i = 0; i < numTotalY; i += 1)
		strWaveExtract = StringFromList(i, strWaveNames)
		Make/D/O/N=(numTotalX) dfr:$strWaveExtract/WAVE=wv
		wv[] = wavIBW[p][i]
		WaveClear wv
	endfor

	return dfr
End

Function PLEMd2CopyWaveNote(wavIBW, wv)
	WAVE wavIBW, wv

	String strHeader

	strHeader = Note(wavIBW)
	strHeader = strHeader[0,(strsearch(strHeader, "IGOR0",0)-1)] // clean WaveNotes
	Note/K/NOCR wv strHeader
End

Function PLEMd2ExtractIBW(strPLEM, wavIBW)
	String strPLEM
	WAVE wavIBW

	Struct PLEMd2stats stats
	String strWaveBG, strWavePL
	Variable numExcitationFrom, numExcitationTo
	Variable dim0, dim1
	Variable i,j, numItems

	DFREF packageRoot = $cstrPLEMd2root
	SVAR gstrMapsFolder = packageRoot:gstrMapsFolder

	if(!PLEMd2MapExists(strPLEM))
		Abort "PLEMd2ExtractIBW: Map does not exist"
	endif

	//There are 3 different structures for DATA
	//1) WAVES: WL, BG, PL ...
	//2) WAVES: WL, BG_498_502, PL_498_502,BG_502_506,PL_502_506 ...
	//3) WAVES: WL, BG, PL_498_502,PL_502_506,PL_506_510,PL_510_514 ...
	//Possibilities handled:
	//1)+3) stats.strbackground = single --> wavexists(background)
	//2) stats. strBackground = multiple --> count(BG_*) = count (PL_*)
	//4) image mode:
	//   special case of 1) size of WL wave is no equal to BG or PL.

	// collect strWavePL und strWaveBG. WaveList is not DFR aware
	DFREF saveDFR = GetDataFolderDFR()
	PLEMd2statsLoad(stats, strPLEM)
	DFREF dfr = PLEMd2ExtractWaves(wavIBW)
	SetDataFolder dfr
	switch(stats.numbackground)
		case 0:
		case 1:
			//single background
			strWavePL = WaveList("PL*", ";", "")
			// fill strWaveBG with dummy "BG"
			numItems = ItemsInList(strWavePL, ";")
			strWaveBG = ""
			for(i = 0; i < numItems; i += 1)
				strWaveBG += "BG;"
			endfor

			wave/Z wavBackground = BG
			if(!WaveExists(wavBackground))
				print "PLEMd2ExtractIBW: Error, wave BG does not exist in folder :ORIGINAL"
			endif
			WaveClear wavBackground

			break
		case 2:
			//multiple background
			strWavePL = WaveList("PL_*", ";", "")
			strWaveBG = WaveList("BG_*", ";", "")
			break
		default:
			print "PLEMd2ExtractIBW: Background Case not handled"
			return 0
			break
	endswitch
	SetDataFolder saveDFR

	// updating stats (TotalX and TotalY)
	if(ItemsInList(strWaveBG, ";") != ItemsInList(strWavePL, ";"))
		Abort "PLEMd2ExtractIBW: Error Size Missmatch between Background Maps and PL Maps"
	endif
	stats.numPLEMTotalY = ItemsInList(strWavePL, ";")

	stats.numCalibrationMode = 0
	if(stats.numPLEMTotalY == 1)
		stats.numCalibrationMode = 1
	endif

	wave wavWavelength = dfr:WL
	if(!WaveExists(wavWavelength))
		Abort "PLEMd2ExtractIBW: Wavelength Wave not found within ORIGINAL Folder"
	endif
	stats.numPLEMTotalX = NumPnts(wavWavelength)

	if(stats.numReadOutMode == 1)
		// quick fix for image mode on cameras
		if(stats.numPLEMTotalX == 81919) // xenics xeva
			stats.numDetector = 3
			stats.numPLEMTotalY = 256
			stats.numPLEMTotalX = 320
		else
			stats.numDetector = 2 // andor clara
			stats.numPLEMTotalY = 1040
			stats.numPLEMTotalX = 1392
		endif
	endif

	// Redimension the Waves to proper size
	dim0 = stats.numPLEMTotalX
	dim1 = stats.numPLEMTotalY
	Redimension/N=(dim0, dim1) stats.wavPLEM, stats.wavMeasure, stats.wavBackground
	PLEMd2CopyWaveNote(wavIBW, stats.wavPLEM)
	if(stats.numReadOutMode == 1)
		dim0 = 0 // no wavelength
		dim1 = 1 // save power and excitation wl
	endif
	Redimension/N=(dim0) stats.wavWavelength, stats.wavGrating
	Redimension/N=(dim1) stats.wavExcitation, stats.wavYpower, stats.wavYphoton

	// set x-Scaling
	stats.wavWavelength = wavWavelength

	// Grating Waves (requires wavWavelength)
	String strGratingWave = PLEMd2d1CorrectionConstructor(stats.numGrating,stats.numDetector,stats.numCooling)
	if(!cmpstr(strGratingWave, ""))
		stats.wavGrating = 1
		print "PLEMd2ExtractIBW: Grating Wave was set to 1"
	else
		Duplicate/FREE $(ReplaceString("DUMMY", strGratingWave, "E_",1,1)) wavYgrating
		Duplicate/FREE $(ReplaceString("DUMMY", strGratingWave, "WL_",1,1)) wavXgrating
		interpolate2/T=1/I=3/Y=stats.wavGrating/X=stats.wavWavelength wavXgrating, wavYgrating
	endif

	// different handling for spectra in calibration mode (1) and for maps (0)
	if(stats.numCalibrationMode == 1)
		wave wavMeasure 	= dfr:$(StringFromList(0, strWavePL))
		wave wavBackground 	= dfr:$(StringFromList(0, strWaveBG))

		if(stats.numReadOutMode == 1)
			// image mode. currently no information for images is saved
			Redimension/N=(stats.numPLEMTotalY * stats.numPLEMTotalX) wavMeasure, wavBackground // workaround for XEVA (2 pixel missing)
			stats.wavMeasure = wavMeasure[p + stats.numPLEMTotalX * q]
			stats.wavBackground = wavBackground[p + stats.numPLEMTotalX * q]
		else
			stats.wavMeasure 	= wavMeasure
			stats.wavBackground = wavBackground
		endif

		if(stats.numReadOutMode == 1)
			// image mode. currently no information for images is saved
			stats.wavMeasure = wavMeasure[p + stats.numPLEMTotalX * q]
			stats.wavBackground = wavBackground[p+stats.numPLEMTotalX*q]
		endif

		WaveClear wavBackground
		WaveClear wavMeasure

		// Excitation wave
		stats.wavExcitation 	= (stats.numEmissionStart + stats.numEmissionEnd) / 2
	else
		for(i = 0; i < stats.numPLEMTotalY; i += 1)
			// Original Waves: load
			wave wavMeasure 	= dfr:$(StringFromList(i, strWavePL))
			wave wavBackground 	= dfr:$(StringFromList(i, strWaveBG))

			stats.wavMeasure[][i] 		= wavMeasure[p]
			stats.wavBackground[][i] 	= wavBackground[p]

			// Original Waves: unload
			WaveClear wavBackground
			WaveClear wavMeasure

			// Excitation wave
			numExcitationFrom 	= str2num(StringFromList(1,StringFromList(i,strWavePL), "_"))
			numExcitationTo 		= str2num(StringFromList(2,StringFromList(i,strWavePL), "_"))
			stats.wavExcitation[i] 	= (numExcitationFrom + numExcitationTo) / 2

			// since PLEMv3.0 excitation is saved multiplied by 10.
			if(stats.wavExcitation[i] > 1e3)
				stats.wavExcitation[i] /= 10
			endif
		endfor
	endif

	// Power correction waves
	// requires Excitation wave for Photon Energy
	stats.wavYpower	 = str2num(StringFromList(p, PLEMd2ExtractPower(wavIBW), ";"))
	stats.wavYphoton = (stats.wavYpower * 1e-6) / (6.62606957e-34 * 2.99792458e+8 / (stats.wavExcitation * 1e-9)) 		// power is in uW and Excitation is in nm

	// init camera specific corrections.
	// Please note that sizeadjustment and rotationadjustment are not
	// changeable on a "per file base" but on a "per experiment base"
	stats.numPixelPitch = 1
	NVAR/Z numSizeAdjustment = root:numSizeAdjustment
	NVAR/Z numRotationAdjustment = root:numRotationAdjustment

	// set camera specific corrections
	if(stats.numDetector == 0)
		// Andor Newton
	elseif(stats.numDetector == 1)
		// Andor iDus
	elseif(stats.numDetector == 2)
		// Andor Clara
		stats.numPixelPitch = 6.45 	// 6.45um

		// magnification adjustment
		if(!NVAR_EXISTS(numSizeAdjustment))
			Variable/G root:numSizeAdjustment = 0.960
			NVAR numSizeAdjustment = root:numSizeAdjustment
		endif

		// rotation adjustments
		if(!NVAR_EXISTS(numRotationAdjustment))
			// mounted camera is rotated depending on setup
			Variable/G root:numRotationAdjustment = -0.95
			NVAR numRotationAdjustment = root:numRotationAdjustment
		endif
		numRotationAdjustment = -0.95 // overwrite! better rotation for mkl23clarascan
		PLEMd2rotateLaser(stats)
	elseif(stats.numDetector == 3)
		// Xencis XEVA
		stats.numPixelPitch = 30 // 30um

		// magnification adjustment
		if(!NVAR_EXISTS(numSizeAdjustment))
			Variable/G root:numSizeAdjustment = 0.977
			NVAR numSizeAdjustment = root:numSizeAdjustment
		endif

		stats.booSwitchX = !stats.booSwitchX // xeva has reverse readout
	endif
	if(!NVAR_EXISTS(numRotationAdjustment))
		Variable/G root:numRotationAdjustment = 0
		NVAR numRotationAdjustment = root:numRotationAdjustment
	endif
	
	if(stats.numCalibrationMode != 1)
		//todo counterpart in PLEMd2setScale
		stats.numPLEMBottomY	= (str2num(StringFromList(1, StringFromList(0, strWavePL), "_")) + str2num(StringFromList(2, StringFromList(0, strWavePL), "_"))) / 2
	endif

	PLEMd2statsSave(stats)

	print GetWavesDataFolder(stats.wavPLEM, 2)
End

static Function PLEMd2setScale(stats)
	Struct PLEMd2stats &stats
	
	NVAR/Z numSizeAdjustment = root:numSizeAdjustment
	if(!NVAR_EXISTS(numSizeAdjustment))
		Variable/G root:numSizeAdjustment = 1
		NVAR numSizeAdjustment = root:numSizeAdjustment
		print "PLEMd2setScale: sizeAdjustment set to 1"
	endif

	// handle spectra
	if(stats.numReadOutMode != 1)
		stats.numPLEMLeftX = stats.wavWavelength[0]
		stats.numPLEMDeltaX = PLEMd2Delta(stats.wavWavelength, normal = 1)
		if(stats.numCalibrationMode == 1)
			stats.numPLEMDeltaY 	= (stats.numEmissionEnd - stats.numEmissionStart)
			stats.numPLEMBottomY 	= stats.numEmissionStart
		else
			stats.numPLEMBottomY	= stats.wavExcitation[0]
			stats.numPLEMDeltaY	= PLEMd2Delta(stats.wavExcitation)

			// since PLEMv3.0 excitation is saved multiplied by 10.
			if(stats.numPLEMBottomY > 1e3)
				stats.numPLEMBottomY /= 10
			endif
		endif
	endif

	// handle microscope images
	if(stats.numReadOutMode == 1)
		stats.numPLEMDeltaX =  (stats.booSwitchY == 1 ? +1 : -1) * numSizeAdjustment * stats.numPixelPitch / stats.numMagnification
		stats.numPLEMLeftX 	=  stats.numPositionY - stats.numPLEMDeltaX * (stats.numLaserPositionX)
		stats.numPLEMDeltaY 	= (stats.booSwitchX == 1 ? -1 : +1) * numSizeAdjustment * stats.numPixelPitch / stats.numMagnification
		stats.numPLEMBottomY 	= stats.numPositionX - stats.numPLEMDeltaY * stats.numLaserPositionY
	endif

	PLEMd2statsSave(stats)
	
	SetScale/P x stats.numPLEMLeftX, stats.numPLEMDeltaX, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground
	SetScale/P y stats.numPLEMBottomY, stats.numPLEMDeltaY, "", stats.wavPLEM, stats.wavMeasure, stats.wavBackground
End

// recalculate laserposition for rotated image
static Function PLEMd2rotateLaser(stats)
	Struct PLEMd2stats &stats

	variable dim0, dim1

	dim0 = stats.numLaserPositionX
	dim1 = stats.numLaserPositionY

	NVAR numRotationAdjustment = root:numRotationAdjustment
	PLEMd2rotatePoint(dim0, dim1, stats.numPLEMTotalX, stats.numPLEMTotalY, numRotationAdjustment)

	stats.numLaserPositionX = dim0
	stats.numLaserPositionY = dim1
End

static Function PLEMd2rotatePoint(pointX, pointY, totalX, totalY, rotation)
	Variable &pointX, &pointY
	Variable totalX, totalY, rotation

	// calculate LaserPosition (x,y) for rotated image when numRotationAdjustment != 0
	Make/FREE/U/I/N=(totalX, totalY) wv = 0
	wv[pointX][pointY] = 1000
	ImageRotate/Q/E=(0)/O/A=(rotation) wv
	WaveStats/M=1/Q wv

	pointX = V_maxRowLoc
	pointY = V_maxColLoc

	return 0
End

Function PLEMd2BuildMaps(strPLEM)
	String strPLEM

	variable i, numExcitation

	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)
	
	PLEMd2setScale(stats)

	// reset PLEM size to measurement (rotation changes it)
	Redimension/N=(DimSize(stats.wavMeasure, 0), DimSize(stats.wavMeasure, 1)) stats.wavPLEM

	if(stats.booInterpolate == 1)
		numExcitation = DimSize(stats.wavExcitation, 0)
		for(i = 0; i < numExcitation; i += 1)
			Duplicate/FREE/R=[][i] stats.wavMeasure wavMeasure, wavTempMeasure
			Redimension/N=(-1, 0) wavTempMeasure
			Duplicate/FREE/R=[][i] stats.wavBackground wavBackground, wavTempBackground
			Redimension/N=(-1, 0) wavTempBackground

			Interpolate2 /T=1 /I=3 /Y=wavTempMeasure stats.wavWavelength, wavMeasure
			interpolate2 /T=1 /I=3 /Y=wavTempBackground stats.wavWavelength, wavBackground

			stats.wavMeasure[][i] 		= wavTempMeasure[p]
			stats.wavBackground[][i] 	= wavTempBackground[p]

			WaveClear wavTempBackground, wavTempMeasure
			WaveClear wavBackground, wavMeasure
		endfor
	endif

	WAVE wavPLEM = stats.wavPLEM // work around bug in Multithread assignment which can not use stats.wavPLEM
	if(stats.booBackground)
		Multithread wavPLEM[][] = (stats.wavMeasure[p][q] - stats.wavBackground[p][q])
	else
		Multithread wavPLEM = stats.wavMeasure
	endif

	if(stats.booPower)
		if(DimSize(stats.wavPLEM, 1) == DimSize(stats.wavYpower, 0))
			Multithread wavPLEM /= stats.wavYpower[q]
		else
			Multithread wavPLEM /= stats.wavYpower[0]
		endif
	endif

	if(stats.booPhoton)
		Multithread wavPLEM /= stats.wavYphoton[q]
	endif

	if(stats.booNormalization)
		Multithread wavPLEM /= stats.numNormalization
	endif

	if(stats.booGrating)
		Multithread wavPLEM /= stats.wavGrating[p]
	endif

	if(stats.booQuantumEfficiency)
		// stats.wavPLEM *= 1 // QE not handled
	endif

	NVAR numRotationAdjustment = root:numRotationAdjustment
	if(numRotationAdjustment != 0)
		ImageRotate/Q/E=(NaN)/O/A=(numRotationAdjustment) stats.wavPLEM
	endif
End

// function modified from absorption-load-v6
// calculates the mean distance between points in wave.
// mainly used in the process of transforming waves to igor wave format.
Function PLEMd2Delta(wavInput, [normal])
	Wave wavInput
	Variable normal
	if(ParamIsDefault(normal))
		normal = 0
	endif

	Variable numSize, numDelta, i
	String strDeltaWave

	numSize		= DimSize(wavInput,0)
	if(numSize > 1)
		if(normal)
			numDelta = abs((wavInput[numSize-1] - wavInput[0]))/(numSize-1)
		else
			// calculate numDelta
			Make/FREE/O/N=(numSize-1) wavDeltaWave
			for(i = 0; i < (numSize - 1); i += 1)
				wavDeltaWave[i] = (wavInput[(i+1)] - wavInput[i])
			endfor
			WaveStats/Q/W wavDeltaWave

			wave M_WaveStats
			numDelta = M_WaveStats[3] //average
			//print "Wave " + nameofwave(wavInput) + " has a Delta of " + num2str(numDelta) + " with a standard deviation of " + num2str(M_WaveStats[4])
			//if X-Wave is not equally spaced, set the half minimum delta at all points.
			// controll by calculating statistical error 2*sigma/rms
			if((2 * M_WaveStats[4] / M_WaveStats[5] * 100) > 5)
				print "PLEMd2Delta: Wave is not equally spaced. Check Code and calculate new Delta."
				// minimum
				numDelta = M_WaveStats[10]
				// avg - 2 * sdev : leave out the minimum 5% for statistical resaons
				if(M_WaveStats[3] > 0)		// sdev is always positive ;-)
					numDelta = M_WaveStats[3] - 2 * M_WaveStats[4]
				else
					numDelta = M_WaveStats[3] + 2 * M_WaveStats[4]
				endif
			endif
			// not used put possibly needed, when a new Delta Value is returned.

			KillWaves/Z  M_WaveStats
		endif
	else
		numDelta = 0
	endif
	return numDelta
End

Function PLEMd2ExtractInfo(strPLEM, wavIBW)
	String strPLEM
	WAVE wavIBW

	String strFound
	Struct PLEMd2Stats stats

	PLEMd2statsLoad(stats, strPLEM)

	stats.strPLEM = strPLEM

	stats.strDate 		= PLEMd2ExtractSearch(wavIBW, "Date")
	stats.strUser 		= PLEMd2ExtractSearch(wavIBW, "User")
	stats.strFileName 	= PLEMd2ExtractSearch(wavIBW, "File")

	stats.numCalibrationMode = PLEMd2ExtractVariables(wavIBW, "numCalibrationMode")
	stats.numSlit 		= PLEMd2ExtractVariables(wavIBW, "numSlit")
	stats.numGrating 	= PLEMd2ExtractVariables(wavIBW, "numGrating")
	stats.numFilter 	= PLEMd2ExtractVariables(wavIBW, "numFilter")
	stats.numShutter 	= PLEMd2ExtractVariables(wavIBW, "numShutter")
	stats.numWLcenter 	= PLEMd2ExtractVariables(wavIBW, "numWLcenter")
	stats.numDetector 	= PLEMd2ExtractVariables(wavIBW, "numDetector")
	stats.numCooling 	= PLEMd2ExtractVariables(wavIBW, "numCooling")
	stats.numExposure 	= PLEMd2ExtractVariables(wavIBW, "numExposure")
	stats.numBinning 	= PLEMd2ExtractVariables(wavIBW, "numBinning")
	stats.numScans 		= PLEMd2ExtractVariables(wavIBW, "numScans")
	stats.numBackground = PLEMd2ExtractVariables(wavIBW, "numBackground")
	stats.numWLfirst 	= 0 // deprecated
	stats.numWLlast 	= 0 // deprecated
	stats.numWLdelta 	= PLEMd2ExtractVariables(wavIBW, "numWLdelta")
	stats.numEmissionMode 	= PLEMd2ExtractVariables(wavIBW, "numEmissionMode")
	stats.numEmissionPower 	= PLEMd2ExtractVariables(wavIBW, "numEmissionPower")
	stats.numEmissionStart 	= PLEMd2ExtractVariables(wavIBW, "numEmissionStart")
	stats.numEmissionEnd 	= PLEMd2ExtractVariables(wavIBW, "numEmissionEnd")
	stats.numEmissionDelta 	= PLEMd2ExtractVariables(wavIBW, "numEmissionDelta")
	stats.numEmissionStep 	= PLEMd2ExtractVariables(wavIBW, "numEmissionStep")

	stats.numPositionX = PLEMd2ExtractVariables(wavIBW, "numPositionX")
	stats.numPositionY = PLEMd2ExtractVariables(wavIBW, "numPositionY")
	stats.numPositionZ = PLEMd2ExtractVariables(wavIBW, "numPositionZ")
	stats.booSwitchX = PLEMd2ExtractVariables(wavIBW, "numSwitchX")
	stats.booSwitchY = PLEMd2ExtractVariables(wavIBW, "numSwitchY")

	stats.numReadOutMode 	= PLEMd2ExtractVariables(wavIBW, "numReadoutMode")
	stats.numLaserPositionX = PLEMd2ExtractVariables(wavIBW, "numLaserX")
	stats.numLaserPositionY = PLEMd2ExtractVariables(wavIBW, "numLaserY")
	stats.numMagnification 	= PLEMd2ExtractVariables(wavIBW, "numMagnification")

	PLEMd2statsSave(stats)
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
	if((strlen(strReadLine)>0) && (strlen(strItem)>0))
		strReturn = strItem
	else
		strReturn = ""
	endif

	return strReturn
End

Function/S PLEMd2ExtractWaveList(wavIBW)
	Wave wavIBW

	String strHeader, strList, strReadLine
	Variable i, numLines, startLine, endLine

	strHeader=note(wavIBW)
	startLine = strsearch(strHeader, "IGOR3:", 0) + 6
	if(startLine < 0)
		Abort "Critical: String IGOR3: missing in WaveNote"
	endif

	endLine = strsearch(strHeader, "\r", startLine) - 1
	if(endLine < 0)
		endLine = strlen(strHeader)
	endif

	return strHeader[startLine, endLine]
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
	for(i = 0; i < numCount; i += 1)
		numItem = str2num(StringFromList(i, strListParse))
		strListPower = AddListItem(num2str(numItem), strListPower, ";",Inf)
	endfor
	//print "for " + strVariableName + " at item number: " + num2str(WhichListItem(strVariableName, strListVariableNames)) + " found item: " + strItem

	return strListPower
End

Function/WAVE PLEMd2DuplicateByNum(numPLEM)
	Variable numPLEM
	if(numPLEM < 0)
		print "PLEMd2DuplicateByNum: Wrong Function Call numPLEM out of range"
		return $""
	endif
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	return PLEMd2Duplicate(strPLEM)
End

Function/WAVE PLEMd2Duplicate(strPLEM, [overwrite])
	String strPLEM
	variable overwrite

	String strTemp, strWavename
	Variable i

	Struct PLEMd2Stats stats
	PLEMd2statsLoad(stats, strPLEM)
	
	overwrite = ParamIsDefault(overwrite) ? 1 : !!overwrite

	strWavename = "root:" + stats.strPLEM
	strTemp = strWavename

	if(!overwrite && WaveExists($strWavename))
		print "PLEMd2Duplicate: Wave already exists. Using incremental WaveName"
		i = -1
		do
			i += 1
			strTemp = strWavename + "_" + num2str(i)
			wave/Z wv = $strTemp
		while(WaveExists(wv))
		strWavename = strTemp
	endif

	Duplicate/O stats.wavPLEM $strWavename/WAVE=wv
	print "PLEMd2Duplicate: WaveName is " + strWavename

	return wv
End

Function PLEMd2FixWavenotes(wavIBW)
	WAVE wavIBW

	String strHeader, strWaveNames, strWaveNamesNew, falseBackground, i

	print "PLEMd2FixWavenotes: Trying to correct WaveNote"

	strHeader = Note(wavIBW)
	if((StringMatch(strHeader, "*IGOR2:*")) == 0)
		//IGOR2 not found so the error is probably related to that. (caused by early version of LabView program)
		print "PLEMd2FixWavenotes: Error: Did not find IGOR2 in WaveNote. Fixing...."
		//rename IGOR4 to IGOR3 and IGOR3 to IGOR2.
		strHeader = ReplaceString("IGOR3:",strHeader, "IGOR2:")
		strHeader = ReplaceString("IGOR4:",strHeader, "IGOR3:")
	Endif

	strWaveNames = PLEMd2ExtractWaveList(wavIBW)
	if(StringMatch(strWaveNames, "*BG;*") && StringMatch(strWaveNames, "*BG_*"))
		//mixed multiple and single background during measurement, revert to single bg
		strWaveNamesNew = RemoveFromList(ListMatch(strWaveNames, "BG_*"), strWaveNames)
		//strWaveNames	= strHeader[strsearch(strHeader, "IGOR3:",0), strlen(strHeader)]
		strHeader = ReplaceString("IGOR3:" + strWaveNames, strHeader, "IGOR3:" + strWaveNamesNew)
	endif
	
	Note/K wavIBW strHeader
	strHeader = Note(wavIBW)
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
	for(i = 0; i < V_npnts; i += 1)
		stats.wavChiralitynm[i]="("+num2str(stats.wavChiralityN[i])+", "+num2str(stats.wavChiralityM[i])+")"
	endfor

End

Function PLEMd2AtlasRecalculate(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)
	Variable numPlank = 4.135667516E-12 //meV s
	Variable numLight =  	299792458E9 //nm/s
	stats.wavEnergyS1	= numPlank * numLight / (numPlank * numLight / stats.wavAtlasS1nm[p] - stats.numS1offset)
	stats.wavEnergyS2	= numPlank * numLight / (numPlank * numLight / stats.wavAtlasS2nm[p] - stats.numS2offset)
End

Function PLEMd2AtlasInit(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	Variable i, numChiralities, j
	Variable xmin, xmax, ymin, ymax
	Variable chirality_start, chirality_end

	PLEMd2AtlasReload(strPLEM) // also populates wave references
	PLEMd2statsLoad(stats, strPLEM)	// so we have to load afterwards

	// get boundaries of current window
	PLEMd2Display(strPLEM)
	getAxis/Q left
	ymin = V_min
	ymax = V_max
	getAxis/Q bottom
	xmin = V_min
	xmax = V_max

	print xmin,xmax
	print ymin,ymax

    // search for all chiralities within current window
	Duplicate/O stats.wavAtlasS1nm stats.wavEnergyS1
	Duplicate/O stats.wavAtlasS2nm stats.wavEnergyS2
	Duplicate/O stats.wavAtlasN    stats.wavchiralityn
	Duplicate/O stats.wavAtlasM    stats.wavchiralitym
    stats.wavEnergyS2   = 0
    stats.wavEnergyS1   = 0
    stats.wavchiralityn = 0
    stats.wavchiralitym = 0

	numChiralities = Dimsize(stats.wavAtlasS1nm, 0)
    j = 0
	for(i = 0; i < numChiralities; i += 1)
		if((stats.wavAtlasS2nm[i] > (ymin - 10)) && (stats.wavAtlasS1nm[i] > (xmin - 10)) && (stats.wavAtlasS2nm[i] < (ymax + 10)) && (stats.wavAtlasS1nm[i] < (xmax + 10)))
            stats.wavEnergyS1[j]   = stats.wavAtlasS1nm[i]
            stats.wavEnergyS2[j]   = stats.wavAtlasS2nm[i]
	        stats.wavchiralityn[j] = stats.wavAtlasN[i]
	        stats.wavchiralitym[j] = stats.wavAtlasM[i]
            j += 1
        endif
	endfor
    Redimension/N=(j) stats.wavEnergyS1, stats.wavEnergyS2, stats.wavchiralitym, stats.wavchiralityn

    // overwrite reset point
	Duplicate/O stats.wavEnergyS1 stats.wavAtlasS1nm
	Duplicate/O stats.wavEnergyS2 stats.wavAtlasS2nm
	Duplicate/O stats.wavchiralityn stats.wavAtlasN
	Duplicate/O stats.wavchiralitym stats.wavAtlasM

	// create waves of appropriate dimensions
	Duplicate/O stats.wavchiralityn stats.wav2Dfit
	Duplicate/O stats.wavchiralitym stats.wav1Dfit
	stats.wav2Dfit = 0
	stats.wav1Dfit = 0

	stats.numS1offset = 0
	stats.numS2offset = 0

	PLEMd2statsSave(stats)
	PLEMd2AtlasCreateNM(strPLEM)
End

Function PLEMd2AtlasEdit(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	String winPLEMedit

	if(PLEMd2MapExists(strPLEM) == 0)
		print "PLEMd2AtlasFit: Map does not exist properly"
		return 0
	endif

	PLEMd2statsLoad(stats, strPLEM)

	winPLEMedit = PLEMd2getWindow(stats.strPLEM) + "_edit"
	DoWindow/F $winPLEMedit
	if(V_flag == 0)
		Edit stats.wavchiralitynm, stats.wav2Dfit, stats.wav1Dfit, stats.wavEnergyS1, stats.wavEnergyS2, stats.wavChiralityn, stats.wavChiralityM
		DoWindow/C/N/R $winPLEMedit
	endif

End

Function PLEMd2AtlasClean(strPLEM)
	String strPLEM

	Variable i, numPoints

	Variable xmin, xmax, ymin, ymax

	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)

	// get boundaries of current window
	PLEMd2Display(strPLEM)
	getAxis/Q left
	ymin = V_min
	ymax = V_max
	getAxis/Q bottom
	xmin = V_min
	xmax = V_max

	numPoints = DimSize(stats.wavchiralitynm, 0)
	for(i = 0; i < DimSize(stats.wavchiralitynm, 0); i += 1)
		if((stats.wav1Dfit[i] == 0) || (stats.wavEnergyS2[i] < ymin) || (stats.wavEnergyS2[i] > ymax) || (stats.wavEnergyS1[i] < xmin) || (stats.wavEnergyS1[i] > xmax))
			print "deleting " + stats.wavchiralitynm[i]
			print (stats.wavEnergyS2[i]), (stats.wavEnergyS1[i])
			DeletePoints i,1, stats.wavchiralitynm, stats.wavchiralityn, stats.wavchiralitym
			DeletePoints i,1, stats.wav2Dfit, stats.wav1Dfit, stats.wavEnergyS1, stats.wavEnergyS2
			i-=1
		endif
	endfor
End

Function PLEMd2AtlasFit1D(strPLEM)
	String strPLEM

	Variable i, j, numAtlas, numFits
	Variable numDelta = 20, numAccuracy = 0
	Variable fit_start, fit_end
	Variable numEnergyS1, numEnergyS2
	Variable numPlank = 4.135667516E-12 //meV s
	Variable numLight = 299792458E9 //nm/s
	String strWavPLEMfitSingle, strWavPLEMfit

	Variable V_fitOptions = 4 // used to suppress CurveFit dialog
	Variable V_FitQuitReason  // stores the CurveFit Quit Reason
	Variable V_FitError   // Curve Fit error

	Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)

	numFits = numpnts(stats.wavEnergyS1)
	for(i = 0; i < numFits; i += 1)
		// fit Excitation
		// find p,q
		FindValue/T=2/V=(stats.wavEnergyS1[i] - numDelta) stats.wavWavelength
		if(V_Value == -1)
			fit_start = 0
		else
			fit_start = V_Value
		endif
		FindValue/T=2/V=(stats.wavEnergyS1[i] + numDelta) stats.wavWavelength
		if(V_Value == -1)
			fit_end = DimSize(stats.wavPLEM, 0) - 1
		else
			fit_end = V_Value
		endif
		do
			numAccuracy += 1
			FindValue/T=(numAccuracy)/V=(stats.wavEnergyS2[i]) stats.wavExcitation
		while(V_Value == -1)

		Duplicate/FREE/R=[fit_start, fit_end][V_Value] stats.wavPLEM fitme
		Redimension/N=(fit_end - fit_start + 1) fitme
		Duplicate/FREE fitme fitresult
		CurveFit/Q lor fitme /D=fitresult
		if(V_FitError == 0)
			Wavestats/Q fitresult
			stats.wavEnergyS1[i] = stats.wavWavelength[(V_maxRowLoc + fit_start)] // (unscaled) point from original wavelength wave
		else
			stats.wavEnergyS1[i] = 0
		endif
		WaveClear fitme, fitresult

		// fit Emission
		// find p,q
		FindValue/T=2/V=(stats.wavEnergyS2[i] - numDelta) stats.wavExcitation
		if(V_Value == -1)
			fit_start = 0
		else
			fit_start = V_Value
		endif
		FindValue/T=2/V=(stats.wavEnergyS2[i] + numDelta) stats.wavExcitation
		if(V_Value == -1)
			fit_end = DimSize(stats.wavPLEM, 1) - 1
		else
			fit_end = V_Value
		endif
		numAccuracy = 0
		do
			numAccuracy += 1
			FindValue/T=(numAccuracy)/V=(stats.wavEnergyS1[i]) stats.wavWavelength
		while(V_Value == -1)

		Duplicate/FREE/R=[V_Value][fit_start, fit_end] stats.wavPLEM fitme
		Duplicate/FREE/R=[fit_start, fit_end] stats.wavExcitation xfitme
		Redimension/N=(fit_end - fit_start + 1) fitme, xfitme
		Duplicate/FREE fitme fitresult
		CurveFit/Q lor fitme /D=fitresult
		if(V_FitError == 0)
			Wavestats/Q fitresult
			stats.wavEnergyS2[i] = xfitme[V_maxrowloc]
		else
			stats.wavEnergyS2[i] = 0
		endif
		WaveClear fitme, fitresult

		// save measurement data at current point
		// check if energy is valid
		numAtlas = DimSize(stats.wavAtlasN, 0)
		for(j = 0; j < numAtlas; j += 1)
			if((stats.wavAtlasN[j] == stats.wavChiralityn[i]) && (stats.wavAtlasM[j] == stats.wavChiralitym[i]))
				break
			endif
		endfor
		if(j == numAtlas)
			// not found. error.
			stats.wav1Dfit[i] = 0
			continue
		endif
		numEnergyS1	= numPlank * numLight / (numPlank * numLight / stats.wavAtlasS1nm[j] - stats.numS1offset)
		numEnergyS2	= numPlank * numLight / (numPlank * numLight / stats.wavAtlasS2nm[j] - stats.numS2offset)
		if((abs(stats.wavEnergyS1[i] - numEnergyS1) > 30) || (abs(stats.wavEnergyS2[i] - numEnergyS2) > 30))
			print (stats.wavEnergyS2[i]), numEnergyS2
			print (stats.wavEnergyS1[i]), numEnergyS1
			stats.wav1Dfit[i] = 0
		else
			FindValue/T=2/V=(stats.wavEnergyS1[i]) stats.wavWavelength
			if(V_Value == -1)
				fit_start = 0
			else
				fit_start = V_Value
			endif
			FindValue/T=2/V=(stats.wavEnergyS2[i]) stats.wavExcitation
			if(V_Value == -1)
				fit_end = DimSize(stats.wavPLEM, 1) - 1
			else
				fit_end = V_Value
			endif
			stats.wav1Dfit[i] = stats.wavPLEM[fit_start][fit_end]
		endif
	endfor

End

Function PLEMd2AtlasFit2D(strPLEM)
    String strPLEM

    Variable numFits, i

    Struct PLEMd2stats stats
	PLEMd2statsLoad(stats, strPLEM)

    numFits = numpnts(stats.wavEnergyS1)
	for(i = 0; i < numFits; i += 1)
    endfor
End

Function PLEMd2AtlasFit3D(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats

	Variable numS1,numS2
	Variable numDeltaS1, numDeltaS2
	Variable numDeltaS1left, numDeltaS1right, numDeltaS2bottom, numDeltaS2top
	Variable rightXvalue, topYvalue
	Variable V_fitOptions=4 // used to suppress CurveFit dialog
	Variable V_FitQuitReason // stores the CurveFit Quit Reason
	Variable V_FitError // Curve Fit error
	String strChirality = ""
	String strWavPLEMfitSingle, strWavPLEMfit
	String winPLEMfit, winPLEM
	Variable i

	if(PLEMd2MapExists(strPLEM) == 0)
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
	SetScale/P y,stats.numPLEMbottomY,stats.numPLEMdeltaY, "",stats.wavPLEMfit
	SetScale/P x,stats.numPLEMleftX,stats.numPLEMdeltaX, "",stats.wavPLEMfit
	//Display
	//AppendImage stats.wavPLEM

	numDeltaS1 = 50
	numDeltaS2 = 50
	
	rightXvalue = stats.numPLEMleftX + stats.numPLEMTotalX * stats.numPLEMdeltaX
	topYvalue = stats.numPLEMbottomY + stats.numPLEMTotalY * stats.numPLEMdeltaY
	
	// input
	i=0
	for(i = 0; i < numpnts(stats.wavEnergyS1); i += 1)
		stats.wavPLEMfit[][][i]=0
		stats.wav2Dfit[i] = 0
		numS1 = stats.wavEnergyS1[i] //x
		numS2 = stats.wavEnergyS2[i] //y

		numDeltaS1left 	= numDeltaS1/2
		numDeltaS1right 	= numDeltaS1/2
		numDeltaS2bottom = numDeltaS2/2
		numDeltaS2top 	= numDeltaS2/2

		if((numS1-numDeltaS1left) < stats.numPLEMleftX)
			//print "chirality not in Map S1 Data Range"
			numDeltaS1left = numS1 - stats.numPLEMleftX
			if(numDeltaS1left<0)
				numDeltaS1left = 0
			endif
		endif
		if((numS1+numDeltaS1right) > rightXvalue)
			//print "chirality not in Map S1Data Range"
			numDeltaS1right = rightXvalue - numS1
			if(numDeltaS1right<0)
				numDeltaS1right = 0
			endif
		endif
		if((numS2-numDeltaS2bottom) < stats.numPLEMbottomY)
			//print "chirality not in Map S1Data Range"
			numDeltaS2bottom = numS2 - stats.numPLEMbottomY
			if(numDeltaS2bottom<0)
				numDeltaS2bottom = 0
			endif
		endif
		if((numS2+numDeltaS2top) > topYvalue)
			//print "chirality not in Map S1Data Range"
			numDeltaS2top = topYvalue - numS2
			if(numDeltaS2top<0)
				numDeltaS2top = 0
			endif
		endif
		if((numDeltaS1 < 0) | (numDeltaS2 < 0))
			stats.wavPLEMfit[][][i] = 0
			stats.wav2Dfit[i] = 0
		else
			V_FitError = 0
			//Make/O/T fitConstraints={"K6 = 0"}
			//Make/FREE/O W_coef = {0,1,stats.wavEnergyS1[i], (sqrt(stats.wav2Dfit[i]/(2*pi))), stats.wavEnergyS2[i], (sqrt(stats.wav2Dfit[i]/(2*pi))), 0}
			// gauss2d=K0+K1*exp((-1/(2*(1-K6^2)))*(((x-K2)/K3)^2 + ((y-K4)/K5)^2 - (2*K6*(x-K2)*(y-K4)/(K3*K5))))
			CurveFit/Q gauss2D stats.wavPLEM(numS1-numDeltaS1left,numS1+numDeltaS1right)(numS2-numDeltaS2bottom,numS2+numDeltaS2top)
			//FuncFit/Q PLEMd2SimpleGaussian2D, W_coef stats.wavPLEM(numS1-numDeltaS1left,numS1+numDeltaS1right)(numS2-numDeltaS2bottom,numS2+numDeltaS2top)
			if(V_FitError == 0)
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
			if((stats.wavEnergyS1[i] < 0) | (stats.wavEnergyS2[i] < 0) | (stats.wav2Dfit[i] < 0))
				stats.wavPLEMfit[][][i] = 0
				stats.wav2Dfit[i] = 0
			endif
			if((abs((numS1-stats.wavEnergyS1[i])/numS1) > 0.25 ) || (abs((numS2-stats.wavEnergyS2[i])/numS2) > 0.25 ))
				stats.wavPLEMfit[][][i] = 0
				stats.wav2Dfit[i] = 0
			endif
		endif
	endfor
	// add all maps to one map
	PLEMd2AtlasMerge3d(stats.wavPLEMfit,stats.wavPLEMfitSingle)

	// check if window already exists
	winPLEM = PLEMd2getWindow(stats.strPLEM)
	DoWindow/F $winPLEM
	// DoWindow sets the variable V_flag:
	// 	1 window existed
	// 	0 no such window
	// 	2 window is hidden.
	if(!!V_flag)
		String listContour = ContourNameList("", ";")
		for(i = 0; i < ItemsInList(listContour); i += 1)
			RemoveContour $(StringFromList(i, listContour))
		endfor
		AppendMatrixContour stats.wavPLEMfitSingle
		ModifyContour ''#0 labels=0,autoLevels={0,*,10}
	endif

	// check if window already exists
	winPLEMfit = PLEMd2getWindow(stats.strPLEM) + "_fit"
	DoWindow/F $winPLEMfit
	if(V_flag == 2)
		print "PLEMd2AtlasFit: Fit-Graph was hidden. Case not handled. check code"
	elseif(V_flag == 0)
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
	Redimension/N=(Dimsize(wave3d, 0),Dimsize(wave3d, 1)) wave2d
	for(i = 1; i < Dimsize(wave3d, 2); i += 1)
		wave2d += wave3d[p][q][i]
	endfor
End

Function PLEMd2AtlasShow(strPLEM)
	String strPLEM
	Struct PLEMd2stats stats
	if(PLEMd2MapExists(strPLEM) == 0)
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
	ModifyGraph textMarker(plem03)={stats.wavChiralitynm, "default",0,0,5,0.00,10.00} //labels top
	ModifyGraph rgb(plem03)=(65535,65535,65535)
	ModifyGraph mrkStrokeRGB(plem03)=(65535,65535,65535)

	ModifyGraph mode(plem01)=3 , msize(plem01)=2
	ModifyGraph marker(plem01)=5 // squares
	ModifyGraph marker(plem01)=8 // circles
	ModifyGraph msize(plem01)=5
	ModifyGraph height={Plan,1,left,bottom}
	ModifyGraph height=0
End

Function PLEMd2AtlasHide(strPLEM)
	String strPLEM
	if(PLEMd2MapExists(strPLEM) == 0)
		print "PLEMd2AtlasHide: Map does not exist properly"
		return 0
	endif
	PLEMd2Display(strPLEM)
	RemoveFromGraph/Z plem01
	RemoveFromGraph/Z plem02
	RemoveFromGraph/Z plem03

	Variable i
	String listContour = ContourNameList("", ";")
	for(i = 0; i < ItemsInList(listContour); i += 1)
		RemoveContour $(StringFromList(i, listContour))
	endfor
End

Function PLEMd2d1Open()

End

//adapted from function OpenFileDialog on http://www.entorb.net/wickie/IGOR_Pro
Function/S PLEMd2PopUpChooseFile([strPrompt])
	String strPrompt

	Variable refNum
	String strFileName, strLastPath, strFolderName
	String fileFilters = "Igor Binary File (*.ibw):.ibw;General Text Files (*.txt, *.csv):.txt,.csv;All Files:.*;"

	// get last path
	Struct PLEMd2Prefs prefs
	PLEMd2LoadPackagePrefs(prefs)
	strLastPath = prefs.strLastPath

	GetFileFolderInfo/Q/Z=1 strLastPath
	if(V_Flag || !V_isFolder)
		strLastPath = prefs.strBasePath
		GetFileFolderInfo/Q/Z=1 strLastPath
		if(V_Flag || !V_isFolder)
			strLastPath = SpecialDirPath("Documents", 0, 0, 0 )
		endif
	endif

	//Display file Dialog starting with last path
	NewPath/O/Q PLEMd2LastPath, strLastPath
	if(V_flag)
		Abort "Invalid Path"
	endif
	PathInfo/S PLEMd2LastPath
	if(!V_flag)
		Abort "Symbolic path does not exist"
	endif
	strPrompt = SelectString(ParamIsDefault(strPrompt), strPrompt, "choose file")
	Open/D/R/Z=2/F=fileFilters/M=strPrompt refNum
	if(V_flag)
		KillPath/Z PLEMd2LastPath
		return ""
	endif
	strFileName = S_fileName
	KillPath/Z PLEMd2LastPath // we don't need the path reference

	// save as last path
	strFolderName = ParseFilePath(1, strFileName, ":", 1, 0)
	GetFileFolderInfo/Q/Z=1 strFolderName
	if(V_isFolder)
		prefs.strLastPath = strFolderName
		PLEMd2SavePackagePrefs(prefs)
	endif

	return strFileName
End

//imports Maps and corresponding files from
//old PLE-Map displayer created by Tilman Hain from ~2013-2015
//Old Maps Data have to be in current project root:
Function PLEMd2d1Import(numKillWavesAfterwards)
	Variable numKillWavesAfterwards
	//if(ParamIsDefault(numKillWavesAfterwards))
	//	numKillWavesAfterwards = 0
	//endif
	PLEMd2initialize()
	DFREF dfr = $cstrPLEMd2root
	SVAR gstrMapsFolder = dfr:gstrMapsFolder
	SVAR gstrMapsAvailable = dfr:gstrMapsAvailable
	NVAR gnumMapsAvailable = dfr:gnumMapsAvailable

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
	for(i = 0; i < numMaps; i += 1)
		SetDataFolder $gstrMapsFolder
		strMap 		= StringFromList(i, strMaps)
		numFiles	= PLEMd2d1CountFiles("root:" + strMap)
		print "PLEMd2d1Import: Importing " + strMap + " with " + num2str(numFiles) + " data waves."

		//In MapsFolder we create subdirectories for the waves.
		if(DataFolderExists(strMap))
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
		if(DataFolderExists("ORIGINAL"))
			SetDataFolder ORIGINAL
		else
			NewDataFolder/O/S ORIGINAL
		endif
		for(j = 0; j < numSearchstrings; j += 1)
			strSearchString = StringFromList(j, strSearchStrings)
			for(k = 0; k < numFiles; k += 1)
				strWave = strMap + strSearchString + num2str(k)
				wave wavDummy = $("root:" + strWave)
				if(WaveExists(wavDummy))
					Duplicate/O wavDummy $strWave
					if(numKillWavesAfterwards == 1)
						Killwaves/Z wavDummy
					endif
				endif
			endfor
		endfor
		SetDataFolder $gstrMapsFolder
		SetDataFolder $strMap

		//Copy Map for dimensions.
		wave wavPLEM = $("root:PLE_map_" + strMap)
		if(WaveExists(wavPLEM))
			numTotalX	= DimSize(wavPLEM,0)
			numTotalY	= DimSize(wavPLEM,1)
			if(numTotalY != numFiles)
				print "PLEMd2d1Import: Size Missmatch in Map: " + strMap
			endif
			Duplicate/O wavPLEM PLEM
			if(numKillWavesAfterwards == 1)
				Killwaves/Z wavPLEM
			endif

			wave wavPLEM = PLEM
			//Create Measurement Wave from Files.
			Duplicate/O wavPLEM MEASURE
			wave wavMeasure	= MEASURE

			for(j = 0; j < numTotalY; j += 1)
				strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_" + num2str(j)
				wave wavCurrent = $strWave
				if(WaveExists(wavCurrent))
					for(k = 0; k < numTotalX; k += 1)
						wavMeasure[k][j] = wavCurrent[k]
					endfor
				endif
			endfor

			//Create 2D-Background Wave from Files.
			Duplicate/O wavPLEM BACKGROUND
			wave wavBackground	= BACKGROUND
			//count background files
			numFiles	= PLEMd2d1CountFiles(gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg")
			for(j = 0; j < numTotalY; j += 1)
				if(numFiles > 1)
					strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg_" + num2str(j)
				else
					//single background
					strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_bg_0"
				endif
				wave wavCurrent = $strWave
				if(WaveExists(wavCurrent))
					for(k = 0; k < numTotalX; k += 1)
						wavBackground[k][j] = wavCurrent[k]
					endfor
				else
					//background file not found. Zero it out.
					for(k = 0; k < numTotalX; k += 1)
						wavBackground[k][j] = 0
					endfor
				endif
			endfor

			//Create Corrected Wave from Files.
			Duplicate/O wavPLEM CORRECTED
			wave wavBackground	= CORRECTED

			for(j = 0; j < numTotalY; j += 1)
				strWave = gstrMapsFolder + ":" + strMap + ":ORIGINAL:" + strMap + "_corr_m_" + num2str(j)
				wave wavCurrent = $strWave
				if(WaveExists(wavCurrent))
					for(k = 0; k < numTotalX; k += 1)
						wavBackground[k][j] = wavCurrent[k]
					endfor
				endif
			endfor
		endif

		//Copy Wavelength Wave
		wave wavWavelength = $("root:wavelength_" + strMap)
		if(WaveExists(wavWavelength))
			Duplicate/O wavWavelength WAVELENGTH
			if(numKillWavesAfterwards == 1)
				Killwaves/Z wavWavelength
			endif
		endif

		//Copy Power Wave
		wave wavPower = $("root:" + strMap + "_power")
		if(WaveExists(wavPower))
			Duplicate/O wavPower POWER
			if(numKillWavesAfterwards == 1)
				Killwaves/Z wavPower
			endif
		endif

		//Copy Photon Wave
		wave wavPhoton = $("root:" + strMap + "_photon")
		if(WaveExists(wavPhoton))
			Duplicate/O wavPhoton PHOTON
			if(numKillWavesAfterwards == 1)
				Killwaves/Z wavPhoton
			endif
		endif

		//Append Current Map to List of Maps
		PLEMd2AddMap(strMap)
		//Save stats.
		PLEMd2statsSave(stats)
	endfor
End

Function PLEMd2getMapsAvailable()
	DFREF dfr = $cstrPLEMd2root
	NVAR/Z numMaps = dfr:gnumMapsAvailable
	if(!NVAR_EXISTS(numMaps))
		return 0
	endif

	return numMaps
End

Function/S PLEMd2getStrMapsAvailable()
	DFREF dfr = $cstrPLEMd2root
	SVAR/Z strMaps = dfr:gstrMapsAvailable
	if(!SVAR_EXISTS(strMaps))
		return ""
	endif

	return strMaps
End

Function PLEMd2AddMap(strMap)
	String strMap

	DFREF dfr = $cstrPLEMd2root
	SVAR gstrMapsAvailable = dfr:gstrMapsAvailable
	NVAR gnumMapsAvailable = dfr:gnumMapsAvailable

	Variable numFind

	numFind = FindListItem(strMap, gstrMapsAvailable)
	if(numFind == -1)
		gstrMapsAvailable += strMap + ";"
		numFind = ItemsInList(gstrMapsAvailable)
		gnumMapsAvailable = numFind
	else
		gnumMapsAvailable = ItemsInList(gstrMapsAvailable)
	endif

	return numFind
End

Function PLEMd2KillMap(strMap)
	String strMap

	DFREF dfr = $cstrPLEMd2root
	SVAR gstrMapsAvailable = dfr:gstrMapsAvailable
	NVAR gnumMapsAvailable = dfr:gnumMapsAvailable

	if(FindListItem(strMap, gstrMapsAvailable) != -1)
		gstrMapsAvailable = RemoveFromList(strMap, gstrMapsAvailable)
		gnumMapsAvailable = ItemsInList(gstrMapsAvailable)
	endif

	String strKillDataFolder = PLEMd2mapFolderString(strMap)
	if(DataFolderExists(strKillDataFolder))
		KillDataFolder/Z $strKillDataFolder
		if(V_flag != 0)
			// don't care if Folder could not be killed. Items might be in use.
			print "PLEMd2KillMap: DataFolder could not be deleted."
		endif

	endif
End

Function PLEMd2KillMapByNum(numPLEM)
	Variable numPLEM
	if(numPLEM < 0)
		print "PLEMd2KillMapByNum: Wrong Function Call numPLEM out of range"
		return 0
	endif
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	PLEMd2KillMap(strPLEM)
End

Function PLEMd2MapExists(strMap)
	String strMap

	String strMaps = PLEMd2getStrMapsAvailable()

	if(FindListItem(strMap, strMaps) != -1)
		return 1
	endif

	return 0
End

// check maps folder for content
//
// return number of maps
Function PLEMd2MapStringReInit()
	DFREF dfr = $cstrPLEMd2root
	SVAR gstrMapsFolder = dfr:gstrMapsFolder
	SVAR gstrMapsAvailable = dfr:gstrMapsAvailable
	NVAR gnumMapsAvailable = dfr:gnumMapsAvailable

	Variable i, numMapsAvailable
	String strMap
	gstrMapsAvailable 	= ""
	gnumMapsAvailable 	= 0
	numMapsAvailable = CountObjects(gstrMapsFolder, 4) // number of data folders

	for(i = 0; i < numMapsAvailable; i += 1)
		strMap = GetIndexedObjName(gstrMapsFolder,4,i)
		gstrMapsAvailable += strMap + ";"
	endfor
	gnumMapsAvailable = ItemsInList(gstrMapsAvailable)

	return gnumMapsAvailable
End

Function PLEMd2d1Kill(strWhichOne)
	String strWhichOne
	PLEMd2initialize()

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
	strWavesAvailable = WaveList("*", ";", "")
	strVariablesAvailable = VariableList("!gnum*", ";",4)
	strStringsAvailable = StringList("!gstr*", ";")
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
	for(i = 0; i < numAvailable; i += 1)
		strAvailable = StringFromList(i, strListAvailable)
		if(FindListItem(strAvailable, strListKillMe) != -1)
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
					if(WaveExists($("root:"+strAvailable)))
						Killwaves/Z $("root:"+strAvailable)
					endif
					if(FindListItem(strAvailable, strVariablesAvailable) != -1)
						Killvariables/Z $("root:"+strAvailable)
					endif
					if(FindListItem(strAvailable, strStringsAvailable) != -1)
						Killstrings/Z $("root:"+strAvailable)
					endif
					break
			endswitch
			numCount +=1
		endif
	endfor
	print "PLEMd2d1Kill: deleted " + strWhichOne + ": " + num2str(numCount) + " "
End

Function/S PLEMd2d1Find()
	String strSaveDataFolder = GetDataFolder(1)

	String strWaves, strPLEMd1
	String strWave, strTestString
	Variable numIndex
	Variable numStrLen

	SetDataFolder root:
	strWaves 	= WaveList("PLE_map_*", ";", "")
	strPLEMd1 	= ""
	//loop adopted from igor manual. though <<for>> loops are normally prefered.
	do
		strWave = StringFromList(numIndex, strWaves)
		numStrLen = strlen(strWave)
		//break condition
		if(numStrLen == 0)
			break
		endif
		strTestString = strWave[8,numStrLen-1]
		if(WaveExists($("root:"+"PLE_map_"+strTestString)))
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
		if(WaveExists($(strBaseName + "_" + num2str(numIndex))) == 0)
			break
		endif
		numIndex += 1
	while (1)
	return numIndex
End

Function PLEMd2d1isInit()
	//directory persistent: function does not switch the current directory.
	if(PLEMd2isInitialized() == 0)
		return 0
	else
		SVAR gstrPLEMd1root = $(cstrPLEMd2root + ":gstrPLEMd1root")
		NVAR gnumPLEMd1IsInit = $(gstrPLEMd1root + ":gnumPLEMd1IsInit")
		return gnumPLEMd1IsInit
	endif
End

Function PLEMd2d1reset()
	//directory persistent: function does not switch the current directory.
	print "PLEMd2d1reset: reset in progress"
	if(PLEMd2d1isInit() == 1)
		SVAR gstrPLEMd1root = $(cstrPLEMd2root + ":gstrPLEMd1root")
		NVAR gnumPLEMd1IsInit = $(gstrPLEMd1root + ":gnumPLEMd1IsInit")
		gnumPLEMd1IsInit = 0
	endif
	PLEMd2d1Init()
	print "PLEMd2d1reset: reset ended"
End

Function PLEMd2d1Init()
	//directory persistent: function restores current dir on exit.

	//check if Init() is necessary. And if the global variables are relibably there.
	if(PLEMd2d1isInit() == 0)
		//switch to current working dir. Keep old directory in memory.
		String strSaveDataFolder = GetDataFolder(1)

 		//GLOBAL VARS
		SVAR gstrPLEMd1root = $(cstrPLEMd2root + ":gstrPLEMd1root")
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
		if(V_flag != 0)
			print "PLEMd2d1Init: Error loading correction waves from " + gstrPLEMd1PathBase
			gnumPLEMd1IsInit = 1 // do not try again.
			SetDataFolder $strSaveDataFolder
			return 0
		endif

		NewPath/O/Q path, gstrPLEMd1PathBase
		strFiles = IndexedFile(path,-1, ".txt")
		numFiles = ItemsInList(strFiles)
		//print "PLEMd2d1Init: found " + num2str(numFiles) + " files"
		numPLEMd1CorrectionWaves = ItemsInList(gstrPLEMd1CorrectionToLoad)

		//if there were no waves specified, load all Files from the current directory.
		if(numPLEMd1CorrectionWaves == 0)
			numPLEMd1CorrectionWaves 	= numFiles
			strPLEMd1CorrectionWave 	= strFiles
		else
			strPLEMd1CorrectionWaves	 = gstrPLEMd1CorrectionToLoad
		endif

		gstrPLEMd1CorrectionAvailable = ""
		strFilesLoaded = ""
		for(i = 0; i < numFiles; i += 1)
			strFile = StringFromList(i, strFiles)
			if(FindListItem(strFile, strPLEMd1CorrectionWaves) != -1)
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

					if(V_flag > 0)
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

	if(PLEMd2d1Init() == 0)
		print "PLEMd2d1CorrectionWave: Initialization Failure"
	endif
	SVAR gstrPLEMd1root = $(cstrPLEMd2root + ":gstrPLEMd1root")
	SetDataFolder $gstrPLEMd1root
	SVAR gstrPLEMd1CorrectionAvailable

	String strReturn = ""
	strReturn = gstrPLEMd1root + ":" + strWave

	SetDataFolder $strSaveDataFolder

	if(WaveExists($strReturn))
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
	if(intGrating == 1)
		intGrating = 500
	elseif(intGrating == 2)
		intGrating = 800
	elseif(intGrating == 3)
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
	if(intDetector == 0)
		strDetector = "CCD"
	elseif(intDetector == 1)
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
		if((intTemperatureNear < -273) || (intTemperatureNear > 100))
			lenReturn = 0
		else

			if(intTemperatureNear < 0)
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
		if((lenReturn == 0) && (intTemperatureRange > 0))
			intTemperatureNear = (intTemperature - intTemperatureRange)
			if((intTemperatureNear < -273) || (intTemperatureNear > 100))
				lenReturn = 0
			else
				if(intTemperatureNear < 0)
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
		if( ((((intTemperature - intTemperatureRange) < -273) || ((intTemperature - intTemperatureRange) > 100))) && ((((intTemperature + intTemperatureRange) < -273) || ((intTemperature + intTemperatureRange) > 100))) )
			print "PLEMd2d1CorrectionConstructor: Correction Wave not found for Grating: " + num2str(intGrating) + ", Detector: " + num2str(intDetector) + ", Temperature: " + num2str(intTemperature)
			return ""
		endif

		if(lenReturn == 0)
			intTemperatureRange = intTemperatureRange + 5
		else
			break
		endif
	while (lenReturn == 0)
	strConstructor = strConstructorNear
	print "PLEMd2d1CorrectionConstructor: Correction Wave used: " + strConstructor

	strX = PLEMd2d1CorrectionWave("WL_" + strConstructor)
	strY =  PLEMd2d1CorrectionWave("E_" + strConstructor)
	if((WaveExists($strX)) && (WaveExists($strY)))
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
	if(!waveExists(wavX) && !waveExists(wavY))
		print "Error: Waves Do not exist or user cancelled at Prompt"
		return ""
	endif

	if(!WaveExists($strOut))
		Duplicate/O wavY $strOut
	else
		if(!StringMatch(GetWavesDataFolder(wavY, 2),GetWavesDataFolder($strOut, 2)))
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

	Variable temp
	if(left > right)
		temp=left
		left=right
		right=temp
		temp=0
	endif
End

//Get number of map. in Menu-List.
Function PLEMd2numPLEM(strPLEM)
	String strPLEM

	DFREF dfr = $cstrPLEMd2root
	string strMaps = PLEMd2getStrMapsAvailable()

	return FindListItem(strPLEM, strMaps)
End

Function/S PLEMd2strPLEM(numPLEM)
	Variable numPLEM

	DFREF dfr = $cstrPLEMd2root
	string strMaps = PLEMd2getStrMapsAvailable()

	return StringFromList(numPLEM, strMaps)
End

Function/WAVE PLEMd2getAllstrPLEM([forceRenew])
	Variable forceRenew

	String strPLEM
	Variable i
	Variable numMaps = PLEMd2getMapsAvailable()

	DFREF dfr = $cstrPLEMd2root
	Struct PLEMd2stats stats

	forceRenew = ParamIsDefault(forceRenew) ? 0 : !!forceRenew

	WAVE/T/Z wv = dfr:mapsAvailable
	if(WaveExists(wv) && !forceRenew)
		if(DimSize(wv, 0) == numMaps)
			return wv
		else
			Redimension/N=(numMaps) wv
		endif
	else
		Make/O/T/N=(numMaps) dfr:mapsAvailable/WAVE=wv
	endif

	wv[] = PLEMd2strPLEM(p)

	return wv
End

Function/WAVE PLEMd2getCoordinates([forceRenew])
	Variable forceRenew

	Variable i
	Variable numMaps = PLEMd2getMapsAvailable()

	DFREF dfr = $cstrPLEMd2root
	Struct PLEMd2stats stats

	forceRenew = ParamIsDefault(forceRenew) ? 0 : !!forceRenew

	WAVE/Z wv = dfr:coordinates
	if(WaveExists(wv) && !forceRenew)
		if(DimSize(wv, 0) == numMaps)
			return wv
		else
			Redimension/N=(numMaps, -1) wv
		endif
	else
		Make/O/N=(numMaps, 3) dfr:coordinates/WAVE=wv = NaN
	endif

	WAVE/T wavStrPLEM = PLEMd2getAllstrPLEM()
	for(i = 0; i < numMaps; i += 1)
		PLEMd2statsLoad(stats, wavStrPLEM[i])
		wv[i][0] = stats.numPositionX
		wv[i][1] = stats.numPositionY
		wv[i][2] = stats.numPositionZ
	endfor

	return wv
End

// Get the excitation Power from the maps in the given range
//
// @param overwrite if set to 1: recreate the wave if it already exists
// @param range     specify the spectra ids with a numeric, uint wave
Function/WAVE PLEMd2getPower([overwrite, range])
	Variable overwrite
	WAVE/U/I range

	Variable i, dim0, dim1

	DFREF dfr = $cstrPLEMd2root
	Struct PLEMd2stats stats

	overwrite = ParamIsDefault(overwrite) ? 0 : !!overwrite

	if(ParamIsDefault(range))
		Make/FREE/U/I/N=(PLEMd2getMapsAvailable()) range = p
	endif
	dim0 = DimSize(range, 0)

	WAVE/Z wv = dfr:power
	if(WaveExists(wv) && !overwrite)
		if(DimSize(wv, 0) == dim0)
			return wv
		endif
	endif

	PLEMd2statsLoad(stats, PLEMd2strPLEM(range[0]))
	dim1 = DimSize(stats.wavPLEM, 1)
	if(dim1 == 1)
		dim1 = 0
	endif
	Make/O/N=(dim0, dim1) dfr:power/WAVE=wv = NaN

	WAVE/T wavStrPLEM = PLEMd2getAllstrPLEM()
	for(i = 0; i < dim0; i += 1)
		PLEMd2statsLoad(stats, wavStrPLEM[range[i]])
		wv[i][] = stats.wavYpower[q]
	endfor

	printf "PLEMd2getPower: created %s\r", GetWavesDataFolder(wv, 2)

	return wv
End

Function/WAVE PLEMd2getPhoton([forceRenew])
	Variable forceRenew

	Variable i
	Variable numMaps = PLEMd2getMapsAvailable()

	DFREF dfr = $cstrPLEMd2root
	Struct PLEMd2stats stats

	forceRenew = ParamIsDefault(forceRenew) ? 0 : !!forceRenew

	WAVE/Z wv = dfr:photon
	if(WaveExists(wv) && !forceRenew)
		if(DimSize(wv, 0) == numMaps)
			return wv
		else
			Redimension/N=(numMaps, -1) wv
		endif
	else
		PLEMd2statsLoad(stats, PLEMd2strPLEM(0))
		Make/O/N=(numMaps, DimSize(stats.wavPLEM, 1)) dfr:photon/WAVE=wv = NaN
	endif

	WAVE/T wavStrPLEM = PLEMd2getAllstrPLEM()
	for(i = 0; i < numMaps; i += 1)
		PLEMd2statsLoad(stats, wavStrPLEM[i])
		wv[i][] = stats.wavYphoton[q]
	endfor

	print GetWavesDataFolder(wv, 0)
	return wv
End
