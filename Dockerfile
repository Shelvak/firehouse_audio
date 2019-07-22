FROM ruby:2.6-stretch

RUN apt update && \
    apt install -y vlc pulseaudio psmisc && \
    apt -y clean autoclean autoremove && \
    rm -rf /var/cache/apt/*

# User For Pulseaudio
RUN useradd --create-home --shell /bin/bash -p '*' vlc

RUN mkdir -p /firehouse_audio
WORKDIR /firehouse_audio
ADD . ./

RUN chmod 777 /firehouse_audio/start.sh

RUN gem install bundler:2.0.1

RUN bundle install && chown -R vlc:vlc /firehouse_audio

CMD ["/firehouse_audio/start.sh"]
