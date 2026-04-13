FROM eclipse-temurin:25

WORKDIR /server

VOLUME ["/server/data"]

COPY . /server

RUN echo "eula=true" > /server/eula.txt

EXPOSE 25565

ENTRYPOINT ["java", "-Xmx4G", "-Xms2G", "-jar", "server.jar", "nogui"]
