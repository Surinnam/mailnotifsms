#! /bin/bash

if [ -f lastmessage ]
then
    source lastmessage
else
    echo "Last message unset"
    exit 0
fi

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


OUT=$(fetch_msg | grep Subject)


while read -r line; do
    curl -G\
	--data-urlencode "msg=New mail!""$line"\
	"https://smsapi.free-mobile.fr/sendmsg?user=""$ID""&pass=""$APIKEY"
    LASTMESSAGE=$((LASTMESSAGE+1))
done <<< "$OUT"

echo "LASTMESSAGE=""$LASTMESSAGE" > lastmessage
