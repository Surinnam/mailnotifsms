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
     echo ". FETCH 2033 BODY.PEEK[HEADER.FIELDS (SUBJECT)]"; sleep 1;
     ) | openssl s_client -crlf -connect "$SERVER":"$PORT" 2> /dev/null
}


OUT=$(fetch_msg | grep Subject)

curl -G\
    --data-urlencode "msg=New mail!""$OUT"\
    "https://smsapi.free-mobile.fr/sendmsg?user=""$ID""&pass=""$APIKEY"

