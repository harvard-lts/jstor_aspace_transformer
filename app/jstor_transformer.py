import sys, os, os.path, json, requests, traceback, time
from tenacity import retry, retry_if_result, wait_random_exponential, retry_if_not_exception_type
from datetime import datetime
from flask import Flask, request, jsonify, current_app, make_response
from random import randint
from time import sleep
<<<<<<< HEAD
from pymongo import MongoClient
=======
from  saxonpy  import PySaxonProcessor
>>>>>>> 02fb918 (add xsl files, prototype the ssio2via transform)

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
        """\
Get job tracker file
Append job ticket id to jobs in process list in the tracker file
Update job timestamp file"""

        result = {
          'success': False,
          'error': None,
          'message': ''
        }

        #Get the job ticket which should be the parent ticket
        current_app.logger.error("**************JStor Transformer: Do Task**************")
        current_app.logger.error("WORKER NUMBER " + str(os.getenv('CONTAINER_NUMBER')))

        #xmlFile = open(file="/tmp/JSTORFORUM/harvested/loebmusic/8000188508.xml", encoding="utf-8")
        xsltFile = open(file="xslt/ssio2via.xsl", encoding="utf-8")
        directory = "/tmp/JSTORFORUM/harvested/loebmusic"
        for filename in os.listdir(directory):
            current_app.logger.info("filename")
            current_app.logger.info(filename)
            #_f = os.path.join(directory, filename)
            xmlFile = open(file=directory + "/" + filename, encoding="utf-8") #open(file=_f, encoding="utf-8")
            current_app.logger.info("1")
            #self.do_transform(directory + "/" + filename)
            with PySaxonProcessor(license=False) as proc:
                current_app.logger.info("2")
                xsltProc = proc.new_xslt_processor()
                document = proc.parse_xml(xml_text=xmlFile.read())
                xsltProc.set_source(xdm_node=document)
                xsltProc.compile_stylesheet(stylesheet_text=xsltFile.read())
                xsltProc.set_jit_compilation(True)
                xsltProc.transform_to_file()
                output = xsltProc.transform_to_string()
                f = open("/tmp/JSTORFORUM/transformed/loebmusic/" + filename, "w")
                f.write(output)
                f.close()
            xmlFile.close()                               
        result['success'] = True
        # altered line so we can see request json coming through properly
        result['message'] = 'Job ticket id {} has completed '.format(request_json['job_ticket_id'])

        #sleep_s = os.getenv("TASK_SLEEP_S", 1)

        #current_app.logger.info("Sleep " + str(sleep_s) + "seconds")
        #sleep(1)
        
        return result

    def do_transform(filename):
        xsltFile = open(file="xslt/ssio2via.xsl", encoding="utf-8")
        xmlFile = open(file=filename, encoding="utf-8")
        with PySaxonProcessor(license=False) as proc:
            current_app.logger.info("2")
            '''
            xsltProc = proc.new_xslt30_processor()
            xsltProc.set_cwd(".") 
            xsltProc.transform_to_file(source_file=directory + "/" + filename ,stylesheet_file="xslt/ssio2via.xsl", output_file="/tmp/JSTORFORUM/transformed/loebmusic/test" + filename)
            '''
            xsltProc = proc.new_xslt_processor()
            document = proc.parse_xml(xml_text=xmlFile.read())
            xsltProc.set_source(xdm_node=document)
            xsltProc.compile_stylesheet(stylesheet_text=xsltFile.read())
            xsltProc.set_jit_compilation(True)
            xsltProc.transform_to_file()
            output = xsltProc.transform_to_string()
            f = open("/tmp/JSTORFORUM/transformed/loebmusic/" + filename, "w")
            f.write(output)
            f.close()

        result['success'] = True
        # altered line so we can see request json coming through properly
        result['message'] = 'Job ticket id {} has completed '.format(request_json['job_ticket_id'])

        sleep_s = int(os.getenv("TASK_SLEEP_S", 1))

        current_app.logger.info("Sleep " + str(sleep_s) + "seconds")
        sleep(sleep_s)

        #dump json
        current_app.logger.info("json message: " + json.dumps(request_json))

        #integration test: write small record to mongo to prove connectivity
        integration_test = False
        if ('integration_test' in request_json):
            integration_test = request_json['integration_test']
        if (integration_test):
            current_app.logger.info("running integration test")
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
        
        return result

    def revert_task(self, job_ticket_id, task_name):
        return True
