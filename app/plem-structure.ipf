#pragma TextEncoding = "UTF-8"		// For details execute DisplayHelpTopic "The TextEncoding Pragma"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Structure for storing Information about a PLE-Map
Structure PLEMd2stats
	//Versioning System to update/create new Global vars.
	Variable numVersion
	//strPLEM is Name of Map
	//strDataFolder is Folder to Main directory
	//strDataFolderOriginal is Folder to Processed IBW data Main:ORIGINAL
	//numPLEM is number of Map in Menu Entry-List
	//wavPLEM is the wave reference to :PLEM
	String strPLEM, strDataFolder, strDataFolderOriginal
	Variable numPLEM
	//2D-Waves
	Wave wavPLEM, wavMeasure, wavBackground
	//1D-Waves
	Wave wavExcitation, wavWavelength
	Wave wavYpower, wavYphoton, wavGrating
	// Normalization Value
	Variable numNormalization
	// Switches for calculation
	Variable booBackground, booPower, booPhoton, booGrating, booQuantumEfficiency, booNormalization, booFilter, booInterpolate
	// chirality waves
	Wave/D wavAtlasS1nm, wavAtlasS2nm, wavAtlasN, wavAtlasM, wavAtlasNM
	Wave/D wavEnergyS1, wavEnergyS2, wavChiralityn, wavChiralitym, wav2Dfit, wav1Dfit
	Wave/T wavChiralitynm
	Wave wavPLEMfit, wavPLEMfitSingle
	// Variables for chirality offset
	Variable 	numS1offset, numS2offset
	// calculated variables
	Variable numPLEMTotalX, numPLEMLeftX, numPLEMDeltaX, numPLEMRightX
	Variable numPLEMTotalY, numPLEMBottomY, numPLEMDeltaY, numPLEMTopY 	//stats.numPLEMDeltaY

	// nanostage position
	variable numPositionX, numPositionY, numPositionZ, booSwitchX, booSwitchY

	// image mode information (PLEMv3.3)
	variable numReadOutMode, numLaserPositionX, numLaserPositionY, numMagnification

	// variables from IBW file
	String strDate, strUser, strFileName
	Variable numCalibrationMode, numSlit, numGrating, numFilter, numShutter, numWLcenter, numDetector, numCooling, numExposure, numBinning, numWLfirst, numWLlast, numWLdelta, numEmissionMode, numEmissionPower, numEmissionStart, numEmissionEnd, numEmissionDelta, numEmissionStep, numScans, numBackground
Endstructure

Function PLEMd2statsLoad(stats, strMap)
	Struct PLEMd2stats &stats
	String strMap

	DFREF dfrMap = returnMapFolder(strMap)
	Wave stats.wavPLEM 			= createWave(dfrMap, "PLEM")
	Wave stats.wavPLEMfitSingle	= createWave(dfrMap, "PLEMfit")
	Wave stats.wavMeasure 		= createWave(dfrMap, "MEASURE", setWaveType = PLEMd2WaveTypeUnsigned16)
	Wave stats.wavBackground 	= createWave(dfrMap, "BACKGROUND", setWaveType = PLEMd2WaveTypeUnsigned16)
	Wave stats.wavExcitation 	= createWave(dfrMap, "yExcitation")
	Wave stats.wavWavelength 	= createWave(dfrMap, "xWavelength")
	Wave stats.wavYpower 		= createWave(dfrMap, "yPower")
	Wave stats.wavYphoton 		= createWave(dfrMap, "yPhoton")
	Wave stats.wavGrating 		= createWave(dfrMap, "xGrating")

	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	Wave/D stats.wavEnergyS1 		= createWave(dfrAtlas, "PLEMs1nm")
	Wave/D stats.wavEnergyS2 		= createWave(dfrAtlas, "PLEMs2nm")
	Wave/D stats.wavChiralityn 		= createWave(dfrAtlas, "PLEMchiralityn")
	Wave/D stats.wavChiralitym 		= createWave(dfrAtlas, "PLEMchiralitym")
	Wave/T stats.wavChiralitynm 	= createWave(dfrAtlas, "PLEMchirality", setWaveType = PLEMd2WaveTypeText)
	Wave/D stats.wavAtlasS1nm 		= createWave(dfrAtlas, "atlasS1nm")
	Wave/D stats.wavAtlasS2nm 		= createWave(dfrAtlas, "atlasS2nm")
	Wave/D stats.wavAtlasN 			= createWave(dfrAtlas, "atlasN")
	Wave/D stats.wavAtlasM 			= createWave(dfrAtlas, "atlasM")
	Wave/D stats.wav1Dfit 			= createWave(dfrAtlas, "fit1D")
	Wave/D stats.wav2Dfit 			= createWave(dfrAtlas, "fit2D")
	Wave/D stats.wavPLEMfit 		= createWave(dfrAtlas, "fitPLEM")

	// PLEMd2statsInitialize(strMap)
	stats.numVersion = getMapVariable(strMap, "gnumVersion")

	stats.numPLEM 				= getMapVariable(strMap, "gnumPLEM")
	stats.strPLEM				= getMapString(strMap, "gstrPLEM") // no magic here
	stats.strDataFolder			= getMapString(strMap, "gstrDataFolder")
	stats.strDataFolderOriginal	= getMapString(strMap, "gstrDataFolderOriginal")

	stats.numNormalization 	= getMapVariable(strMap, "gnumNormalization")
	stats.numNormalization 	= SelectNumber(stats.numNormalization != 0, 1, stats.numNormalization)

	stats.booBackground 		= getMapVariable(strMap, "gbooBackground")
	stats.booPower 				= getMapVariable(strMap, "gbooPower")
	stats.booPhoton 			= getMapVariable(strMap, "gbooPhoton")
	stats.booGrating  			= getMapVariable(strMap, "gbooGrating")
	stats.booQuantumEfficiency 	= getMapVariable(strMap, "gbooQuantumEfficiency")
	stats.booNormalization		= getMapVariable(strMap, "gbooNormalization")
	stats.booFilter				= getMapVariable(strMap, "gbooFilter")
	stats.booInterpolate 		= getMapVariable(strMap, "gbooInterpolate")

	stats.numS1offset 	= getMapVariable(strMap, "gnumS1offset")
	stats.numS2offset 	= getMapVariable(strMap, "gnumS2offset")

	stats.numPLEMTotalX = getMapVariable(strMap, "gnumPLEMTotalX")
	stats.numPLEMLeftX 	= getMapVariable(strMap, "gnumPLEMLeftX")
	stats.numPLEMDeltaX = getMapVariable(strMap, "gnumPLEMDeltaX")
	stats.numPLEMRightX = getMapVariable(strMap, "gnumPLEMRightX")

	stats.numPLEMTotalY		= getMapVariable(strMap, "gnumPLEMTotalY")
	stats.numPLEMBottomY 	= getMapVariable(strMap, "gnumPLEMBottomY")
	stats.numPLEMDeltaY		= getMapVariable(strMap, "gnumPLEMDeltaY")
	stats.numPLEMTopY		= getMapVariable(strMap, "gnumPLEMTopY")

	stats.strDate 		= getMapString(strMap, "gstrDate")
	stats.strUser		= getMapString(strMap, "gstrUser")
	stats.strFileName 	= getMapString(strMap, "gstrFileName")

	stats.numCalibrationMode 	= getMapVariable(strMap, "gnumCalibrationMode")
	stats.numSlit 				= getMapVariable(strMap, "gnumSlit")
	stats.numGrating 			= getMapVariable(strMap, "gnumGrating")
	stats.numFilter 			= getMapVariable(strMap, "gnumFilter")
	stats.numShutter 			= getMapVariable(strMap, "gnumShutter")
	stats.numWLcenter 			= getMapVariable(strMap, "gnumWLcenter")
	stats.numDetector 			= getMapVariable(strMap, "gnumDetector")
	stats.numCooling 			= getMapVariable(strMap, "gnumCooling")
	stats.numExposure 			= getMapVariable(strMap, "gnumExposure")
	stats.numBinning 			= getMapVariable(strMap, "gnumBinning")
	stats.numWLfirst 			= getMapVariable(strMap, "gnumWLfirst")
	stats.numWLlast 			= getMapVariable(strMap, "gnumWLlast")
	stats.numWLdelta 			= getMapVariable(strMap, "gnumWLdelta")
	stats.numEmissionMode 		= getMapVariable(strMap, "gnumEmissionMode")
	stats.numEmissionPower 		= getMapVariable(strMap, "gnumEmissionPower")
	stats.numEmissionStart 		= getMapVariable(strMap, "gnumEmissionStart")
	stats.numEmissionEnd 		= getMapVariable(strMap, "gnumEmissionEnd")
	stats.numEmissionDelta 		= getMapVariable(strMap, "gnumEmissionDelta")
	stats.numEmissionStep 		= getMapVariable(strMap, "gnumEmissionStep")
	stats.numScans 				= getMapVariable(strMap, "gnumScans")
	stats.numBackground 		= getMapVariable(strMap, "gnumBackground")

	stats.numPositionX 	= getMapVariable(strMap, "gnumPositionX")
	stats.numPositionY 	= getMapVariable(strMap, "gnumPositionY")
	stats.numPositionZ 	= getMapVariable(strMap, "gnumPositionZ")
	stats.booSwitchX 	= getMapVariable(strMap, "gbooSwitchX")
	stats.booSwitchY 	= getMapVariable(strMap, "gbooSwitchY")

	stats.numReadOutMode 	= getMapVariable(strMap, "gnumReadOutMode")
	stats.numLaserPositionX = getMapVariable(strMap, "gnumLaserPositionX")
	stats.numLaserPositionY = getMapVariable(strMap, "gnumLaserPositionY")
	stats.numMagnification 	= getMapVariable(strMap, "gnumMagnification")
End

Function PLEMd2statsSave(stats)
	Struct PLEMd2stats &stats
	String strMap = stats.strPLEM

	setMapVariable(strMap, "gnumVersion", stats.numVersion)

	setMapVariable(strMap, "gnumPLEM", stats.numPLEM)
	setMapString(strMap, "gstrPLEM", stats.strPLEM)
	setMapString(strMap, "gstrDataFolder", stats.strDataFolder)
	setMapString(strMap, "gstrDataFolderOriginal", stats.strDataFolderOriginal)

	setMapVariable(strMap, "gnumNormalization", stats.numNormalization)
	setMapVariable(strMap, "gbooBackground", stats.booBackground)
	setMapVariable(strMap, "gbooPower", stats.booPower)

	setMapVariable(strMap, "gbooPhoton", stats.booPhoton)
	setMapVariable(strMap, "gbooGrating", stats.booGrating)
	setMapVariable(strMap, "gbooQuantumEfficiency", stats.booQuantumEfficiency)
	setMapVariable(strMap, "gbooNormalization", stats.booNormalization)
	setMapVariable(strMap, "gbooFilter", stats.booFilter)
	setMapVariable(strMap, "gbooInterpolate", stats.booInterpolate)

	setMapVariable(strMap, "gnumS1offset", stats.numS1offset)
	setMapVariable(strMap, "gnumS2offset", stats.numS2offset)

	setMapVariable(strMap, "gnumPLEMTotalX", stats.numPLEMTotalX)
	setMapVariable(strMap, "gnumPLEMLeftX", stats.numPLEMLeftX)
	setMapVariable(strMap, "gnumPLEMDeltaX", stats.numPLEMDeltaX)
	setMapVariable(strMap, "gnumPLEMRightX", stats.numPLEMRightX)

	setMapVariable(strMap, "gnumPLEMTotalY", stats.numPLEMTotalY)
	setMapVariable(strMap, "gnumPLEMBottomY ", stats.numPLEMBottomY)
	setMapVariable(strMap, "gnumPLEMDeltaY", stats.numPLEMDeltaY)
	setMapVariable(strMap, "gnumPLEMTopY", stats.numPLEMTopY)

	setMapString(strMap, "gstrDate", stats.strDate)
	setMapString(strMap, "gstrUser", stats.strUser)
	setMapString(strMap, "gstrFileName", stats.strFileName)

	setMapVariable(strMap, "gnumCalibrationMode", stats.numCalibrationMode)
	setMapVariable(strMap, "gnumSlit", stats.numSlit)
	setMapVariable(strMap, "gnumGrating", stats.numGrating)
	setMapVariable(strMap, "gnumFilter", stats.numFilter)
	setMapVariable(strMap, "gnumShutter", stats.numShutter)
	setMapVariable(strMap, "gnumWLcenter", stats.numWLcenter)
	setMapVariable(strMap, "gnumDetector", stats.numDetector)
	setMapVariable(strMap, "gnumCooling", stats.numCooling)
	setMapVariable(strMap, "gnumExposure", stats.numExposure)
	setMapVariable(strMap, "gnumBinning", stats.numBinning)
	setMapVariable(strMap, "gnumScans", stats.numScans)
	setMapVariable(strMap, "gnumBackground", stats.numBackground)
	setMapVariable(strMap, "gnumWLfirst", stats.numWLfirst)
	setMapVariable(strMap, "gnumWLlast", stats.numWLlast)
	setMapVariable(strMap, "gnumWLdelta", stats.numWLdelta)
	setMapVariable(strMap, "gnumEmissionMode", stats.numEmissionMode)
	setMapVariable(strMap, "gnumEmissionPower", stats.numEmissionPower)
	setMapVariable(strMap, "gnumEmissionStart", stats.numEmissionStart)
	setMapVariable(strMap, "gnumEmissionEnd", stats.numEmissionEnd)
	setMapVariable(strMap, "gnumEmissionDelta", stats.numEmissionDelta)
	setMapVariable(strMap, "gnumEmissionStep", stats.numEmissionStep)

	setMapVariable(strMap, "gnumPositionX", stats.numPositionX)
	setMapVariable(strMap, "gnumPositionY", stats.numPositionY)
	setMapVariable(strMap, "gnumPositionZ", stats.numPositionZ)
	setMapVariable(strMap, "gbooSwitchX", stats.booSwitchX)
	setMapVariable(strMap, "gbooSwitchY", stats.booSwitchY)

	setMapVariable(strMap, "gnumReadOutMode", stats.numReadOutMode)
	setMapVariable(strMap, "gnumLaserPositionX", stats.numLaserPositionX)
	setMapVariable(strMap, "gnumLaserPositionY", stats.numLaserPositionY)
	setMapVariable(strMap, "gnumMagnification", stats.numMagnification)
End

Function PLEMd2statsInitialize(strMap)
//Initialize the stats struct without calling the load procedure
//**on Version-Missmatch
//**if Folder INFO is not there.
	String strMap
	Struct PLEMd2Stats stats

	if(PLEMd2isInit() != 1)
		print "PLEMd2statsInitialize: PLEMd2isInit returned false"
		return 0
	endif
	PLEMd2statsLoad(stats, strMap)

	stats.numPLEM = PLEMd2AddMap(strMap)
	stats.strPLEM = strMap
	stats.strDataFolder =  GetDataFolder(1, returnMapFolder(strMap))
	stats.numVersion = cPLEMd2Version

	stats.numNormalization = 1

	stats.booBackground 	= 1
	stats.booPower 		= 0
	stats.booPhoton 		= 0
	stats.booGrating  	= 0
	stats.booQuantumEfficiency = 0
	stats.booNormalization		= 0
	stats.booFilter		= 0
	stats.booInterpolate = 0

	PLEMd2statsSave(stats)

End

Function PLEMd2statsCalculateDeprecated(stats)
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
	SetDataFolder $cstrPLEMd2root
	SVAR gstrMapsFolder

	String strMap = gstrMapsFolder + ":" + strPLEM + ":PLEM"

	SetDataFolder $strSaveDataFolder
	return strMap
End
