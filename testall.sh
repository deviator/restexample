dub
dub build --config=server
dub build --config=client
./progserver&
./progclient
killall progserver
