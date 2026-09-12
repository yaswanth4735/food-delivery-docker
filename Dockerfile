# Stage 1: Build Stage
FROM maven:3.9.0-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:resolve

# Copy source code
COPY src ./src

# Build the Maven project and generate WAR file
RUN mvn clean package -DskipTests

# Stage 2: Runtime Stage
FROM tomcat:10.1-jre17

LABEL maintainer="Food Delivery Team"
LABEL version="1.0"
LABEL description="Docker image for Online Food Delivery System - FOODimage"

# Set environment variables
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# Remove default Tomcat applications
RUN rm -rf $CATALINA_HOME/webapps/ROOT \
    && rm -rf $CATALINA_HOME/webapps/docs \
    && rm -rf $CATALINA_HOME/webapps/examples \
    && rm -rf $CATALINA_HOME/webapps/manager \
    && rm -rf $CATALINA_HOME/webapps/host-manager

# Copy the WAR file from builder stage
COPY --from=builder /app/target/*.war $CATALINA_HOME/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Set working directory
WORKDIR $CATALINA_HOME

# Run Tomcat
CMD ["catalina.sh", "run"]
