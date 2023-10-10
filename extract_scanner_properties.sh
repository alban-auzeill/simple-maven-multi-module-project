#!/usr/bin/env bash

set -euo pipefail

function extract_scanner_properties() {
  if [[ -e "result" ]]; then
    rm -r result
  fi
  mkdir result
  mkdir result/split
  mkdir result/tmp
  mkdir result/mix
  #for MAVEN_VERSION in 4.0.0-alpha-7 3.9.5 3.9.4 3.8.8 3.6.3 3.5.4 3.3.9 3.2.5 3.1.1 3.0.5 2.2.1 2.2.0; do
  for MAVEN_VERSION in 4.0.0-alpha-7 3.9.5 3.8.8 3.6.3 3.5.4; do
    mvn --quiet wrapper:wrapper "-Dmaven=${MAVEN_VERSION}"
    #for SONAR_MAVEN_VERSION in 3.10.0.2594 3.9.1.2184 3.9.0.2155 3.8.0.2131 3.7.0.1746 3.6.1.1688 3.6.0.1398 3.5.0.1254; do
    for SONAR_MAVEN_VERSION in 3.10.0.2594 3.9.1.2184 3.8.0.2131 3.7.0.1746 3.6.1.1688 3.5.0.1254; do
      #for MAVEN_GOAL in clean validate compile test package verify install; do
      for MAVEN_GOAL in clean validate compile test package verify install; do
        ./mvnw --quiet clean
        rm -r "${HOME}/.m2/repository/org/example/multi-module-project" > /dev/null 2>&1 || true

        RESULT_FILE="result/split/maven-${MAVEN_VERSION}__sonar-maven-plugin-${SONAR_MAVEN_VERSION}___with-${MAVEN_GOAL}.properties"
        echo "${RESULT_FILE}"
        ./mvnw --quiet "${MAVEN_GOAL}" \
         "org.sonarsource.scanner.maven:sonar-maven-plugin:${SONAR_MAVEN_VERSION}:sonar" \
         "-Dsonar.login=${SONAR_LOGIN}" \
         "-Dsonar.password=${SONAR_PASSWORD}" \
         "-Dsonar.scanner.dumpToFile=${RESULT_FILE}"

        ./filter_properties "${RESULT_FILE}"
        cp "${RESULT_FILE}" "result/tmp/part1.properties"
        convert_to_sha1 "${RESULT_FILE}"

        RESULT_FILE="result/split/maven-${MAVEN_VERSION}__sonar-maven-plugin-${SONAR_MAVEN_VERSION}__after-${MAVEN_GOAL}.properties"
        echo "${RESULT_FILE}"
        ./mvnw --quiet \
         "org.sonarsource.scanner.maven:sonar-maven-plugin:${SONAR_MAVEN_VERSION}:sonar" \
         "-Dsonar.login=${SONAR_LOGIN}" \
         "-Dsonar.password=${SONAR_PASSWORD}" \
         "-Dsonar.scanner.dumpToFile=${RESULT_FILE}"

        ./filter_properties "${RESULT_FILE}"
        cp "${RESULT_FILE}" "result/tmp/part2.properties"
        convert_to_sha1 "${RESULT_FILE}"

        cat "result/tmp/part1.properties" > "result/tmp/all.properties"
        cat "result/tmp/part2.properties" >> "result/tmp/all.properties"
        local ALL_PROP_FILE=""
        ALL_PROP_FILE="result/mix/$(md5sum "result/tmp/all.properties" | awk '{print $1}').properties"
        if [[ ! -e "${ALL_PROP_FILE}" ]]; then
          (
            echo "# ____________________________________________________________"
            echo "# sonar-maven-plugin executed WITH the maven goal"
            cat "result/tmp/part1.properties"
            echo
            echo
            echo "# ____________________________________________________________"
            echo "# sonar-maven-plugin executed AFTER the maven goal"
            cat "result/tmp/part2.properties"
            echo
            echo
            echo "# ____________________________________________________________"
            echo "# configurations producing the above properties"
            echo "#"
          ) > "${ALL_PROP_FILE}"
        fi
        echo "# Maven: ${MAVEN_VERSION}, sonar-maven-plugin: ${SONAR_MAVEN_VERSION}, maven goal: ${MAVEN_GOAL}" >> "${ALL_PROP_FILE}"
        rm "result/tmp/part1.properties" "result/tmp/part2.properties" "result/tmp/all.properties"
      done
    done
  done
  ./mvnw --quiet wrapper:wrapper "-Dmaven=3.9.5"
}

function convert_to_sha1() {
  local RESULT_FILE="$1"
  local FILE_HASH=""
  FILE_HASH="$(md5sum "${RESULT_FILE}" | awk '{print $1}')"
  echo "${RESULT_FILE}" >> "result/split/${FILE_HASH}.txt"
  sort -o "result/split/${FILE_HASH}.txt" "result/split/${FILE_HASH}.txt"
  if [[ -e "result/split/${FILE_HASH}.properties" ]]; then
    rm "${RESULT_FILE}"
  else
    mv "${RESULT_FILE}" "result/split/${FILE_HASH}.properties"
  fi
}

extract_scanner_properties
