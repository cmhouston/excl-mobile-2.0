:: Set working dir
cd %~dp0 & cd ..

:user_configuration

:: About AIR application packaging
:: http://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7fd9.html

:: NOTICE: all paths are relative to project root

:: Android packaging
::set AND_CERT_NAME="org.cmhouston.more"
::set AND_CERT_PASS=fd
::set AND_CERT_FILE=cert\MoreApp.p12
::set AND_ICONS=icons/android

set AND_CERT_NAME="org.cmhouston.morecmh"
set AND_CERT_PASS=1615.Binz
set AND_CERT_FILE=CMH_Android\CMH.p12
set AND_ICONS=icons/android

set AND_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%AND_CERT_FILE%" -storepass %AND_CERT_PASS%

:: iOS packaging Dev
set IOS_DIST_CERT_FILE= CMH_Apple\CMH_Dist_Certificate.p12
set IOS_DEV_CERT_FILE=CMH_Apple\CMH_Dist_Certificate.p12
::set IOS_DEV_CERT_FILE=cert\12FS_Dev_Cert.p12
set IOS_DEV_CERT_PASS=codeking316
::set IOS_PROVISION=cert\CMH_More_Dev.mobileprovision
set IOS_PROVISION=CMH_Apple\MoreCMH.mobileprovision
set IOS_ICONS=icons/ios

set IOS_DEV_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%IOS_DEV_CERT_FILE%" -storepass %IOS_DEV_CERT_PASS% -provisioning-profile %IOS_PROVISION%
set IOS_DIST_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%IOS_DIST_CERT_FILE%" -provisioning-profile %IOS_PROVISION%

:: Application descriptor
set APP_XML=application.xml

:: Files to package
set APP_DIR=bin
set FILE_OR_DIR=-C %APP_DIR% .

:: Your application ID (must match <id> of Application descriptor) and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<id>" %APP_XML%') do set APP_ID=%%a
set APP_ID=%APP_ID: =%

:: Output packages
set DIST_PATH=dist
set DIST_NAME=MoreApp

:: Debugging using a custom IP
set DEBUG_IP=

:validation
findstr /C:"<id>%APP_ID%</id>" "%APP_XML%" > NUL
if errorlevel 1 goto badid
goto end

:badid
echo.
echo ERROR: 
echo   Application ID in 'bat\SetupApp.bat' (APP_ID) 
echo   does NOT match Application descriptor '%APP_XML%' (id)
echo.

:end
