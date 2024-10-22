# Use the OpenJDK 17 JDK slim image as the base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container to /app
WORKDIR /app

# Copy the demo.jar file from the host machine to the /app directory inside the container
COPY build/libs/demo.jar /app

# Expose port 8080 to allow communication with the outside world
EXPOSE 8080

# Define the command to run the Java application inside the container
CMD ["java", "-jar", "demo.jar"]