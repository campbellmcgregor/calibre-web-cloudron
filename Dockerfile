FROM cloudron/base:2.0.0@sha256:f9fea80513aa7c92fe2e7bf3978b54c8ac5222f47a9a32a7f8833edf0eb5a4f4

# ports 
EXPOSE 8083

#forked from Linuxserver.io docker file
# https://github.com/linuxserver/docker-calibre-web

RUN mkdir -p /app/pkg

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
 pip3 install setuptools && \
 pip3 install --no-cache-dir -U -r \
	requirements.txt && \
 pip3 install --no-cache-dir -U -r \
	optional-requirements.txt && \
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
    

# copy start script
COPY start.sh /app/pkg


# sorting out the supervisor configs and their log files
RUN sed -e 's,^logfile=.*$,logfile=/run/supervisord.log,' -i /etc/supervisor/supervisord.conf
COPY supervisor-calibreweb.conf /etc/supervisor/conf.d/

# copy base library
RUN mkdir -p /app/data/Library/
COPY Library/* /app/data/Library/
COPY app.db /app/code

# organise some permissions and make some stuff executable
RUN chown -R cloudron:cloudron /app/code /app/pkg /app/data
RUN chmod +x /app/pkg/start.sh

# set the container to connect into the data folder as a nice user friendly thing
WORKDIR /app/data

# kicking off the start script
CMD [ "/app/pkg/start.sh" ]
# add local files
#COPY root/ /


