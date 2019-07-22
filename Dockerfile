FROM ruby:2.6-slim

MAINTAINER aaraujo@protonmail.ch

RUN apt update && \
    apt install -y vlc pulseaudio psmisc && \
    apt -y clean autoclean autoremove && \
    rm -rf /var/cache/apt/*

# User For Pulseaudio
RUN useradd --create-home --shell /bin/bash -p '*' vlc

RUN mkdir -p /firehouse_audio
WORKDIR /firehouse_audio
ADD . ./

RUN bundle install && chown -R vlc:vlc /firehouse_audio

CMD ["/firehouse_audio/start.sh"]
