import sys, os, os.path, json, requests, traceback, time
import subprocess
from tenacity import retry, retry_if_result, wait_random_exponential, retry_if_not_exception_type
from datetime import datetime
from flask import Flask, request, jsonify, current_app, make_response
from random import randint
from time import sleep
from pymongo import MongoClient
import fnmatch

class JstorTransformer():
    def __init__(self):
        self.child_running_jobs = []
        self.child_error_jobs = []
        self.child_success_jobs = []
        self.parent_job_ticket_id = None
        self.child_error_count = 0
        self.max_child_errors = int(os.getenv("CHILD_ERROR_LIMIT", 10))

    # Write to error log update result and update job tracker file
    def handle_errors(self, result, error_msg, exception_msg = None, set_job_failed = False):
        exception_msg = str(exception_msg)
        current_app.logger.error(exception_msg)
        current_app.logger.error(error_msg)
        result['error'] = error_msg
        result['message'] = exception_msg
        # Append error to job tracker file errors_encountered list
        if self.parent_job_ticket_id:
            job_tracker.append_error(self.parent_job_ticket_id, error_msg, exception_msg, set_job_failed)

        return result

    def do_task(self, request_json):

        result = {
          'success': False,
          'error': None,
          'message': ''
        }
        #Get the job ticket which should be the parent ticket
        current_app.logger.info("**************JStor Transformer: Do Task**************")
        current_app.logger.info("WORKER NUMBER " + str(os.getenv('CONTAINER_NUMBER')))

        sleep_s = int(os.getenv("TASK_SLEEP_S", 1))

        current_app.logger.info("Sleep " + str(sleep_s) + "seconds")
        sleep(sleep_s)

        #dump json
        current_app.logger.info("json message: " + json.dumps(request_json))
        jstorforum = False
        if 'jstorforum' in request_json:
            current_app.logger.info("running jstorforum transform")
            jstorforum = request_json['jstorforum']
        if jstorforum:
            self.do_transform('jstorforum')

        aspace = False
        if 'aspace' in request_json:
            current_app.logger.info("running aspace transform")
            aspace = request_json['aspace']
        if aspace:
            self.do_transform('aspace')

        #integration test: write small record to mongo to prove connectivity
        integration_test = False
        if ('integration_test' in request_json):
            integration_test = request_json['integration_test']
        if (integration_test):
            current_app.logger.info("running integration test")
            #do a transform using the test config file
            self.do_transform('jstorforum', True)
            self.do_transform('aspace',True)
            try:
                mongo_url = os.environ.get('MONGO_URL')
                mongo_dbname = os.environ.get('MONGO_DBNAME')
                mongo_collection = os.environ.get('MONGO_COLLECTION_ITEST')
                mongo_client = MongoClient(mongo_url, maxPoolSize=1)

                mongo_db = mongo_client[mongo_dbname]
                integration_collection = mongo_db[mongo_collection]
                job_ticket_id = str(request_json['job_ticket_id'])
                test_id = "transformer-" + job_ticket_id
                test_record = { "id": test_id, "status": "inserted" }
                integration_collection.insert_one(test_record)
                mongo_client.close()
            except Exception as err:
                current_app.logger.error("Error: unable to connect to mongodb, {}", err)
        
        result['success'] = True
        # altered line so we can see request json coming through properly
        result['message'] = 'Job ticket id {} has completed '.format(request_json['job_ticket_id'])

        return result

    def do_transform(self, jobname, itest=False):
        if itest:
            configfile = "harvestjobs_test.json"
        else:
            configfile = "harvestjobs.json"
        current_app.logger.info("configfile: " + configfile)
        with open(configfile) as f:
            harvjobsjson = f.read()
        harvestconfig = json.loads(harvjobsjson)
        #current_app.logger.debug("harvestconfig")        
        #current_app.logger.debug(harvestconfig) 
        harvestDir = os.getenv("jstor_harvest_dir")        
        transformDir = os.getenv("jstor_transform_dir")
        for job in harvestconfig:     
            if jobname == 'jstorforum' and jobname == job["jobName"]:   
                for set in job["harvests"]["sets"]:
                    opDir = set["opDir"]
                    if os.path.exists(harvestDir + opDir + "_oaiwrapped"):
                        if len(fnmatch.filter(os.listdir(harvestDir + opDir + "_oaiwrapped"), '*.xml')) > 0:
                            for filename in os.listdir(harvestDir + opDir + "_oaiwrapped"):
                                #subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + opDir + "/" + filename, "-s:" + harvestDir + opDir + "/" + filename, "-xsl:xslt/ssio2via.xsl"])
                                subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + harvestDir + opDir + "/" + filename, "-s:" + harvestDir + opDir + "_oaiwrapped/" + filename, "-xsl:xslt/strip_oai_ssio.xsl"])
                                subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + opDir + "/" + filename, "-s:" + harvestDir + opDir + "/" + filename, "-xsl:xslt/ssio2via.xsl"])                               
                                subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + opDir + "_hollis/" + filename, "-s:" + transformDir + opDir + "/" + filename, "-xsl:xslt/via2hollis.xsl"])                               

            if jobname == 'aspace' and jobname == job["jobName"]:    
                for filename in os.listdir(harvestDir + 'aspace'):
                    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + "aspace_stripwrapper/" + filename, "-s:" + harvestDir + "aspace/" + filename, "-xsl:xslt/strip_oai_aspace.xsl"])                               
                    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + "aspace_valid/" + filename, "-s:" + transformDir + "aspace_stripwrapper/" + filename, "-xsl:xslt/aspace2valid.xsl"])                               
                    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + "aspace_harvard/" + filename, "-s:" + transformDir + "aspace_valid/" + filename, "-xsl:xslt/aspace2oasis.xsl"])                               
                    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + "aspace_hollis_part1/" + filename, "-s:" + transformDir + "aspace_harvard/" + filename, "-xsl:xslt/ead2hollis_part1.xsl"])  
                    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" + transformDir + "aspace_hollis/" + filename, "-s:" + transformDir + "aspace_hollis_part1/" + filename, "-xsl:xslt/ead2hollis_part2.xsl"])  

    def revert_task(self, job_ticket_id, task_name):
        return True
