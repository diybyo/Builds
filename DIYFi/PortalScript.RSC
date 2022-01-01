
/ip hotspot user profile set [find name="ClientWiFi"] on-login=":local un\
    ame \$user;\r\
    \n:local usercount 0;\r\
    \n:local usertime \"00:00:00\";\r\
    \n:local kickable;\r\
    \n:local maxuser 2;\r\
    \n\r\
    \n   :foreach i in=[/ip hotspot active find user=\$uname] do= {\r\
    \n      :local curup [/ip hotspot active get \$i uptime];\r\
    \n      :if ( \$curup >= \$usertime ) do={\r\
    \n         :set usertime \$curup;\r\
    \n         :set kickable \$i;\r\
    \n      }\r\
    \n      :set usercount (\$usercount+1);\r\
    \n   }\r\
    \n\r\
    \n   :log info \"\$uname = \$usercount\";\r\
    \n\r\
    \n   :if (\$usercount >= \$maxuser) do={\r\
    \n      :log info \"Login user: \$uname (\$usercount/\$maxuser) - Oldest \
    \$usertime will be logout!\";\r\
    \n      /ip hotspot active remove numbers=\$kickable;\r\
    \n   } ;\r\
    \n\r\
    \n\r\
    \n\r\
    \n" on-logout="\r\
    \n:log info \"Delete used account script executed\";\r\
    \n:foreach i in [/ip hotspot user find profile=\"ClientWiFi\"] do={\r\
    \n   :if ([/ip hotspot user get \$i uptime]>=[/ip hotspot user get \$i lim\
    it-uptime]) do={\r\
    \n      /ip hotspot user remove \$i;\r\
    \n   }\r\
    \n}\r\
    \n";
/
/
/









