dub
dub build --config=server
dub build --config=client
./progserver&
sleep 2
./progclient
killall progserver
