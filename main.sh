#! /bin/bash

if [ -f config ]
then
    source config
else
    echo "Create a config file with the following format:"
    echo "LOGIN=\"login\""
    echo "PASS=\"pass\""
    echo "ID=12345678"
    echo "APIKEY=\"xxxxxxxxxxxxx\""
    echo "SERVER=\"server.domain\""
    echo "PORT=123"
fi

fetch_msg() {
    (echo ". LOGIN ""$LOGIN"" ""$PASS"; sleep 1;
     echo ". SELECT INBOX"; sleep 1;
     echo ". FETCH ""$LASTMESSAGE"":* BODY.PEEK[HEADER.FIELDS (SUBJECT)]"; sleep 1;
     echo ". LOGOUT"; sleep 1;
     ) | openssl s_client -crlf -connect "$SERVER":"$PORT" 2> /dev/null
}

fetch_lastmessage() {
    (echo ". LOGIN ""$LOGIN"" ""$PASS"; sleep 1;
     echo ". SELECT INBOX"; sleep 1;
     echo ". LOGOUT"; sleep 1;
    ) | openssl s_client -crlf -connect "$SERVER":"$PORT" 2> /dev/null
}

write_nextmessage() {
   echo "NEXTMESSAGE=""$NEXTMESSAGE" > nextmessage 
}

if [ -f nextmessage ]
then
    source nextmessage
else
    echo "Next message was not set"
    LASTMESSAGE=$(fetch_lastmessage | grep EXISTS | sed 's/\* \([^ ]*\).*/\1/')
    NEXTMESSAGE=$((LASTMESSAGE+1))
    write_nextmessage
    exit 0
fi

OUT=$(fetch_msg | grep Subject)


if [ ${#OUT} -gt 0 ]; then
   while read -r line; do
       curl -G\
	    --data-urlencode "msg=New mail!""$line"\
	    "https://smsapi.free-mobile.fr/sendmsg?user=""$ID""&pass=""$APIKEY"
       NEXTMESSAGE=$((NEXTMESSAGE+1))
   done <<< "$OUT"
fi

write_nextmessage
