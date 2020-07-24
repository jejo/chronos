FROM java:8-jre
ARG http_proxy
ENV http_proxy ${http_proxy}

CMD ["/bin/bash"]
RUN /bin/sh -c apt-get update && apt-get install -y --no-install-recommends 		ca-certificates 		curl 		wget 	&& rm -rf /var/lib/apt/lists/*
RUN /bin/sh -c apt-get update && apt-get install -y --no-install-recommends 		bzip2 		unzip 		xz-utils 	&& rm -rf /var/lib/apt/lists/*
RUN /bin/sh -c echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

ENV LANG=C.UTF-8

RUN /bin/sh -c { 		echo '#!/bin/sh'; 		echo 'set -e'; 		echo; 		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; 	} > /usr/local/bin/docker-java-home 	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV JAVA_VERSION=8u111
ENV JAVA_DEBIAN_VERSION=8u111-b14-2~bpo8+1
ENV CA_CERTIFICATES_JAVA_VERSION=20140324

RUN /bin/sh -c set -x 	&& apt-get update 	&& apt-get install -y 		openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" 		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" 	&& rm -rf /var/lib/apt/lists/* 	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]
RUN /bin/sh -c /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN /bin/sh -c apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF     && echo "deb http://repos.mesosphere.com/debian jessie-unstable main" | tee /etc/apt/sources.list.d/mesosphere.list     && echo "deb http://repos.mesosphere.com/debian jessie-testing main" | tee -a /etc/apt/sources.list.d/mesosphere.list     && echo "deb http://repos.mesosphere.com/debian jessie main" | tee -a /etc/apt/sources.list.d/mesosphere.list     && apt-get update     && apt-get install --no-install-recommends -y --force-yes mesos=1.0.1-2.0.93.debian81     && apt-get clean     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./tmp/chronos.jar  /chronos/chronos.jar 
ADD ./bin/start.sh  /chronos/bin/start.sh 

ENTRYPOINT ["/chronos/bin/start.sh"]

