FROM eclipse-temurin:25

WORKDIR /server

COPY server.jar /serverfile/server.jar

EXPOSE 25565

ENTRYPOINT ["java", "-Xmx4G", "-Xms2G", "-jar", "/serverfile/server.jar", "nogui"]
