#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function PLEMd2Display(strPLEM)
	String strPLEM

	Struct PLEMd2Stats stats
	String winPLEM
	PLEMd2statsLoad(stats, strPLEM)

	// check if spectrum is a valid input
	if((strlen(stats.strPLEMfull)==0) || (strlen(stats.strPLEM)==0))
		print "PLEMd2Display: Error stats.strPLEMfull not set for Map: " + strPLEM + " check code"
		return 0
	endif
	if(WaveExists($(stats.strPLEMfull)) == 0)
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
	if(V_flag == 1)
		CheckDisplayed/W=$winPLEM stats.wavPLEM
		if(V_Flag)
			print stats.strPLEM, "window found"
		endif
		return 0
	elseif(V_flag == 2)
		print "PLEMd2Display: Graph was hidden. Case not handled. check code"
	elseif(V_flag == 0)
		Display
		DoWindow/C/N/R $winPLEM
		if((stats.numCalibrationMode == 1) && (stats.numReadOutMode != 1))
			AppendToGraph stats.wavPLEM vs stats.wavWavelength
			ModifyGraph/W=$winPLEM standoff=0
			SetAxis/W=$winPLEM/A left
			Label/W=$winPLEM left "intensity / a.u."
			Label/W=$winPLEM bottom "wavelength / nm (Excitation at "+num2str(stats.numEmissionStart)+"-"+num2str(stats.numEmissionEnd)+")"
		else
			//AppendImage stats.wavPLEM vs {stats.wavWavelength, stats.wavExcitation}
			AppendImage stats.wavPLEM
			PLEMd2Decorate(strWinPLEM = winPLEM, booImage = (stats.numReadOutMode == 1))
		endif
	endif
End

Function PLEMd2DisplayByNum(numPLEM)
	Variable numPLEM
	if(numPLEM < 0)
		print "PLEMd2DisplayByNum: Wrong Function Call numPLEM out of range"
		return 0
	endif
	String strPLEM
	strPLEM = PLEMd2strPLEM(numPLEM)
	PLEMd2Display(strPLEM)
End

Function PLEMd2Decorate([strWinPLEM, booImage])
	String strWinPLEM
	Variable booImage
	Variable numZmin, numZmax
	Variable numXmin, numXmax
	Variable numYmin, numYmax
	String strImages

	// if no argument was selected, take top graph window
	if(ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if(ParamIsDefault(booImage))
		booImage = 0
	endif

	if(strlen(strWinPLEM) == 0)
		Print "PLEMd2Decorate: No window to append to"
		return 0
	endif

	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEM, ";")
	if(ItemsInList(strImages) != 1)
		Print "PLEMd2Decorate: No Image found in top graph or More than one Image present"
	endif
	wave wavImage = ImageNameToWaveRef(strWinPLEM,StringFromList(0,strImages))

	// get min and max of wave (statistically corrected)
	WaveStats/Q/W wavImage
	wave M_WaveStats
	numZmin = M_WaveStats[10]	//minimum
	numZmin = M_WaveStats[3]-sign(M_WaveStats[3])*2*M_WaveStats[4] //statistical minimum
	if(numZmin<0)
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
	ModifyImage/W=$strWinPLEM ''#0 ctab= {*,*,Terrain256,0}
	ModifyGraph/W=$strWinPLEM standoff=0
	ModifyGraph/W=$strWinPLEM height={Aspect,((numYmax-numYmin)/(numXmax-numXmin))}
	ModifyGraph/W=$strWinPLEM height = 0

	SetAxis/W=$strWinPLEM left,numYmin, numYmax
	SetAxis/W=$strWinPLEM/A left
	SetAxis/W=$strWinPLEM bottom,numXmin,numXmax
	SetAxis/W=$strWinPLEM/A bottom

	if(booImage)
		ModifyGraph zero=1
		Label/W=$strWinPLEM left "position / µm"
		Label/W=$strWinPLEM bottom "position / µm"
	else
		Label/W=$strWinPLEM left "excitation / nm"
		Label/W=$strWinPLEM bottom "emission / nm"
	endif
End

Function PLEMd2ShowNote([strWinPLEM])
	String strWinPLEM

	String strWinPLEMbase, strPLEM
	String strImages, strTraces, strDataFolderMap, strDataFolderInfo
	Struct PLEMd2Stats stats

	// if no argument was selected, take top graph window
	if(ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if(strlen(strWinPLEM) == 0)
		Print "PLEMd2ShowNote: base window not found"
		return 0
	endif
	// take parent window
	strWinPLEMbase = strWinPLEM[0,(strsearch(strWinPLEM, "#",0)-1)]
	// if the panel is already shown, do nothing
	DoUpdate /W=$strWinPLEMbase#PLEMd2WaveNote
	if(V_flag != 0)
		Print "PLEMd2ShowNote: Panel already exists."
		return 0
	endif

	// get the image name and wave reference.
	strPLEM = PLEMd2window2strPLEM(strWinPLEMbase)
	PLEMd2statsLoad(stats, strPLEM)
	wave wavPLEM = stats.wavPLEM
	CheckDisplayed wavPLEM
	if( V_Flag != 1 )
		print "PLEMd2ShowNote: wrong panel. wave not found"
	endif

	// display Note
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
	if(ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if(strlen(strWinPLEM) == 0)
		Print "PLEMd2Panel: No window to append to"
		return 0
	endif

	// if the panel is already shown, do nothing
	DoUpdate /W=$strWinPLEM#PLEMd2Panel
	if(V_flag != 0)
		Print "PLEMd2Panel: Panel already exists."
		return 0
	endif

	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEM, ";")
	if(ItemsInList(strImages) == 0)
		strTraces = TraceNameList(strWinPLEM, ";",1)
		if(ItemsInList(strTraces) == 1)
			wave wavPLEM = TraceNameToWaveRef(strWinPLEM,StringFromList(0,strTraces))
		else
			Print "PLEMd2Panel: No Image found. More than one or no trace found in top graph."
			return 0
		endif
	elseif(ItemsInList(strImages) > 1)
		Print "PLEMd2Panel: More than one image found in top graph."
		return 0
	else
		wave wavPLEM = ImageNameToWaveRef(strWinPLEM,StringFromList(0,strImages))
	endif
	// check for INFO folder
	strDataFolderMap = GetWavesDataFolder(wavPLEM,1)
	strDataFolderInfo = strDataFolderMap + "INFO:"
	if(DataFolderExists(strDataFolderInfo) == 0)
		Print "PLEMd2Panel: INFO Data Folder for Image in top graph not found."
		return 0
	endif
	NewPanel /N=PLEMd2Panel/W=(0,0,300,250) /EXT=0 /HOST=$strWinPLEM
	TitleBox/Z gstrPLEMfull			variable=$(strDataFolderInfo + "gstrPLEMfull"), 			pos={0,0}, 		size={130,0}, disable=0, frame=0, font="Helvetica"
	SetVariable normalization,		value=$(strDataFolderInfo + "gnumNormalization"),			pos={150,80}, 	title="normalization", size={130,0}, proc=SetVarProcCalculate
	SetVariable delatX,				value=$(strDataFolderInfo + "gnumPLEMDeltaX"),				pos={150,100},	title="deltaX", size={130,0}, noedit=1
	CheckBox boxBackground 			variable=$(strDataFolderInfo + "gbooBackground"), 			pos={10,20}, 	title="background", proc=CheckProcCalculate
	CheckBox boxPower 				variable=$(strDataFolderInfo + "gbooPower"), 				pos={10,40}, 	title="power", proc=CheckProcCalculate
	CheckBox boxPhoton				variable=$(strDataFolderInfo + "gbooPhoton"), 				pos={10,60}, 	title="photon", proc=CheckProcCalculate
	CheckBox boxGrating 				variable=$(strDataFolderInfo + "gbooGrating"), 				pos={10,120}, 	title="grating", proc=CheckProcCalculate
	CheckBox boxQuantumEfficiency	variable=$(strDataFolderInfo + "gbooQuantumEfficiency"),	pos={10,160}, 	title="detector", proc=CheckProcCalculate
	CheckBox boxNormalization		variable=$(strDataFolderInfo + "gbooNormalization"), 		pos={10,80}, 	title="normalization", proc=CheckProcCalculate
	CheckBox boxFilter				variable=$(strDataFolderInfo + "gbooFilter"), 				pos={10,140}, 	title="filter", proc=CheckProcCalculate
	CheckBox boxInterpolate			variable=$(strDataFolderInfo + "gbooInterpolate"), 			pos={10,100}, 	title="interpolate", proc=CheckProcCalculate

	Button ProcessIBW, pos={150, 30}, size={130,30}, proc=ButtonProcProcessIBW,title="reset"
//	Button BuildMaps, pos={150, 180}, size={130,30}, proc=ButtonProcBuildMaps,title="calculate"
	Button ShowNote, pos={150, 140}, size={130,30}, proc=ButtonProcShowNote,title="WaveNote"
	DoWindow PLEMd2Panel
End

Function PLEMd2PanelAtlas([strWinPLEM])
	String strWinPLEM
	String strImages, strTraces, strDataFolderMap, strDataFolderInfo
	// if no argument was selected, take top graph window
	if(ParamIsDefault(strWinPLEM))
		strWinPLEM = WinName(0, 1, 1)
	endif
	if(strlen(strWinPLEM) == 0)
		Print "PLEMd2Atlas: No window to append to"
		return 0
	endif

	// if the panel is already shown, do nothing
	DoUpdate /W=$strWinPLEM#PLEMd2PanelAtlas
	if(V_flag != 0)
		Print "PLEMd2Atlas: Panel already exists."
	endif

	// get the image name and wave reference.
	strImages = ImageNameList(strWinPLEM, ";")
	if(ItemsInList(strImages) == 0)
		strTraces = TraceNameList(strWinPLEM, ";",1)
		if(ItemsInList(strTraces) == 1)
			wave wavPLEM = TraceNameToWaveRef(strWinPLEM,StringFromList(0,strTraces))
			Print "PLEMd2Atlas: Traces not yet handled"
			return 0
		else
			Print "PLEMd2Atlas: No Image found. More than one or no trace found in top graph."
			return 0
		endif
	elseif(ItemsInList(strImages) > 1)
		Print "PLEMd2Atlas: More than one image found in top graph."
		return 0
	else
		wave wavPLEM = ImageNameToWaveRef(strWinPLEM,StringFromList(0,strImages))
	endif
	// check for INFO folder
	strDataFolderMap = GetWavesDataFolder(wavPLEM,1)
	strDataFolderInfo = strDataFolderMap + "INFO:"
	if(DataFolderExists(strDataFolderInfo) == 0)
		Print "PLEMd2Panel: INFO Data Folder for Image in top graph not found."
		return 0
	endif
	NewPanel /N=PLEMd2PanelAtlas/W=(0,0,300,100) /EXT=2 /HOST=$strWinPLEM
	SetVariable 	gnumS1offset,	proc=VariableProcAtlasRecalculate,	value=$(strDataFolderInfo + "gnumS1offset"),	pos={10,10}, 	size={130,0}
	SetVariable 	gnumS2offset,	proc=VariableProcAtlasRecalculate,	value=$(strDataFolderInfo + "gnumS2offset"),	pos={10,30}, 	size={130,0}
	Button 		AtlasReset,		proc=ButtonProcAtlasReset,	title="reset",			pos={10, 50},	size={50,25}
	Button 		AtlasShow,		proc=ButtonProcAtlasShow,	title="show",			pos={150, 10},	size={50,25}
	Button		AtlasHide,		proc=ButtonProcAtlasHide,		title="hide",			pos={150, 40},	size={50,25}
	Button		AtlasFit3D,		proc=ButtonProcAtlasFit3D,	title="fit3D",			pos={200, 10},	size={50,25}
	Button		AtlasFit2D,		proc=ButtonProcAtlasFit2D,	title="fit2D",			pos={200, 40},	size={50,25}
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

Function ButtonProcAtlasFit3D(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(ba.win)
			PLEMd2AtlasFit3D(strPLEM)
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

Function CheckProcCalculate(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String strPLEM
			strPLEM = PLEMd2window2strPLEM(cba.win)
			PLEMd2BuildMaps(strPLEM)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function SetVarProcCalculate(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			if(dval != 0)
				String strPLEM
				strPLEM = PLEMd2window2strPLEM(sva.win)
				PLEMd2BuildMaps(strPLEM)
			endif
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

	if(numEnd == -1 && numStart != -1)
		return strWindow[numStart+4,inf]
	else
		return strWindow[numStart+4,numEnd-1]
	endif
End
