#!/bin/bash
MY_ANDROID_DIR=$(pwd)
MY_BUILD_BOARD="h739_wifibt_hd"
IS_CLEAN_ANDROID=


function exports_env()
{
    source build/envsetup.sh
    lunch astar-wifibt-user
}

function gms_clean()
{
	rm -rf out/dist/
	make installclean
}

function gms_build_firm()
{

    make -j12
    pack $MY_BUILD_BOARD
}

function gms_signed()
{
    get_uboot $MY_BUILD_BOARD
    make -j8 dist
    #./build/tools/releasetools/sign_target_files_apks -d device/softwinner/V_TAB_7_LITE_II/security out/dist/V_TAB_7_LITE_II-target_files-$(date +%Y%m%d).zip out/dist/signed-target-files.zip
	#./build/tools/releasetools/sign_target_files_apks -d device/softwinner/polaris-wifionly/security -e FaceLock.apk,Gmail2.apk,Videos.apk,GoogleTTS.apk,PlusOne.apk,Chrome.apk,ServiceFramework.apk,BrowserProviderProxy.apk,GoogleEars.apk,Music2.apk,Books.apk,CalendarGoogle.apk,GameCenter.apk,GameCenter.apk,SoftwinnerBaseService.apk,Maps.apk,MediaUploader.apk,GoogleContactsSyncAdapter.apk,PlayGames.apk,LatinImeGoogle.apk,GooglePartnerSetup.apk,Velvet.apk,GoogleFeedback.apk,GoogleCalendarProvider.apk,SetupWizard.apk,Phonesky.apk,GoogleLoginService.apk,GoogleOneTimeInitializer.apk,talkback.apk,GoogleServicesFramework.apk,PrebuiltGmsCore.apk,SoftWinnerService.apk,SoftWinnerService.apk,DragonFire.apk,DragonPhone.apk,VideoTest.apk=device/softwinner/polaris-wifionly/security/platform  -e GoogleBackupTransport.apk=device/softwinner/polaris-wifionly/security/platform out/dist/polaris_wifionly-target_files-$(date +%Y%m%d).zip out/dist/signed-target-files.zip

expect -c"
    set timeout 1200; 
  
    spawn ./build/tools/releasetools/sign_target_files_apks -d device/softwinner/astar-wifibt/security -e SoftWinnerService.apk,SoftWinnerService.apk,DragonPhone.apk,DragonFire.apk,VideoTest.apk=device/softwinner/astar-wifibt/security/releasekey  out/dist/astar_wifibt-target_files-$(date +%Y%m%d).zip out/dist/signed-target-files.zip

    expect {
                \"*password*\" {send \"brn\r\"; exp_continue}
                \"*password*\" {send \"brn\r\"; exp_continue}
                \"*password*\" {send \"brn\r\"; exp_continue}
                \"*password*\" {send \"brn\r\"; }
    };"

    ./build/tools/releasetools/img_from_target_files out/dist/signed-target-files.zip out/dist/signed-img.zip
    rm -rf out/dist/signed-img/
    mkdir -p out/dist/signed-img
    unzip out/dist/signed-img.zip -d out/dist/signed-img
    cp out/dist/signed-img/*.img $OUT/
    pack -s $MY_BUILD_BOARD
}

function gms_ota()
{
	./build/tools/releasetools/ota_from_target_files out/dist/signed-target-files.zip out/dist/signed-ota.zip
}

while getopts b:c OPTION
do
     case $OPTION in
        c) IS_CLEAN_ANDROID=1
        ;;
        b) MY_BUILD_BOARD=$OPTARG
        ;;
        m) MY_PASSWORD=$OPTARG
        ;;
     esac
done

exports_env
gms_clean
gms_build_firm
gms_signed
gms_ota


