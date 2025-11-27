@echo off

call ./update-config.bat
LaunchUtils/busybox-sh.bat ./LaunchUtils/ScriptCaller.sh %*
