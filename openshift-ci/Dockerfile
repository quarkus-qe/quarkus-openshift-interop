FROM registry.access.redhat.com/ubi8/ubi

ENV LANGUAGE='en_US:en'
ENV DIR=/tmp
WORKDIR $DIR

RUN dnf install -y git glibc-devel zlib-devel gcc freetype-devel libstdc++-static --setopt=install_weak_deps=False
# ubi8 repos contain maven 3.5 and jdk 1.8; we need something newer
# Install mandrel: https://github.com/graalvm/mandrel/releases
ARG MANDREL_VERSION='23.1.7.0'
ADD https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}-Final/mandrel-java21-linux-amd64-${MANDREL_VERSION}-Final.tar.gz mandrel-java21-linux-amd64-${MANDREL_VERSION}-Final.tar.gz
ADD https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}-Final/mandrel-java21-linux-amd64-${MANDREL_VERSION}-Final.tar.gz.sha256 mandrel.sha256
RUN sha256sum -c mandrel.sha256 && tar -xaf mandrel-java21-linux-amd64-${MANDREL_VERSION}-Final.tar.gz
# Install maven: https://maven.apache.org/install.html + https://maven.apache.org/download.cgi
ARG MAVEN_VERSION='3.9.10'
ADD https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz maven.tar.gz
RUN curl https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 > maven.sha512 && printf "\tmaven.tar.gz" >> maven.sha512 && sha512sum -c maven.sha512
RUN tar -xaf maven.tar.gz

# install oc client
ADD https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux-amd64-rhel8.tar.gz oc.tar.gz
RUN tar -xaf oc.tar.gz oc && mv oc /usr/local/bin/

ENV JAVA_HOME="${DIR}/mandrel-java21-${MANDREL_VERSION}-Final"
ENV GRAALVM_HOME="${JAVA_HOME}"
ENV PATH="${JAVA_HOME}/bin:$DIR/apache-maven-${MAVEN_VERSION}/bin:${PATH}"

# these versions should be updated for every release
ENV QUARKUS_BRANCH=3.20
ENV QUARKUS_VERSION=3.20.3.redhat-00006
ENV QUARKUS_PLATFORM_GROUP_ID=com.redhat.quarkus.platform
ENV QUARKUS_PLATFORM_ARTIFACT_ID=quarkus-bom

## List of projects to include in smoke test
ENV PROJECTS=config,lifecycle-application,http/http-minimum,http/http-minimum-reactive,sql-db/sql-app,monitoring/micrometer-prometheus

RUN git clone --depth=1 -b ${QUARKUS_BRANCH} https://github.com/quarkus-qe/quarkus-test-suite.git tests
WORKDIR /tmp/tests
RUN chmod -R 777 /tmp/tests

RUN mkdir --mode=777 /tmp/home
ENV HOME=/tmp/home

# maven settings for repository
ADD settings.xml /tmp/home/.m2/settings.xml

ADD --chmod=755 run.sh /tmp/tests/
ADD --chmod=755 oc_login.sh /tmp/tests/
# to debug on local
# ADD --chmod=755 oc_login_local.sh /tmp/tests/oc_login.sh

# Without this we got "read-only file system" bug during CI test runs
RUN chgrp -R 0 /var && chmod -R g=u /var

# test results are in $PROJECT/target/failsafe-reports/*.xml for every PROJECT in $PROJECTS.
CMD ./oc_login.sh && ./run.sh
