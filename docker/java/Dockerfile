# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
ARG IMAGE_NAME=eclipse-temurin:21-alpine
ARG CLASSPATH=""
ARG JAVA_OPTS=""
ARG APM_OPTS=""

FROM $IMAGE_NAME AS base

## Stage 1: Create NGINX configuration
USER root

# Copy the application configuarion as per the application
# Build process must ensure output jar is unique for each build
COPY target/*.jar /app/webapp/bin/app.jar

# Stage 2: Customized configuation injection occurs at command line
FROM base AS customized
WORKDIR /app
#<DOCKER-INJECTION-POINT>

# Stage 3: Final image
FROM customized AS final

RUN addgroup --gid 10001 --system webapp \
 && adduser  --uid 10000 --system --ingroup webapp --home /app/webapp webapp \
 && chown -R webapp:webapp /app/webapp/

COPY ./startup.sh /app/webapp/
RUN chmod +x /app/webapp/startup.sh
ENV CLASSPATH=${CLASSPATH}
ENV JAVA_OPTS=${JAVA_OPTS}
ENV APM_OPTS=${APM_OPTS}


EXPOSE 8080
ENTRYPOINT ["/app/webapp/startup.sh"]
