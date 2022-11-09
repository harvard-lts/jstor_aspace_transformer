#!groovy
@Library('huit-lts-basic-pipeline') _

// projName is the directory name for the project on the servers for it's docker/config files
// default values: 
//  registryCredentialsId = "${env.REGISTRY_ID}"
//  registryUri = 'https://registry.lts.harvard.edu'
def endpoints = []
huitLtsBasicPipeline.call("jstor-aspace-transformerer", "JSTORFORUM", "jstorforum", "", endpoints, "lts-jstorforum-alerts")
