when not defined(c):
    {.error: "Must be compiled in c mode"}

{.emit: """
// Author: Mr.Un1k0d3r RingZer0 Team
// slightly modified to use with Nim


#include <Windows.h>
#include <ntstatus.h>
// #include <stdlib.h>

#define SE_DEBUG_NAME 0x14

// function definitions
typedef NTSTATUS(NTAPI *pdef_RtlAdjustPrivilege) (
	ULONG privilege,
	BOOLEAN enable,
	BOOLEAN current_thread,
	PBOOLEAN enabled);
typedef NTSTATUS(NTAPI *pdef_NtRaiseHardError)(
	NTSTATUS error_status,
	ULONG number_of_parameters,
	ULONG unicode_string_parameter_mask,
	PULONG_PTR parameters,
	ULONG response_option,
	PULONG reponse);

void enableSedebug()
{
	pdef_RtlAdjustPrivilege RtlAdjustPrivilege = (pdef_RtlAdjustPrivilege)GetProcAddress(LoadLibraryA("ntdll.dll"), "RtlAdjustPrivilege");
	BOOLEAN enabled;
	RtlAdjustPrivilege(SE_DEBUG_NAME, TRUE, FALSE, &enabled);
  // system("whoami /priv | findstr SeDebugPrivilege");
}
""".}
proc enableSedebug(): void
    {.importc: "enableSedebug", nodecl.}
when isMainModule:
  enableSedebug()
