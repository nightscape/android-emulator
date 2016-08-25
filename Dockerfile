FROM ubuntu:latest

MAINTAINER Martin Mauch <martin.mauch@gmail.com>

# Expose ADB, ADB control and VNC ports
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900

ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

RUN apt-get -y update && \
  apt-get -y install software-properties-common bzip2 net-tools socat curl && \
  add-apt-repository ppa:webupd8team/java && \
  apt-get -y update && \
  apt-get -y install oracle-java8-installer

# Install Android SDK
ARG SDK_VERSION=24.3.4
RUN  mkdir -p /opt && curl -L http://dl.google.com/android/android-sdk_r$SDK_VERSION-linux.tgz | tar zxv -C /opt

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Update ADB
RUN echo "y" | android update adb

ARG EMULATOR_VERSION=android-24
ARG BUILD_TOOLS_VERSION=24.0.2
# Install latest android tools and system images
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -a --filter platform-tools,build-tools-$BUILD_TOOLS_VERSION,$EMULATOR_VERSION,sys-img-x86-$EMULATOR_VERSION --no-ui --force

# Create fake keymap file
RUN mkdir /opt/android-sdk-linux/tools/keymaps
RUN touch /opt/android-sdk-linux/tools/keymaps/en-us

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
