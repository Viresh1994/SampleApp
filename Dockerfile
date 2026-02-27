# ---------- Build stage ----------
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests
# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.war app.war

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "app.war"]
# FROM eclipse-temurin:21-jre

# WORKDIR /app

# COPY demo-0.0.1-SNAPSHOT.war app.war
# #COPY target/demo-0.0.1-SNAPSHOT.war app.war

# EXPOSE 8080

# ENTRYPOINT ["java", "-jar", "app.war"]
