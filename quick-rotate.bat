@echo off
REM Quick IP Rotation for OpenCode (Windows)

REM Free SOCKS5 proxies
set PROXIES[0]=socks5://184.178.172.28:15294
set PROXIES[1]=socks5://192.111.139.165:19402
set PROXIES[2]=socks5://184.178.172.18:15284
set PROXIES[3]=socks5://72.210.252.134:4145
set PROXIES[4]=socks5://184.178.172.22:15288

REM Pick random proxy
set /a index=%RANDOM% %% 5
set SELECTED_PROXY=%PROXIES[%index%]%

echo Using proxy: %SELECTED_PROXY%
echo Starting OpenCode with rotated IP...
echo.

REM Set proxy environment
set https_proxy=%SELECTED_PROXY%
set http_proxy=%SELECTED_PROXY%
set all_proxy=%SELECTED_PROXY%

REM Run opencode
opencode %*
