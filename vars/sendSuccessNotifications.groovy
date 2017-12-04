#!/usr/bin/env groovy

def call(String buildStatus = 'STARTED', String SN) {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'
  Stack_name = SN
  // Default values
  def subject = "${buildStatus} Build for: ${Stack_name}"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """${buildStatus}: Job '${env.JOB_NAME}. Build Number: [${env.BUILD_NUMBER}]'
This build is for Stack: ${Stack_name}
Check console output at: ${env.BUILD_URL}console"""

  emailext (
      to: 'feroz.shaikh@ust-global.com,surya.jakhotia1@t-mobile.com,raghavendra.pai@ust-global.com,somanchi.subramanyam@ust-global.com',
      subject: subject,
      body: details,
      attachmentsPattern: 'Stack_details.txt',
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
}
