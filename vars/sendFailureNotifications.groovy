#!/usr/bin/env groovy

def call(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """${buildStatus}: Job '${env.JOB_NAME}. Build Number: [${env.BUILD_NUMBER}]'
Check console output at: ${env.BUILD_URL}console"""

  emailext (
      to: 'feroz.shaikh@ust-global.com,surya.jakhotia1@t-mobile.com,raghavendra.pai@ust-global.com,somanchi.subramanyam@ust-global.com',
      subject: subject,
      body: details,
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
}
