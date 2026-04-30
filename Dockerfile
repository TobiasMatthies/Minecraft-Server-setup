FROM eclipse-temurin:25

WORKDIR /app
COPY . .
RUN chmod +x entrypoint.sh

WORKDIR /server

EXPOSE 25565

ENTRYPOINT ["/app/entrypoint.sh"]
