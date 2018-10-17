#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3

Menu "PLEM", dynamic //create menu bar entry
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
		PLEMd2MenuInit()+"Init",/q, PLEMd2()
		"Open", PLEMd2open()
		"Decorate Image",PLEMd2Decorate()
		"Info", PLEMd2Panel()
		"Atlas", PLEMd2PanelAtlas()
//		"-"
//		"Clean up Variables", PLEMd2Clean()
//	End
	SubMenu "Display"
	//List all available Maps in current project (max 30)
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
		PLEMd2Menu(15), PLEMd2DisplayByNum(15)
		PLEMd2Menu(16), PLEMd2DisplayByNum(16)
		PLEMd2Menu(17), PLEMd2DisplayByNum(17)
		PLEMd2Menu(18), PLEMd2DisplayByNum(18)
		PLEMd2Menu(19), PLEMd2DisplayByNum(19)
		PLEMd2Menu(20), PLEMd2DisplayByNum(20)
		PLEMd2Menu(21), PLEMd2DisplayByNum(21)
		PLEMd2Menu(22), PLEMd2DisplayByNum(22)
		PLEMd2Menu(23), PLEMd2DisplayByNum(23)
		PLEMd2Menu(24), PLEMd2DisplayByNum(24)
		PLEMd2Menu(25), PLEMd2DisplayByNum(25)
		PLEMd2Menu(26), PLEMd2DisplayByNum(26)
		PLEMd2Menu(27), PLEMd2DisplayByNum(27)
		PLEMd2Menu(28), PLEMd2DisplayByNum(28)
		PLEMd2Menu(29), PLEMd2DisplayByNum(29)
	End
	SubMenu "Duplicate"
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
		PLEMd2Menu(15), PLEMd2DuplicateByNum(15)
		PLEMd2Menu(16), PLEMd2DuplicateByNum(16)
		PLEMd2Menu(17), PLEMd2DuplicateByNum(17)
		PLEMd2Menu(18), PLEMd2DuplicateByNum(18)
		PLEMd2Menu(19), PLEMd2DuplicateByNum(19)
		PLEMd2Menu(20), PLEMd2DuplicateByNum(20)
		PLEMd2Menu(21), PLEMd2DuplicateByNum(21)
		PLEMd2Menu(22), PLEMd2DuplicateByNum(22)
		PLEMd2Menu(23), PLEMd2DuplicateByNum(23)
		PLEMd2Menu(24), PLEMd2DuplicateByNum(24)
		PLEMd2Menu(25), PLEMd2DuplicateByNum(25)
		PLEMd2Menu(26), PLEMd2DuplicateByNum(26)
		PLEMd2Menu(27), PLEMd2DuplicateByNum(27)
		PLEMd2Menu(28), PLEMd2DuplicateByNum(28)
		PLEMd2Menu(29), PLEMd2DuplicateByNum(29)
	End
	SubMenu "Kill"
		PLEMd2Menu(0), PLEMd2KillMapByNum(0)
		PLEMd2Menu(1), PLEMd2KillMapByNum(1)
		PLEMd2Menu(2), PLEMd2KillMapByNum(2)
		PLEMd2Menu(3), PLEMd2KillMapByNum(3)
		PLEMd2Menu(4), PLEMd2KillMapByNum(4)
		PLEMd2Menu(5), PLEMd2KillMapByNum(5)
		PLEMd2Menu(6), PLEMd2KillMapByNum(6)
		PLEMd2Menu(7), PLEMd2KillMapByNum(7)
		PLEMd2Menu(8), PLEMd2KillMapByNum(8)
		PLEMd2Menu(9), PLEMd2KillMapByNum(9)
		PLEMd2Menu(10), PLEMd2KillMapByNum(10)
		PLEMd2Menu(11), PLEMd2KillMapByNum(11)
		PLEMd2Menu(12), PLEMd2KillMapByNum(12)
		PLEMd2Menu(13), PLEMd2KillMapByNum(13)
		PLEMd2Menu(14), PLEMd2KillMapByNum(14)
		PLEMd2Menu(15), PLEMd2KillMapByNum(15)
		PLEMd2Menu(16), PLEMd2KillMapByNum(16)
		PLEMd2Menu(17), PLEMd2KillMapByNum(17)
		PLEMd2Menu(18), PLEMd2KillMapByNum(18)
		PLEMd2Menu(19), PLEMd2KillMapByNum(19)
		PLEMd2Menu(20), PLEMd2KillMapByNum(20)
		PLEMd2Menu(21), PLEMd2KillMapByNum(21)
		PLEMd2Menu(22), PLEMd2KillMapByNum(22)
		PLEMd2Menu(23), PLEMd2KillMapByNum(23)
		PLEMd2Menu(24), PLEMd2KillMapByNum(24)
		PLEMd2Menu(25), PLEMd2KillMapByNum(25)
		PLEMd2Menu(26), PLEMd2KillMapByNum(26)
		PLEMd2Menu(27), PLEMd2KillMapByNum(27)
		PLEMd2Menu(28), PLEMd2KillMapByNum(28)
		PLEMd2Menu(29), PLEMd2KillMapByNum(29)
	End
End

Function/S PLEMd2Menu(numPLEM)
	//directory persistent
	Variable numPLEM
	String strReturn = ""

	//dynamic Menus are called every time the menu bar is pressed.
	//global Variables should not automatically occur in other projects. so don't create them.
	if(PLEMd2isInit())
		SVAR gstrMapsAvailable = $(cstrPLEMd2root + ":gstrMapsAvailable")
		NVAR gnumMapsAvailable	 = $(cstrPLEMd2root + ":gnumMapsAvailable")
		if(numPLEM<gnumMapsAvailable)
			strReturn = StringFromList(numPLEM, gstrMapsAvailable)
		endif
	endif

	return strReturn
End

Function/t PLEMd2MenuInit()
	if(PLEMd2isInit())
		return "!" + num2char(18) //on
	else
		return "" // off
	endif
End
