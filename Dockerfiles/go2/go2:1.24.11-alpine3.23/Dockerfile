FROM golang:1.24-alpine3.23

RUN apk add git 

WORKDIR /home
RUN git clone https://github.com/myyrakle/go2
WORKDIR /home/go2
RUN git switch release-branch.go1.24

RUN apk add gcc musl-dev bash
WORKDIR /home/go2/src
ENV GOROOT_BOOTSTRAP=/home/go2/bin
RUN ./make.bash
WORKDIR /home/go2
RUN rm -rf .git .gitignore .github

RUN rm -rf /usr/local/go && mv /home/go2 /usr/local/go 

RUN go version
