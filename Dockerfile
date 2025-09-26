# ---- Build stage ----
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# copy build files first to leverage cache
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw -q -B -DskipTests dependency:go-offline

# build
COPY src ./src
RUN ./mvnw -q -B -DskipTests package && \
    cp target/*.jar /app/app.jar

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/app.jar /app/app.jar

# sensible defaults; switch profile to 'mysql' when wiring Aurora
ENV SERVER_PORT=8080 \
    SPRING_PROFILES_ACTIVE=prod \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError"

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar","--server.port=${SERVER_PORT}"]