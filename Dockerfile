FROM centos:7
RUN yum install wget -y 
ADD install-nodejs.sh .
ARG NODE_VERSION='v12.13.1'
RUN ./install-nodejs.sh $NODE_VERSION

RUN adduser nonrootuser
#USER nonrootuser

ARG region
ARG key
ARG secret
COPY src /usr/src/app/src

ARG WORKING_DIR='/usr/src/app/src'
WORKDIR "$WORKING_DIR"
npm install
npm install pm2@latest
./node_modules/pm2/bin/pm2 install typescript

ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

#ENV JAVA_HOME='/usr/lib/jvm/java-1.8.0-openjdk'
#ENV PATH="${PATH}:${JAVA_HOME}/bin"
RUN chown nonrootuser:nonrootuser /usr/src/app/src
CMD ["/bin/bash"]
#CMD ["java","-jar","presence.jar"]
#CMD ["/node_modules/pm2/bin/pm2","start","ecosystem.config.js"]
./node_modules/pm2/bin/pm2 start ecosystem.config.js
