#!/bin/bash
set -eux

export _JAVA_OPTIONS=-Duser.home=$HOME

# The CI testing not using this file, to modify the mvn command
# change this file https://github.com/openshift/release/blob/master/ci-operator/step-registry/quarkus/execute-tests/quarkus-execute-tests-commands.sh
mvn -B -V clean verify -fae \
    -Dmaven.repo.local=$PWD/local-repo \
    -Dquarkus.platform.group-id=$QUARKUS_PLATFORM_GROUP_ID \
    -Dquarkus.platform.artifact-id=$QUARKUS_PLATFORM_ARTIFACT_ID \
    -Dquarkus.platform.version=$QUARKUS_VERSION \
    -Dquarkus-plugin.version=$QUARKUS_VERSION \
    -Proot-modules,http-modules,sql-db-modules,monitoring-modules \
    -Dopenshift \
    -pl $PROJECTS
