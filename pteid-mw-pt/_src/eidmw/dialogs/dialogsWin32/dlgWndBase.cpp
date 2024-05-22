/* ****************************************************************************

 * eID Middleware Project.
 * Copyright (C) 2008-2009 FedICT.
 * Copyright (C) 2019 Caixa Magica Software.
 * Copyright (C) 2011 Vasco Silva - <vasco.silva@caixamagica.pt>
 * Copyright (C) 2018 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2019-2020 Miguel Figueira - <miguelblcfigueira@gmail.com>
 * Copyright (C) 2019 Adriano Campos - <adrianoribeirocampos@gmail.com>
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
#include "dlgWndBase.h"
#include "../langUtil.h"
#include "Log.h"
#include <wingdi.h>
#include "dlgUtil.h"
#include "resource.h"

TD_WNDMAP WndMap;
Win32Dialog *Win32Dialog::Active_lpWnd = NULL;
HWND Win32Dialog::Active_hWnd = NULL;
extern HMODULE g_hDLLInstance; // = (HMODULE)NULL;

Win32Dialog::Win32Dialog(const wchar_t *appName) {
	m_ModalHold = true;
	m_hDC = NULL;				  // Private GDI Device Context
	m_hWnd = NULL;				  // Holds Our Window Handle
	m_hInstance = g_hDLLInstance; // Grab An Instance From our DLL module to become able to Create our windows for/from
	// m_appName = "DialogBase";		// Application Core-Name
	dlgResult = eIDMW::DLG_CANCEL; // Dialog Result
	m_appName = _wcsdup(appName);

	int fontSizeTitle = 20;
	int fontSize = 14;

	if (PteidControls::StandardFontHeader == NULL)
		PteidControls::StandardFontHeader = PteidControls::CreatePteidFont(fontSizeTitle, FW_BLACK, m_hInstance);

	if (PteidControls::StandardFontBold == NULL)
		PteidControls::StandardFontBold = PteidControls::CreatePteidFont(fontSize, FW_BOLD, m_hInstance);

	if (PteidControls::StandardFont == NULL)
		PteidControls::StandardFont = PteidControls::CreatePteidFont(fontSize, FW_REGULAR, m_hInstance);

	int iconWidth = 36;
	int iconHeight = 36;
	ScaleDimensions(&iconWidth, &iconHeight);
	m_hAppIcon =
		(HBITMAP)LoadImage(m_hInstance, MAKEINTRESOURCE(IDB_BITMAP3), IMAGE_BITMAP, iconWidth, iconHeight, NULL);
}

Win32Dialog::~Win32Dialog() {
	if (m_hWnd)
		KillWindow();

	if (m_appName) {
		free(m_appName);
		m_appName = NULL;
	}

	m_ModalHold = false;
}

HWND Win32Dialog::createWindowWithParentFallback(DWORD dwExStyle, const wchar_t *title, DWORD dwStyle, int X, int Y,
												 int nWidth, int nHeight, HWND parent) {
	bool retried_creation = false;
	HWND new_window = NULL;
retry:
	if (!(new_window = CreateWindowEx(dwExStyle, m_appName, title, dwStyle, X, Y, nWidth, nHeight, parent, NULL,
									  m_hInstance, NULL))) {
		unsigned long err = GetLastError();
		if (err == ERROR_INVALID_WINDOW_HANDLE && !retried_creation) {
			parent = NULL;
			retried_creation = true;
			MWLOG(LEV_ERROR, MOD_DLG,
				  L"  --> Win32Dialog::createWindowWithParentFallback - Retrying Window creation with NULL parent",
				  err);
			goto retry;
		}
		KillWindow(); // Reset The Display
		MWLOG(LEV_ERROR, MOD_DLG,
			  L"  --> Win32Dialog::createWindowWithParentFallback - Window Creation Error - Error=%ld", err);
	}

	m_parent = parent;

	return new_window;
}

bool Win32Dialog::CreateWnd(const wchar_t *title, int width, int height, int Icon, HWND Parent) {
	if (m_hWnd)
		return false;

	MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::CreateWnd (Parent=%X)", Parent);

	DWORD dwExStyle; // Window Extended Style
	DWORD dwStyle;	 // Window Style
	RECT WindowRect; // Grabs Rectangle Upper Left / Lower Right Values
	RECT DeskRect;

	ScaleDimensions(&width, &height);

	WindowRect.left = (long)0;		  // Set Left Value To 0
	WindowRect.right = (long)width;	  // Set Right Value To Requested Width
	WindowRect.top = (long)0;		  // Set Top Value To 0
	WindowRect.bottom = (long)height; // Set Bottom Value To Requested Height
	GetClientRect(GetDesktopWindow(), &DeskRect);

	WNDCLASS wc; // Windows Class Structure
	HICON hIco;
	if (Icon == 0)
		hIco = LoadIcon(NULL, IDI_WINLOGO);
	else
		hIco = LoadIcon(m_hInstance, MAKEINTRESOURCE(Icon));

	wc.style = CS_HREDRAW | CS_VREDRAW | CS_DROPSHADOW; // 	            // Redraw On Size, And Drop Shadow
	wc.lpfnWndProc = (WNDPROC)WndProc;					// WndProc Handles Messages
	wc.cbClsExtra = 0;									// No Extra Window Data
	wc.cbWndExtra = 0;									// DLGWINDOWEXTRA;							// No Extra Window Data
	wc.hInstance = m_hInstance;							// Set The Instance
	wc.hIcon = hIco;									// Load The Default Icon
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);			// Load The Arrow Pointer
	wc.hbrBackground =
		CreateSolidBrush(RGB(255, 255, 255)); // CreateSolidBrush(RGB(255, 255, 255)); //(HBRUSH)GetSysColorBrush(
											  // COLOR_3DFACE );	// What Color we want in our background
	wc.lpszMenuName = NULL;					  // We Don't Want A Menu
	wc.lpszClassName = m_appName;			  // Set The Class Name

	if (!RegisterClass(&wc)) // Attempt To Register The Window Class
	{
		unsigned long err = GetLastError();
		MWLOG(LEV_WARN, MOD_DLG, L"  --> Win32Dialog::CreateWnd - Failed To Register The Window Class - Error=%ld",
			  err);
		return false; // Return FALSE
	}

	// dwStyle = WS_CAPTION | WS_VISIBLE |  WS_SYSMENU | WS_OVERLAPPED;
	dwStyle = WS_POPUP | WS_BORDER;

	// dwExStyle = WS_EX_LEFT | WS_EX_LTRREADING | WS_EX_WINDOWEDGE | WS_EX_TOPMOST | WS_EX_DLGMODALFRAME;
	dwExStyle = WS_EX_LEFT | WS_EX_LTRREADING | WS_EX_WINDOWEDGE | WS_EX_DLGMODALFRAME;
	if (m_ModalHold) {
		dwStyle |= WS_POPUP;
		dwExStyle |= WS_EX_WINDOWEDGE;
	}

	AdjustWindowRectEx(&WindowRect, dwStyle, FALSE, dwExStyle); // Adjust Window To True Requested Size

	Active_lpWnd = this;

	// Create The Window
	RECT parentWindow;
	if (Parent && IsWindow(Parent))
		GetWindowRect(Parent, &parentWindow);
	else
		parentWindow = DeskRect;
	int X = (parentWindow.right + parentWindow.left) / 2 - (WindowRect.right - WindowRect.left) / 2;
	int Y = (parentWindow.bottom + parentWindow.top) / 2 - (WindowRect.bottom - WindowRect.top) / 2;
	int nWidth = WindowRect.right - WindowRect.left;
	int nHeight = WindowRect.bottom - WindowRect.top;

	if (!(m_hWnd = createWindowWithParentFallback(dwExStyle, title, dwStyle, X, Y, nWidth, nHeight, Parent))) {
		return false;
	}

	SetWindowLong(m_hWnd, GWL_STYLE, 0); // remove all window styles, check MSDN for details

	// ShowWindow(m_hWnd, SW_SHOW);          //display window

	// Create The Window
	/*
   if( !( m_hWnd = Active_hWnd = CreateWindowEx(	dwExStyle,			// Extended Style For The Window
							   m_appName,							// Class Name
							   title,								// Window Title
							   dwStyle,							// Defined Window Style
							   DeskRect.right/2 - (WindowRect.right-WindowRect.left)/2,
							   DeskRect.bottom/2 - (WindowRect.bottom-WindowRect.top)/2,
							   //CW_USEDEFAULT, CW_USEDEFAULT,		// Window Position
							   WindowRect.right-WindowRect.left,	// Calculate Window Width
							   WindowRect.bottom-WindowRect.top,	// Calculate Window Height
							   Parent,								// No Parent Window
							   NULL,								// No Menu
							   m_hInstance,							// Instance
							   (LPVOID)Active_lpWnd)))								// Dont Pass Anything To WM_CREATE
   {
	   unsigned long err = GetLastError();
	   KillWindow( );								// Reset The Display
	   MWLOG(LEV_WARN, MOD_DLG, L"  --> Win32Dialog::CreateWnd - Window Creation Error - Error=%ld",err);
	   return false;								// Return FALSE
   }
   MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::CreateWnd - CreateWindowEx (m_hWnd=%X)",m_hWnd);

   */

	WndMap.insert(TD_WNDPAIR(m_hWnd, this));

	return true;
}

bool Win32Dialog::exec() {
	if (!m_hWnd)
		return false;

	ShowWindow(m_hWnd, SW_SHOW); // Show The Window
	// SetFocus( m_hWnd );								// Sets Keyboard Focus To The Window

	MSG msg;
	while (GetMessage(&msg, NULL, 0, 0) && m_ModalHold) {
		if (NULL == m_hWnd || !IsDialogMessage(m_hWnd, &msg)) {
			TranslateMessage(&msg); // Translate The Message
			DispatchMessage(&msg);	// Dispatch The Message
		}
	}
	return dlgResult != eIDMW::DLG_CANCEL;
}
void Win32Dialog::show() {
	ShowWindow(m_hWnd, SW_SHOW); // Show The Window
	SetFocus(m_hWnd);			 // Sets Keyboard Focus To The Window
}

void Win32Dialog::close() {
	// CloseWindow( m_hWnd ) and ShowWindow( m_hWnd, SW_MINIMIZE ) should do the same
	// but they don't.
	// This is a workarond for signing mail with Oulook 2003 (with Word as editor and 1 processor)
	// If the ShowWindow is used in place of the CloseWindow, Word hangs ?????

	CloseWindow(m_hWnd);
	// ShowWindow( m_hWnd, SW_MINIMIZE );					// Show The Window

	m_ModalHold = false; // Sets Keyboard Focus To The Window
}

void Win32Dialog::Destroy() {}

void Win32Dialog::KillWindow(void) // Properly Kill The Window
{
	if (!m_hWnd)
		return;

	if (m_hWnd && !DestroyWindow(m_hWnd)) // Are We Able To Destroy The Window?
	{
		MessageBox(NULL, L"Could Not Release hWnd.", L"SHUTDOWN ERROR", MB_OK | MB_ICONINFORMATION);
	}

	if (!UnregisterClass(m_appName, m_hInstance)) // Are We Able To Unregister Class
	{
		MessageBox(NULL, L"Could Not Unregister Class.", L"SHUTDOWN ERROR", MB_OK | MB_ICONINFORMATION);
	}

	WndMap.erase(m_hWnd);
	if (Active_hWnd == m_hWnd)
		Active_hWnd = NULL;

	if (m_hbrBkgnd) {
		DeleteObject(m_hbrBkgnd);
		m_hbrBkgnd = NULL;
	}

	m_hInstance = NULL; // Set hInstance To NULL
	m_hWnd = NULL;		// Set hWnd To NULL
	Destroy();
}

bool Win32Dialog::isFriend(HWND f_hWnd) {
	if (!WndMap.empty()) {
		try {
			TD_WNDMAP::iterator it_WndMap = WndMap.find(f_hWnd);
			if (it_WndMap != WndMap.end())
				return true;
		} catch (...) {
		}
	}

	return false;
}

LRESULT CALLBACK Win32Dialog::WndProc(HWND hWnd,	 // Handle For This Window
									  UINT uMsg,	 // Message For This Window
									  WPARAM wParam, // Additional Message Information
									  LPARAM lParam) // Additional Message Information
{
	if (!WndMap.empty()) {
		try // Call the WndProc Function from the 'HWND-Owner' Window Class
		{
			TD_WNDMAP::iterator it_WndMap = WndMap.find(hWnd);
			if (it_WndMap != WndMap.end())
				return (*it_WndMap).second->ProcecEvent(uMsg, wParam, lParam);
		} catch (...) {
		}
	}
	if (uMsg == WM_CREATE || uMsg == WM_NCCREATE) // Call the WndProc Function from the 'HWND-Owner' Window Class
												  // Retrieved from the lParam->(CREATESTRUCT *)lpCreateParams
	{
		try {
			if (((CREATESTRUCT *)lParam)->lpCreateParams == (LPVOID)Active_lpWnd) {
				((CREATESTRUCT *)lParam)->lpCreateParams =
					(LPVOID)hWnd; // Replace the Extra parameter with the handle to the window so the class resolving
								  // the message knows it's own handle too ( [Win32Dialog::CreateWnd(..)]CreateWindowEx
								  // did not yet return a value here )
				Active_lpWnd->ProcecEvent(uMsg, wParam, lParam);
			}
		} catch (...) {
		}
	}

	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

LRESULT Win32Dialog::ProcecEvent(UINT uMsg,		// Message For This Window
								 WPARAM wParam, // Additional Message Information
								 LPARAM lParam) // Additional Message Information
{
	if (m_hWnd == NULL)
		return 0;

	PAINTSTRUCT ps;
	RECT rect;

	switch (uMsg) {
	case WM_PAINT: {
		m_hDC = BeginPaint(m_hWnd, &ps);
		SetBkColor(m_hDC, GetSysColor(COLOR_3DFACE));
		GetClientRect(m_hWnd, &rect);
		DrawText(m_hDC, L"Virtual Hello World!", -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
		EndPaint(m_hWnd, &ps);

		SetForegroundWindow(m_hWnd);

		return 0;
	}

	case WM_NCACTIVATE: {
		MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::ProcecEvent WM_NCACTIVATE (wParam=%X, lParam=%X)", wParam,
			  lParam);

		if (!IsIconic(m_hWnd) && m_ModalHold && Active_hWnd == m_hWnd) {
			ShowWindow(m_hWnd, SW_SHOW);
			SetFocus(m_hWnd);
			return 0;
		}
		break;
	}

	case WM_KILLFOCUS: {
		MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::ProcecEvent WM_KILLFOCUS (wParam=%X, lParam=%X)", wParam,
			  lParam);

		if (!IsIconic(m_hWnd) && m_ModalHold && Active_hWnd == m_hWnd) {
			if (GetParent((HWND)wParam) != m_hWnd) {
				SetFocus(m_hWnd);
				return 0;
			}
		}
		break;
	}

	case WM_CREATE: {
		MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::ProcecEvent WM_CREATE (wParam=%X, lParam=%X)", wParam, lParam);

		HMENU hSysMenu;

		hSysMenu = GetSystemMenu(m_hWnd, FALSE);
		RemoveMenu(hSysMenu, 2, MF_BYPOSITION);
		return 0;
	}

	case WM_CLOSE: {
		MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::ProcecEvent WM_CLOSE (wParam=%X, lParam=%X)", wParam, lParam);

		if (IsIconic(m_hWnd))
			return DefWindowProc(m_hWnd, uMsg, wParam, lParam);
		if (m_ModalHold) {
			ShowWindow(m_hWnd, SW_MINIMIZE);
			return 0;
		}
	}

	case WM_DESTROY: {
		MWLOG(LEV_DEBUG, MOD_DLG, L"  --> Win32Dialog::ProcecEvent WM_DESTROY (wParam=%X, lParam=%X)", wParam, lParam);
		break;
	}

	default: {
		return DefWindowProc(m_hWnd, uMsg, wParam, lParam);
	}
	}
	return DefWindowProc(m_hWnd, uMsg, wParam, lParam);
}

void Win32Dialog::DrawApplicationIcon(HDC hdc, HWND hwnd) {
	BITMAP bitmap;
	HDC hdcMem = CreateCompatibleDC(m_hDC);
	HGDIOBJ oldBitmap = SelectObject(hdcMem, m_hAppIcon);

	RECT rect;
	GetClientRect(m_hWnd, &rect);
	int iconMarginX = 21;
	int iconMarginY = 15;
	ScaleDimensions(&iconMarginX, &iconMarginY);

	GetObject(m_hAppIcon, sizeof(bitmap), &bitmap);
	BitBlt(m_hDC, rect.right - bitmap.bmWidth - iconMarginX, iconMarginY, bitmap.bmWidth, bitmap.bmHeight, hdcMem, 0, 0,
		   SRCCOPY);

	SelectObject(hdcMem, oldBitmap);
	DeleteObject(hdcMem);
}
