FROM golang:1.15.6

MAINTAINER dongdavid

ADD nwrfcsdk.tar.gz /tmp

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN mkdir /usr/local/sap \
    && mv /tmp/nwrfcsdk/nwrfcsdk /usr/local/sap/ \
    && echo export SAPNWRFC_HOME=/usr/local/sap/nwrfcsdk/ >> /root/.bashrc \
    && source /root/.bashrc \
    && echo /usr/local/sap/nwrfcsdk/lib >> /etc/ld.so.conf.d/nwrfcsdk.conf \
    && ldconfig \
    && export CGO_CFLAGS="-I $SAPNWRFC_HOME/include" \
    && export CGO_LDFLAGS="-L $SAPNWRFC_HOME/lib" \
    && export CGO_CFLAGS_ALLOW=.* \
    && export CGO_LDFLAGS_ALLOW=.* \
    && go get github.com/stretchr/testify \
    && go get github.com/dongdavid/gorfc \
    && cd $GOPATH/src/github.com/dongdavid/gorfc/gorfc \
    && go build \
    && go install 