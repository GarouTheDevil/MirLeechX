FROM iamliquidx/mirleechxsdk:a8ce33bccdde0806fbd0541d5faf33e63a572582
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

RUN apt-get -y update && apt-get -qq install -y --no-install-recommends curl git gnupg2 unzip wget pv jq mediainfo

#FFmpeg	
RUN aria2c -x 10 https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \	
    tar xvf ffmpeg*.xz && \	
    cd ffmpeg-*-static && \	
    mv "${PWD}/ffmpeg" "${PWD}/ffprobe" /usr/local/bin/

#mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# Install dovi_tool
RUN wget -P /tmp https://github.com/quietvoid/dovi_tool/releases/download/1.5.6/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz
RUN rm /tmp/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY extract /usr/local/bin
COPY pextract /usr/local/bin
RUN chmod +x /usr/local/bin/extract && chmod +x /usr/local/bin/pextract
COPY . .
COPY .netrc /root/.netrc
RUN chmod 600 /usr/src/app/.netrc
RUN apt-get install -y wget 
RUN wget -q https://github.com/P3TERX/aria2.conf/raw/master/dht.dat -O /usr/src/app/dht.dat && \
    wget -q https://github.com/P3TERX/aria2.conf/raw/master/dht6.dat -O /usr/src/app/dht6.dat
RUN rm -rf ffmpeg*.xz ffmpeg-*-static
RUN apt-get update && apt-get upgrade -y
RUN apt -qq update --fix-missing

CMD ["bash","start.sh"]
