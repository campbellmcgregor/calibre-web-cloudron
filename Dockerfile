FROM cloudron/base:2.0.0@sha256:f9fea80513aa7c92fe2e7bf3978b54c8ac5222f47a9a32a7f8833edf0eb5a4f4

# ports 
EXPOSE 8083

# declare location for the app.db
ENV CALIBRE_DBPATH=/app/data

#forked from Linuxserver.io docker file
# https://github.com/linuxserver/docker-calibre-web

#make pkg dir for startup scripts etc.
RUN mkdir -p /app/pkg

# main installer command
RUN \
 apt update && \
 apt install -y \
	libldap2-dev \
 	imagemagick \
	libnss3 \
	libxcomposite1 \
	libxslt1.1 \
	libldap-2.4-2 \
	libsasl2-2 \
    python3-dev \
	unrar && \
 if [ -z ${CALIBREWEB_RELEASE+x} ]; then \
	CALIBREWEB_RELEASE=$(curl -sX GET "https://api.github.com/repos/janeczku/calibre-web/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/calibre-web.tar.gz -L \
	https://github.com/janeczku/calibre-web/archive/${CALIBREWEB_RELEASE}.tar.gz && \
 mkdir -p \
	/app/code && \
 tar xf \
 /tmp/calibre-web.tar.gz -C \
	/app/code --strip-components=1 && \
 cd /app/code && \
 pip3 install setuptools wheel && \
 pip3 install --no-cache-dir -U -r \
	requirements.txt && \
 pip3 install --no-cache-dir -U -r \
	optional-requirements.txt && \
pip3 install gevent && \
 echo "***install kepubify" && \
 if [ -z ${KEPUBIFY_RELEASE+x} ]; then \
    KEPUBIFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/geek1011/kepubify/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /usr/bin/kepubify -L \
	https://github.com/geek1011/kepubify/releases/download/${KEPUBIFY_RELEASE}/kepubify-linux-64bit && \
 echo "**** cleanup ****" && \
 apt purge -y \
	libldap2-dev \
	libsasl2-dev &&\
 rm -fr \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*
    

# installing calibre to allow converstions
RUN   wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | \
      python -c \
      "import sys; \
       main=lambda:sys.stderr.write('Download failed\n'); \
       exec(sys.stdin.read()); \
       main(install_dir='/opt', isolated=True, version='4.13.0')" 

# copy start script
COPY start.sh /app/pkg


# sorting out the supervisor configs and their log files
RUN sed -e 's,^logfile=.*$,logfile=/run/supervisord.log,' -i /etc/supervisor/supervisord.conf
COPY supervisor-calibreweb.conf /etc/supervisor/conf.d/

# copy base library
RUN mkdir -p /app/data/Library/
COPY Library/* /app/data/Library/
COPY app.db /app/data

# organise some permissions and make some stuff executable
RUN echo "Setting permissions this make take some time"
RUN chown -R cloudron:cloudron /app/code /app/pkg /app/data
RUN chmod +x /app/pkg/start.sh

# set the container to connect into the data folder as a nice user friendly thing
WORKDIR /app/data

# todo 
# tidy up files from install

# kicking off the start script
CMD [ "/app/pkg/start.sh" ]



