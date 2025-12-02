# Stage 1: Build
FROM maven:3.9-amazoncorretto-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM amazoncorretto:11-alpine-jdk
WORKDIR /app

# CHANGE 1: Copy the .war file, not .jar
COPY --from=build /app/target/*.war app.war

EXPOSE 8080

# CHANGE 2: Run the .war file
ENTRYPOINT ["java", "-jar", "app.war"]