FROM ubuntu:latest
RUN apt-get update
RUN apt-get install git curl -y
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash
RUN apt-get install nodejs -y
WORKDIR /home
RUN git clone https://github.com/myyrakle/docker-image-for-test
WORKDIR /home/docker-image-for-test/node-server-for-test
EXPOSE 80
ENTRYPOINT [ "sh", "/home/docker-image-for-test/node-server-for-test/run.sh" ]