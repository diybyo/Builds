//console.log('abc');

var DeviceID     = "%DeviceID%";
var InstallDate  = "%InstallDate%";
var UpTime       = "%UpTime%";
var FirmwareVer  = "%FirmwareVer%";
var CompileDate  = "%CompileDate%";
var ReleaseType  = "%ReleaseType%";
var NickName     = "%NickName%";
var LCDType      = "%LCDType%";
var SSID         = "%SSID%";
var SSH_SVR      = "%SSH_SVR%";
var SSH_UN       = "%SSH_UN%";
var SSH_PW       = "%SSH_PW%";
var SSH_Port     = "%SSH_Port%";
var MTConn       = "%MTConn%";
var GmailAddr    = "%GmailAddr%";
var GmailPW      = "%GmailPW%";
var ChatID       = "%ChatID%";
var BotID        = "%BotID%";
var AutoUpdate   = "%AutoUpdate%";
var AutoSetup    = "%AutoSetup%";
var StaticIP     = "%StaticIP%";
var SubNet       = "%SubNet%";
var RateMatrix   = "%RateMatrix%";
var DevicePINS   = "%PINS%";
var DeviceCONFIG = "%CONFIG%";
var DeviceRATES  = "%RATES%";

//console.log(DeviceID);
//console.log(InstallDate);
//console.log(UpTime);

$('#Status_DeviceID').html(DeviceID);
$('#Status_InstallDate').html(InstallDate);
$('#Status_Uptime').html(secondsToDhms(UpTime));

$('#ConfigFirmware').html(FirmwareVer);
$('#ConfigFirmwareCompileDate').html(CompileDate);
$('#ConfigFirmwareType').html(ReleaseType);
//$("#ConfigSystemLcdType option[value='"+ LCDType +"']").prop('selected', true); 
$('#ConfigSystemLcdType select').val(LCDType).change();
$('#ConfigSystemNickname').val(NickName);

$('#ConfigSystemSSID').val(SSID);
$('#ConfigSystemMTIP').val(SSH_SVR);
$('#ConfigSystemMTUN').val(SSH_UN);
$('#ConfigSystemMTPW').val(SSH_PW);
$('#ConfigSystemMTSSHPort').val(SSH_Port);
//$("#ConfigSystemMTConn option[value='"+ MTConn +"']").prop('selected', true); 
$('#ConfigSystemMTConn select').val(MTConn).change();
$('#ConfigSystemGmailAddr').val(GmailAddr);
$('#ConfigSystemGmailPW').val(GmailPW);
$('#ConfigSystemTeleChatID').val(ChatID);
$('#ConfigSystemTeleBotID').val(BotID);
$('#ConfigSystemAutoUpdate select').val(AutoUpdate).change();
$('#ConfigSystemAutoSetup select').val(AutoSetup).change();
$('#ConfigSystemStaticIP').val(StaticIP);
$('#ConfigSystemSubNet').val(SubNet);

console.log(atob(RateMatrix));
console.log(atob(DevicePINS));
console.log(atob(DeviceCONFIG));
console.log(atob(DeviceRATES));