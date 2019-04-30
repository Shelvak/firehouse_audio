#!/bin/bash

chown -R vlc:vlc /logs

echo "#### Initializing Pulseaudio"
pulseaudio -D --system

echo "#### Initializing Ruby App"
runuser -l vlc -s /bin/bash -c "cd /firehouse_audio; REDIS_HOST=$REDIS_HOST \
                                BROADCAST_IP=$BROADCAST_IP \
                                GEM_HOME=$GEM_HOME \
                                PATH=$GEM_HOME/ruby/2.2.0/bin:$PATH \
                                firehouse_path=$firehouse_path \
                                logs_path=$logs_path \
                                bundle exec rake"

