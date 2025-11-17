#
# Copyright © 2025 CESSDA ERIC (support@cessda.eu)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ===== Stage 1: Build =====
FROM eclipse-temurin:21-jdk AS builder

# Install Maven in the build stage
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Define environment variables
ENV APP_HOME=/opt/cessda/fair-tests
WORKDIR $APP_HOME

# Copy Maven project files
COPY pom.xml .

# Pre-fetch dependencies for faster incremental builds
RUN mvn dependency:go-offline -B

# Copy the actual source code
COPY src ./src

# Build the JAR
RUN mvn clean package -DskipTests

# ===== Stage 2: Runtime =====
FROM eclipse-temurin:21-jre-alpine AS runtime

# Environment variables for runtime config
ENV APP_HOME=/opt/cessda/fair-tests \
    APP_NAME=cessda-fairtests-1.0.0-jar-with-dependencies.jar \
    MAIN_CLASS=cessda.fairtests.MetadataUsesCessdaAccessRights \
    CDC_URL=""

WORKDIR $APP_HOME

# Copy the built JAR from the build stage
COPY --from=builder $APP_HOME/target/*.jar $APP_HOME/$APP_NAME

# Entrypoint — run the Java class with the CDC URL passed as an argument
ENTRYPOINT ["sh", "-c", "java -cp $APP_HOME/$APP_NAME $MAIN_CLASS \"${CDC_URL}\""]

