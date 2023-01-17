FROM debian:11-slim

MAINTAINER magonzalez112 <magonzalez112@users.noreply.github.com>

ARG USERNAME=bridge-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /opt
COPY asterisk-zammad-cti-bridge /opt
COPY config.cfg /opt

# Create the user and install dependencies
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install --no-install-recommends -y perl libanyevent-http-perl libconfig-simple-perl libdata-printer-perl \
                liblog-any-perl liblog-any-adapter-dispatch-perl libwww-form-urlencoded-perl libnet-ssleay-perl libcrypt-ssleay-perl make cpanminus \
    && cpanm Asterisk::AMI
    #&& apt-get install -y sudo \
    #&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    #&& chmod 0440 /etc/sudoers.d/$USERNAME

RUN chown $USER_UID:$USER_GID config.cfg
RUN chown $USER_UID:$USER_GID asterisk-zammad-cti-bridge
RUN chmod u+x asterisk-zammad-cti-bridge
RUN chmod 600 config.cfg

USER $USERNAME

ENTRYPOINT ["/opt/asterisk-zammad-cti-bridge"]
