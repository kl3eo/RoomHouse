#!/bin/bash

export GST_DEBUG="$GST_DEBUG,Kurento*:5,KurentoWebSocket*:4"
export GST_DEBUG="$GST_DEBUG,kmssdpsession:5"
export GST_DEBUG="$GST_DEBUG,sdp*:5"
export GST_DEBUG="$GST_DEBUG,webrtcendpoint:5,kmswebrtcsession:5,kmsiceniceagent:5"
export GST_DEBUG="$GST_DEBUG,basemediamuxer:5,KurentoRecorderEndpointImpl:4,recorderendpoint:5,qtmux:5,curl*:5"
export G_MESSAGES_DEBUG="libnice,libnice-stun"
export GST_DEBUG="$GST_DEBUG,glib:5"

#/home/nobody/newlib/lib64/ld-linux-x86-64.so.2 --library-path /home/nobody/newlib/lib/:/home/nobody/newlib/libs/ /home/nobody/newlib/bin/kurento-media-server

GST_PLUGIN_SCANNER=/usr/lib/x86_64-linux-gnu/gstreamer1.5/gstreamer-1.5/gst-plugin-scanner LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/nobody/newlib/lib/ /home/nobody/newlib/lib64/ld-linux-x86-64.so.2 /home/nobody/newlib/bin/kurento-media-server > log 2>&1 &

#sleep 1
curl --include --header "Connection: Upgrade" --header "Upgrade: websocket" --header "Host: 127.0.0.1:8433" --header "Origin: 127.0.0.1" --insecure https://127.0.0.1:8433/kurento

