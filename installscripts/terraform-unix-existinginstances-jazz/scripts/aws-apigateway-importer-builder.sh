#!/bin/bash
JENKINS_SERVER=$1
#JENKINS_SERVER=ec2-user@54.227.196.90
BUILD_MAVEN=$2
SKIP_TEST=$3
FILENAME='/tmp/aws-apigateway-importer/aws-apigateway-importer-1.0.3-SNAPSHOT-jar-with-dependencies.jar'
TARGET_LOC="/tmp/aws-apigateway-importer/target"
if [[ $BUILD_MAVEN == 'yes' ||  ! -f $FILENAME  ]]
then
	echo " $FILENAME does not exist and BUILD_MAVEN=$BUILD_MAVEN so will build jars"
	cd ./jazz-core/aws-apigateway-importer
	mvn assembly:assembly -Dmaven.test.skip=$SKIP_TEST

	mkdir -vp /tmp/aws-apigateway-importer
	cp -v ./target/*.jar /tmp/aws-apigateway-importer/
	cd -
else
	echo " $FILENAME exists and BUILD_MAVEN=$BUILD_MAVEN so will upload existing jar"
fi
echo teststs
pwd
ssh -i "../sshkeys/ustglobal_rsa.pem"  -o "StrictHostKeyChecking=no" $JENKINS_SERVER "mkdir -p  $TARGET_LOC"
scp -i "../sshkeys/ustglobal_rsa.pem" -o "StrictHostKeyChecking=no" /tmp/aws-apigateway-importer/*.jar $JENKINS_SERVER:$TARGET_LOC
ssh -i "../sshkeys/ustglobal_rsa.pem"  -o "StrictHostKeyChecking=no" $JENKINS_SERVER "chmod -R 777  $TARGET_LOC"
