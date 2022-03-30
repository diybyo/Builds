//console.log("ready");

        var Server = 'http://10.0.0.2/';   // Main vendo
        var App    = 'DIYFi';

        var AjaxEnable = false;
        var TimedOut   = false;
        var currentRequest = null;
        var InsertCoinStart = false;
        var PrevCoin = 0;

        const Mario1Up     = new Audio('assets/media/mario1up.mp3');
        const CoinDrop     = new Audio('assets/media/coindrop.mp3');
        const CoinMario    = new Audio('assets/media/coinsmario.mp3');
        const CoinInsert   = new Audio('assets/media/insertcoinbg.mp3');
        const MarioPowerUp = new Audio('assets/media/mariopowerup.mp3');

        const Busy        = new Audio('assets/media/Busy.mp3');
        const Offline     = new Audio('assets/media/Offline.mp3');
        const ThankYou    = new Audio('assets/media/Salamat.mp3');

         function uniqID(idlength) { 
            var charstoformid = '0123456789ABCDEFGHJKLMNPQRSTUVWXTZabcdefghikmnopqrstuvwxyz'.split('');
            if (! idlength) idlength = Math.floor(Math.random() * charstoformid.length);
            var uniqid = '';
            for (var i = 0; i < idlength; i++) uniqid += charstoformid[Math.floor(Math.random() * charstoformid.length)];
            return uniqid;
         }
         var TransactionID = uniqID(10);  // Will change on every window/tab load/refresh

         function setCookie(name,value,days) {
            var expires = "";
            if (days) {
               var date = new Date();
               date.setTime(date.getTime() + (days*24*60*60*1000));
               expires = "; expires=" + date.toUTCString();
            }
            document.cookie = name + "=" + (value || "")  + expires + "; path=/";
         }

         function getCookie(name) {
            var nameEQ = name + "=";
            var ca = document.cookie.split(';');
            for(var i=0;i < ca.length;i++) {
               var c = ca[i];
               while (c.charAt(0)==' ') c = c.substring(1,c.length);
               if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
            }
            return null;
         }

         function eraseCookie(name) { document.cookie = name+'=; Max-Age=-99999999;'; }

         function setStorageValue(key, value){
            if (localStorage != null) { localStorage.setItem(key, value); }
            else                      { setCookie(key,value,364); }
         }

         function removeStorageValue(key){
	    if (localStorage != null) { localStorage.removeItem(key); }
            else                      { eraseCookie(key); }
         }

         function getStorageValue(key){
	    if (localStorage != null) { return localStorage.getItem(key); }
            else                      { return getCookie(key); }
         }

         function PopulateVendoOptions() {
            $.get("nodes.txt", function(data, status){
               data = data.slice(0, -1); // remove last char
               data = '['+data+']'; // fix json string
               console.log(data);
               var tableValues = $.parseJSON(data); // raw data
               if (!$.isEmptyObject(tableValues)) {
                  map = {}; for (let list of tableValues) { map[Object.values(list).join('')] = list; }
                  $.each(map, function() {
                     //console.log(this.HostName, " ", this.IP, " ", this.NickName);
                     var IP = this.IP;
                     var HN = this.HostName;
                     var NN = this.NickName;
                     $('#VendoSelection').append($('<option>', { value: this.IP, text : this.HostName }));
                  });
               }
               $('#VendoSelection option:first').prop('selected', true);

               var VendoSelected = $('#VendoSelection').find(":selected").val(); // .text();
               //console.log(VendoSelected);
               Server = "http://"+VendoSelected+"/";
               //console.log(Server);
            });
         }

         function CheckInternet() {
            $.get("status.txt", function(data, status){
               console.log(data);
               if (data=="ONLINE") { 
                  $('#OfflineDiv').hide(); 
                  $('#InputDiv').show(); 
               }
               else { 
                  $('#InputDiv').hide(); 
                  $('#OfflineDiv').show(); 
               }
            });
         }


         function ShowHelp() {
            var Req = $.ajax({ url: "help.txt", type: 'get',
               success: function(data) {
                  $('#HelpModalBody').html(data); 
               },
               error:function(e){
                  if (Req !== null) Req.abort();
                  $('#HelpModalBody').html("<h1>Cant get help file...</h1>"); 
               },
               timeout: 5000, // sets timeout to 5 seconds
            });
         }

         function GetNews() {
            var Req = $.ajax({ url: "news.txt", type: 'get',
               success: function(data) {
                  if (data.trim() != "") { $('.news-content').html(data);  }
                  else                   { $('.ticker').hide(); }
               },
               error:function(e){
                  if (Req !== null) Req.abort();
                  $('.ticker').hide();
               }
            });
         }

function initVoucherHandler() {
      var timer = setInterval(function() {
        if (AjaxEnable && (!TimedOut)) {
            var RateTypeSelected = $('#RateType').find(":selected").val(); // console.log(RateTypeSelected);
            if (currentRequest) currentRequest.abort();
         currentRequest = jQuery.ajax({
            url: Server+App,
            type: 'post',
            data: {'message':'start', 'IP':MyIP, 'MAC':MyMAC, 'RateType':RateTypeSelected },
            success: function(data) {
               console.log(data);
               $('#InsertCoinMessage').html(data);

               var Client = JSON.parse(data);
               if (Client.Status=="OK") {
                  var TimeLeft = Client.TimeRemaining;
                  var Coins    = Client.CoinInserted; 
                  var Credited = Client.CoinsCredited; 
                  var Pending  = Client.CoinsPending; 
                  var Voucher  = Client.VoucherCode;
                  var Value    = Client.EquivTimeVal;   // in minutes
                  var MTEquiv  = Client.EquivTimeStr;
                  var TS       = Client.SystemTime; 
                  var TimerMax = Client.CSCountDwnMax;
                  var HostName = Client.HostName;
                  var NickName = Client.NickName;

                  var Percent  = ((TimeLeft/TimerMax)*100);
                  $('#ProgressBar').css("width", Percent+"%");

                  $('#NodeInfo').html(": <b>" + NickName + "</b>");
                  $('#IC_HostName').html(HostName);

                  if (InsertCoinStart) {
                     $('.progress').show();
                     //CoinInsert.play();
                     InsertCoinStart = false;
                     PrevCoin = Coins;
                  }

                  if (Coins > PrevCoin) {
                     PrevCoin = Coins;
                     CoinDrop.pause(); CoinDrop.currentTime = 0; CoinDrop.play();
                  }
                  else { PrevCoin = Coins+1; }

                  if (Coins <=0) {
                     $('#InsertCoinMessage').html("<h1>Please Insert Coin...</h1>"); 
                  }
                  else {
                     var DISPLAY = "<h1>" +
                                   Voucher + "<br>" +
                                   "PhP " + Coins + " (" + Credited + "+" +Pending+ ")<br>" +
                                   MTEquiv + "<br>" +
                                   "</h1>";
                     $('#InsertCoinMessage').html(DISPLAY); 
                  }

                  if (Voucher != "") {
                     // SAVE TO LocalStorage/Cookies
                     var recentVoucher  = getStorageValue('lastvoucher');
                     if (recentVoucher != Voucher) {
                        //console.log("SAVED VOUCHER");
                        setStorageValue('lastvoucher', Voucher);
                        var allV = getStorageValue('allvouchers');
                        if (allV!='' && allV!=null) { var allVouchers = JSON.parse(allV); }
                        else                        { var allVouchers = []; }
                        allVouchers.push(Voucher);
                        //console.log("ALL VOUCHERS: ", allVouchers);
                        setStorageValue('allvouchers', JSON.stringify(allVouchers));
                     }

                     // Input in the ActivateForm
                     if (Voucher!="") $('#VoucherCode').val(Voucher);

                     // fill-up MT hidden fields
                     $('#VoucherCode').val(Voucher);
                     $('#username').val(Voucher);
                     $('#password').val(Voucher);

                  }
 
                  if (TimeLeft<=1) {
                     TimedOut=true;
                     AjaxEnable = false;
                     //$('#ProgressBar').css("width", "0%");
                     $('.progress').hide();
                     if (Coins<=0) {
                        var DISPLAY = "<h1>Thank You!</h1>";
                        $('#InsertCoinMessage').html(DISPLAY);
                     }
                     else {
                        CoinInsert.pause(); CoinInsert.currentTime = 0;
                        ThankYou.play();
                     }
                  }
               }
               else if (Client.Status=="ClientQUIT") { }
               else if (Client.Status=="WAIT") {
                  $('#InsertCoinMessage').html("Please wait..."); 
               }
               else if (Client.Status=="BUSY") {
                  TimedOut=true;
                  Busy.pause(); Busy.currentTime = 0; Busy.play();
                  $('#InsertCoinMessage').html("NODE is BUSY with another client..."); 
               }
               else if (Client.Status=="OFFLINE") {
                  TimedOut=true;
                  CoinInsert.pause(); CoinInsert.currentTime = 0;
                  Offline.pause(); Offline.currentTime = 0; Offline.play();
                  $('#InsertCoinMessage').html("NODE IS OFFLINE"); 
               }
               else {
                  TimedOut=true;
                  $('#InsertCoinMessage').html(Client.Status + "<br>" + Client.Message);
               }
            },
            error:function(e){
               if (typeof(Coins) == "undefined") {
                  //TimedOut=true;
                  Offline.play();
               }
               if (currentRequest !== null) currentRequest.abort();
               //console.log("NODE is NOT answering");
               if (TimeLeft<=1) $('#InsertCoinMessage').html("NODE is NOT responding..."); 
            },
            timeout: 1000, // sets timeout to 5 seconds
         });
       }
       if (TimedOut) {
          currentRequest.abort();
       }
      }, 1000); 
}

         function RecallVoucher() {
            var MyRecentVoucher  = getStorageValue('lastvoucher');
            if (MyRecentVoucher != "undefined" && MyRecentVoucher != "") {
               //console.log(MyRecentVoucher);
               $('#VoucherCode').val(MyRecentVoucher);
               document.sendin.username.value = MyRecentVoucher;
               document.sendin.password.value = MyRecentVoucher;
            }
            else {
               $('#VoucherCode').val("");
               document.sendin.username.value = "";
               document.sendin.password.value = "";
            }
         }

         function ShowVouchers() {
            var MESSAGE = "";
            var MyRecentVoucher  = getStorageValue('lastvoucher');
            var AllVouchers      = getStorageValue('allvouchers');
            if (AllVouchers != "") {
               var allV1 = JSON.parse(AllVouchers); // build array
               allV1.reverse();  // reverse the order - most recent first
               //allV1.shift();    // remove the last item from the list
               //console.log("ALL VOUCHERS: ", allV1);

               var Title='click this to use the code';
               var vPool="";   
               var Counter = 0;
               var MaxDisplay = 7;
               $.each(allV1, function(i, val) {
                  if (Counter++ < MaxDisplay) {
                     if (val == MyRecentVoucher) {
                        vPool += "<span class='delvoucher' rel='"+val+"'><b>XXXXX</b></span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='usevoucher' rel='"+val+"' title='"+Title+"'><b>" + val + "</b></span> <br />"; 
                     }
                     else {
                        vPool += "<span class='delvoucher' rel='"+val+"'><b>XXXXX</b></span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class='usevoucher' rel='"+val+"' title='"+Title+"'>" + val + "</span> <br />"; 
                     }
                  }
               });
               if (Counter > MaxDisplay) vPool += "(" + Counter + ") +++";
               MESSAGE += vPool;
            }
            //console.log(MESSAGE);
            $('#SavedVoucherModalBody').html(MESSAGE);
         }

         $(document).on('click', '.usevoucher', function() {
            var Voucher = $(this).attr('rel');
            //console.log("USE ", Voucher);
            localStorage.setItem('lastvoucher', Voucher);

            $('#VoucherCode').val(Voucher);
            document.sendin.username.value = Voucher;
            document.sendin.password.value = Voucher;

            ShowVouchers();
         });

         $(document).on('click', '.delvoucher', function() {
            var Voucher = $(this).attr('rel');
            if (confirm('are you sure you want to delete: '+Voucher)) {
               //console.log("DEL ", Voucher);
               var MyRecentVoucher = localStorage.getItem('lastvoucher');
               var MyVouchers      = localStorage.getItem('allvouchers');
               if (MyVouchers != "") {
                  var allV = JSON.parse(MyVouchers); // build array
                  //var allV2 = allV.reverse();  // reverse the order - most recent first
                  var allVouchers = allV.filter(function(elem){ return elem != Voucher;  });
                  if (MyRecentVoucher == Voucher) { // are we removing the most recent one?
                     var NewSelectedVoucher = allVouchers[0];
                     localStorage.setItem('lastvoucher', NewSelectedVoucher); // make the first entry the latest

                     $('#VoucherCode').val(NewSelectedVoucher);
                     document.sendin.username.value = NewSelectedVoucher;
                     document.sendin.password.value = NewSelectedVoucher;
                  }
                  localStorage.setItem('allvouchers', JSON.stringify(allVouchers));
               }
               ShowVouchers();
            }
         });

         $(document).ready(function() {
            //CheckInternet();

            $('#overlay').fadeOut();
            //$('#toast-1').toast('show');

            GetNews();
            PopulateVendoOptions();
            RecallVoucher();
            initVoucherHandler();

/*
            $('#VendoSelection').click();
            var VendoSelected = $('#VendoSelection').find(":selected").val(); // .text();
            console.log(VendoSelected);
            Server = "http://"+VendoSelected+"/";
            console.log(Server);

/*
$('#VendoSelection option:first').prop('selected', true);
$("#VendoSelection").prop("selectedIndex", 0);
$("#target option")
    .removeAttr('selected')
    .find(':first')     // You can also use .find('[value=MyVal]')
        .attr('selected','selected');
/**/

            if ($('#VoucherCode').val() != "") $('#ActivateButton').focus();
            //var timer = setInterval(function() { CheckInternet(); }, 1000); 
         });

         $(document).on('click','#InsertCoin',function(e){
           InsertCoinStart = true;
           AjaxEnable = true;
           TimedOut=false;
           //$('#ProgressBar').val("aria-valuenow", "50");
           //$('#ProgressBar').val("aria-valuemax", "100");
           $('#NodeInfo').html("");
           $('.progress').hide();
           $('#InsertCoinMessage').html("Activating vendo, please wait...");
           $('#ServerInfo').text(Server);
         });

         $(document).on('click','#RatesButton',function(e){
            $('#RatesModalBody').html("Requesting from vendo, please wait...");
            var Req = $.ajax({
               url: Server+"getRates.php",
               type: 'post',
               success: function(data) {
                  $('#RatesModalBody').html(data); 
               },
               error:function(e){
                  if (Req !== null) Req.abort();
                  Offline.pause(); Offline.currentTime = 0; Offline.play();
                  $('#RatesModalBody').html("NODE is NOT responding..."); 
               },
               timeout: 5000, // sets timeout to 5 seconds
            });
         });

         $(document).on('click','#VouchersButton',function(e){
            ShowVouchers();
         });

         $(document).on('click','#HelpButton',function(e){
            ShowHelp();
         });

         $(document).on('click','#ActivateButton',function(e){
            //console.log('ActivateButton was clicked');
            doLogin();
         });

         /*$(document).on('click', '#VendoSelection', function() {
            var VendoSelected = $('#VendoSelection').find(":selected").val(); // .text();
            console.log(VendoSelected);
         }); /**/

         $(document).on('change', '#VendoSelection', function() {
            var VendoSelected = $('#VendoSelection').find(":selected").val(); // .text();
            //console.log(VendoSelected);
            Server = "http://"+VendoSelected+"/";
            //console.log(Server);
         });

         $('#modal-1').on('hidden.bs.modal', function () {
            //console.log("Get-Voucher Modal was closed ");
            CoinInsert.pause(); CoinInsert.currentTime = 0;
            Offline.pause(); Offline.currentTime = 0; 
            Busy.pause(); Busy.currentTime = 0;
            ThankYou.pause(); ThankYou.currentTime = 0;
            InsertCoinStart = false;
            AjaxEnable = false;
            TimedOut=false;
            if (currentRequest !== null) currentRequest.abort();
            $.ajax ({type: "POST", url: Server+App, data: {'message':'finish'}, success: function(data){ } });
         });

         $('#modal-3').on('hidden.bs.modal', function () {
            //console.log("Get-Rates Modal was closed ");
            Offline.pause(); Offline.currentTime = 0; 
         });




         const html5QrCode = new Html5Qrcode("reader");
	 const fileinput = document.getElementById('qr-input-file');
	 fileinput.addEventListener('change', e => {
	   if (e.target.files.length == 0) { return; }
           const imageFile = e.target.files[0];
           html5QrCode.scanFile(imageFile, true)
	      .then(decodedText => {
                 //alert(decodedText);
                 //console.log(decodedText);
                 $("#VoucherCode").val(decodedText);
                 $("#modal-5").modal('hide');
                 fileinput.value = '';
                 html5QrCode.clear();
              })
              .catch(err => {
                 alert('Scanned failed, please try again');
                 fileinput.value = '';
                 html5QrCode.clear();
              });
         });

         $(document).on('click','#ScanQR',function(e){

         });

