@echo off
copy /u nul %4
start /wait /d "C:\program files\perforce" p4merge.exe %1 %2 %3 %4
