#!/usr/bin/env bash

function extract_scanner_properties() {
  mkdir -p result
  #for MAVEN_VERSION in 4.0.0-alpha-7 3.9.5 3.9.4 3.8.8 3.6.3 3.5.4 3.3.9 3.2.5 3.1.1 3.0.5 2.2.1 2.2.0; do
  for MAVEN_VERSION in 3.9.5 3.8.8 3.6.3; do
    echo "Maven version: ${MAVEN_VERSION}"
    ./mvnw --quiet wrapper:wrapper "-Dmaven=${MAVEN_VERSION}"
    #for SONAR_MAVEN_VERSION in 3.10.0.2594 3.9.1.2184 3.9.0.2155 3.8.0.2131 3.7.0.1746 3.6.1.1688 3.6.0.1398 3.5.0.1254; do
    for SONAR_MAVEN_VERSION in 3.10.0.2594 3.9.1.2184 3.8.0.2131; do
      #for MAVEN_GOAL in clean validate compile test package verify install; do
      for MAVEN_GOAL in compile package verify install; do
        ./mvnw --quiet clean
        rm -r "${HOME}/.m2/repository/org/example/multi-module-project" > /dev/null 2>&1 || true

        RESULT_FILE="result/scan-maven-${MAVEN_VERSION}-sonar-${SONAR_MAVEN_VERSION}-${MAVEN_GOAL}-with.properties"
        ./mvnw "${MAVEN_GOAL}" \
         "org.sonarsource.scanner.maven:sonar-maven-plugin:${SONAR_MAVEN_VERSION}:sonar" \
         "-Dsonar.login=${SQ_USER}" \
         "-Dsonar.password=${SQ_PASSWORD}" \
         "-Dsonar.scanner.dumpToFile=${RESULT_FILE}"

        ./filter_properties "${RESULT_FILE}"

        RESULT_FILE="result/scan-maven-${MAVEN_VERSION}-sonar-${SONAR_MAVEN_VERSION}-${MAVEN_GOAL}-after.properties"
        ./mvnw \
         "org.sonarsource.scanner.maven:sonar-maven-plugin:${SONAR_MAVEN_VERSION}:sonar" \
         "-Dsonar.login=${SQ_USER}" \
         "-Dsonar.password=${SQ_PASSWORD}" \
         "-Dsonar.scanner.dumpToFile=${RESULT_FILE}"

        ./filter_properties "${RESULT_FILE}"
      done
    done
  done
}

extract_scanner_properties
