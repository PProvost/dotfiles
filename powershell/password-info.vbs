On Error Resume Next

Const ADS_UF_DONT_EXPIRE_PASSWD = &h10000
Const E_ADS_PROPERTY_NOT_FOUND  = &h8000500D
Const ONE_HUNDRED_NANOSECOND    = .000000100
Const SECONDS_IN_DAY            = 86400

Set objADSystemInfo = CreateObject("ADSystemInfo")              ' LINE 8
Set objUser = GetObject("LDAP://" & objADSystemInfo.UserName)   ' LINE 9

intUserAccountControl = objUser.Get("userAccountControl")
If intUserAccountControl And ADS_UF_DONT_EXPIRE_PASSWD Then
    WScript.Echo "The password does not expire."
    WScript.Quit
Else
    dtmValue = objUser.PasswordLastChanged
    If Err.Number = E_ADS_PROPERTY_NOT_FOUND Then
        WScript.Echo "The password has never been set."
        WScript.Quit
    Else
        intTimeInterval = Int(Now - dtmValue)
        WScript.Echo "The password was last set on " & _
          DateValue(dtmValue) & " at " & TimeValue(dtmValue)  & vbCrLf & _
          "The difference between when the password was last" & vbCrLf & _
          "set and today is " & intTimeInterval & " days"
    End If

    Set objDomain = GetObject("LDAP://" & objADSystemInfo.DomainDNSName)
    Set objMaxPwdAge = objDomain.Get("maxPwdAge")

    If objMaxPwdAge.LowPart = 0 Then
        WScript.Echo "The Maximum Password Age is set to 0 in the " & _
                     "domain. Therefore, the password does not expire."
        WScript.Quit
    Else
        dblMaxPwdNano = _
            Abs(objMaxPwdAge.HighPart * 2^32 + objMaxPwdAge.LowPart)
        dblMaxPwdSecs = dblMaxPwdNano * ONE_HUNDRED_NANOSECOND
        dblMaxPwdDays = Int(dblMaxPwdSecs / SECONDS_IN_DAY)
        WScript.Echo "Maximum password age is " & dblMaxPwdDays & " days"

        If intTimeInterval >= dblMaxPwdDays Then
            WScript.Echo "The password has expired."
        Else
            WScript.Echo "The password will expire on " & _
              DateValue(dtmValue + dblMaxPwdDays) & " (" & _
              Int((dtmValue + dblMaxPwdDays) - Now) & " days from today)."
        End If
    End If
End If

