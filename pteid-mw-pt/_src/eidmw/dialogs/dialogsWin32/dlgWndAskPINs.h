/* ****************************************************************************

 * eID Middleware Project.
 * Copyright (C) 2008-2009 FedICT.
 * Copyright (C) 2019 Caixa Magica Software.
 * Copyright (C) 2011 Vasco Silva - <vasco.silva@caixamagica.pt>
 * Copyright (C) 2018 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2019 Miguel Figueira - <miguelblcfigueira@gmail.com>
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version
 * 3.0 as published by the Free Software Foundation.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, see
 * http://www.gnu.org/licenses/.

**************************************************************************** */

#include "stdafx.h"
#include "../dialogs.h"

using namespace eIDMW;

class dlgWndAskPINs : public Win32Dialog {
	void GetPinResult();
	bool CheckPin2Result();

	PteidControls::TextData titleData, headerTextData, errorTextData;
	PteidControls::TextFieldData textFieldData1, textFieldData2, textFieldData3;
	PteidControls::ButtonData okBtnProcData, cancelBtnProcData;

	bool m_dontAskPIN1;
	unsigned char m_UK_InputField;

	const wchar_t *szHeader;
	const wchar_t *szPIN;

public:
	dlgWndAskPINs(DlgPinInfo pinInfo1, DlgPinInfo pinInfo2, std::wstring &Header, std::wstring &title, bool isUnlock,
				  bool dontAskPUK, HWND Parent = NULL);
	virtual ~dlgWndAskPINs();

	wchar_t Pin1Result[128];
	wchar_t Pin2Result[128];

	virtual LRESULT ProcecEvent(UINT uMsg,		// Message For This Window
								WPARAM wParam,	// Additional Message Information
								LPARAM lParam); // Additional Message Information
};
