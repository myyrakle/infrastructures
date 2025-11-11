FROM ubuntu
RUN apt-get update -y
RUN apt-get install openjdk-17-jre openjdk-17-jdk -y
WORKDIR /home
COPY . server
COPY ./run.sh ./run.sh
WORKDIR /home/server 
RUN sh ./gradlew build
RUN mv ./build/libs/server.jar ./../server.jar
WORKDIR /home
RUN rm -rf ./server
ENTRYPOINT ["sh", "./run.sh"]
EXPOSE 80