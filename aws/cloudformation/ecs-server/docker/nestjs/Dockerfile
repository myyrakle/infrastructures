# 원본 이미지 레포지토리는 AWS ECR을 사용하는 것을 권장함. (docker hub pull의 limit rate issue)
FROM ubuntu
RUN apt-get update -y
RUN apt-get install -y curl 
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -E -
RUN apt install -y nodejs 
WORKDIR /home
COPY . server
COPY ./run.sh ./run.sh
WORKDIR /home/server 
RUN npm i  
RUN npm run build
WORKDIR /home
EXPOSE 80