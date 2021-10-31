#!/usr/bin/env bash

set -x

cd /tmp || exit
rm -f agent.jar
curl http://jenkins:8080/jnlpJars/agent.jar -O agent.jar
java -jar agent.jar -jnlpUrl http://jenkins:8080/computer/Symfony-Dockerized-node/jenkins-agent.jnlp -secret e556a40482fbaff2270c657fe244ce69afa966f2bdccc46dbcf1c0aac070d0c1 -workDir "/tmp"