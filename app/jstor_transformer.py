import sys, os, os.path, json, requests, traceback, time
import subprocess
from tenacity import retry, retry_if_result, wait_random_exponential, retry_if_not_exception_type
from datetime import datetime
from flask import Flask, request, jsonify, current_app, make_response
from random import randint
from time import sleep
#from  saxonpy  import PySaxonProcessor

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
        xsltFile = "xslt/ssio2via.xsl"
        directory = "/tmp/JSTORFORUM/harvested/loebmusic"
        current_app.logger.info("call saxon")    
        subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:/tmp/JSTORFORUM/output.xml", "-s:8000188494.xml", "-xsl:xslt/ssio2via.xsl"])                               
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

    def revert_task(self, job_ticket_id, task_name):
        return True
