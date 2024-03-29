import sys, os, os.path, json, requests, traceback, time, shutil, re
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
        self.repositories = self.load_repositories()

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
        job_ticket_id = str(request_json['job_ticket_id'])

        #integration test: write small record to mongo to prove connectivity
        integration_test = False
        if ('integration_test' in request_json):
            integration_test = request_json['integration_test']

        harvestset = None
        if 'harvestset' in request_json:
            harvestset = request_json["harvestset"]

        harvesttype = None
        if 'harvesttype' in request_json:
            harvesttype = request_json["harvesttype"]

        jstorforum = False
        if 'jstorforum' in request_json:
            current_app.logger.info("running jstorforum transform")
            jstorforum = request_json['jstorforum']
        if jstorforum:
            try:
                self.do_transform('jstorforum', harvestset, harvesttype, job_ticket_id)
            except Exception as err:
                current_app.logger.error("Error: unable to transform jstorforum records", exc_info=True)

        aspace = False
        if 'aspace' in request_json:
            current_app.logger.info("running aspace transform")
            aspace = request_json['aspace']
        if aspace:
            try:
                self.do_transform('aspace', None, None, job_ticket_id)
            except Exception as err:
                current_app.logger.error("Error: unable to transform aspace records", exc_info=True)

        if (integration_test):
            current_app.logger.info("running integration test")
            if os.path.exists(os.getenv("JSTOR_DEL_DROP_DIR")):
                for filename in os.listdir(os.getenv("JSTOR_DEL_DROP_DIR")):
                    shutil.copy(os.getenv("JSTOR_DEL_DROP_DIR") + "/" + filename, os.getenv("JSTOR_TEST_DIR"))
            try:
                self.do_transform('jstorforum', None, None, job_ticket_id, True)
            except Exception as err:
                current_app.logger.error("Error: unable to transform jstorforum records in itest", exc_info=True)
            try:
                self.do_transform('aspace', None, None, job_ticket_id, True)
            except Exception as err:
                current_app.logger.error("Error: unable to transform aspace records in itest", exc_info=True)

            try:
                mongo_url = os.environ.get('MONGO_URL')
                mongo_dbname = os.environ.get('MONGO_DBNAME')
                mongo_collection = os.environ.get('MONGO_COLLECTION_ITEST')
                mongo_client = MongoClient(mongo_url, maxPoolSize=1)

                mongo_db = mongo_client[mongo_dbname]
                integration_collection = mongo_db[mongo_collection]
                test_id = "transformer-" + job_ticket_id
                test_record = { "id": test_id, "status": "inserted" }
                integration_collection.insert_one(test_record)
                mongo_client.close()
            except Exception as err:
                current_app.logger.error("Error: unable to connect to mongodb", exc_info=True)
        
        result['success'] = True
        # altered line so we can see request json coming through properly
        result['message'] = 'Job ticket id {} has completed '.format(request_json['job_ticket_id'])

        return result

    def do_transform(self, jobname, harvestset, harvesttype, job_ticket_id, itest=False):
        current_app.logger.info(harvestset)
        if itest:
            configfile = "harvestjobs_test.json"
        else:
            configfile = "harvestjobs.json"
        current_app.logger.info("configfile: " + configfile)
        with open(configfile) as f:
            harvjobsjson = f.read()
        deleteRecordId = re.compile('.+deleteRecordId.*\>(\w+\d+)\<\/deleteRecordId.+')
        dropRecordId = re.compile('.+dropRecordId.*\>(\w+\d+)\<\/dropRecordId.+')
        harvestconfig = json.loads(harvjobsjson)
        #current_app.logger.debug("harvestconfig")        
        #current_app.logger.debug(harvestconfig)
        mongo_url = os.environ.get('MONGO_URL')
        mongo_dbname = os.environ.get('MONGO_DBNAME')
        harvest_collection_name = os.environ.get('HARVEST_COLLECTION', 'jstor_transformed_summary')
        repository_collection_name = os.environ.get('REPOSITORY_COLLECTION', 'jstor_repositories')
        record_collection_name = os.environ.get('JSTOR_TRANSFORMED_RECORDS', 'jstor_transformed_records')
        mongo_url = os.environ.get('MONGO_URL')
        mongo_client = None
        mongo_db = None
        try:
            mongo_client = MongoClient(mongo_url, maxPoolSize=1)
            mongo_db = mongo_client[mongo_dbname]
        except Exception as err:
            current_app.logger.error("Error: unable to connect to mongodb", exc_info=True)

        harvestDir = os.getenv("jstor_harvest_dir") + "/"         
        transformDir = os.getenv("jstor_transform_dir") + "/" 
        ssio2viaXsl = "ssio2via.xsl"
        if harvesttype == 'full':
            ssio2viaXsl = "ssio2viafull.xsl"
        current_app.logger.info("Transforming with: " + ssio2viaXsl) 
        props="-D -Xms512m -Xmx4096m"
        for job in harvestconfig:     
            if jobname == 'jstorforum' and jobname == job["jobName"]:   
                for set in job["harvests"]["sets"]:
                    transform_successful = True 
                    setSpec = "{}".format(set["setSpec"])
                    repository_name = self.repositories[setSpec]["displayname"]
                    repo_short_name = self.repositories[setSpec]["shortname"]
                    opDir = set["opDir"]
                    totalTransformCount = 0
                    harvestdate = datetime.today().strftime('%Y-%m-%d') 
                    if harvestset is None:
                        current_app.logger.info("begin transforming for " + setSpec)
                        if os.path.exists(harvestDir + opDir + "_oaiwrapped"):
                            if len(fnmatch.filter(os.listdir(harvestDir + opDir + "_oaiwrapped"), '*.xml')) > 0:
                                current_app.logger.info("begin transforming - strip oai")
                                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/strip_oai_ssio.xsl", harvestDir + opDir + "_oaiwrapped/", harvestDir + opDir])
                                current_app.logger.info("begin transforming - ssio2via")
                                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/" + ssio2viaXsl, harvestDir + opDir, transformDir + opDir])
                                current_app.logger.info("checking for group records")
                                if os.path.exists(os.getenv("JSTOR_LARGERCONTEXT_DIR")):
                                    if len(fnmatch.filter(os.listdir(os.getenv("JSTOR_LARGERCONTEXT_DIR")), '*.xml')) > 0:
                                        for filename in os.listdir(os.getenv("JSTOR_LARGERCONTEXT_DIR")):
                                            shutil.move(os.getenv("JSTOR_LARGERCONTEXT_DIR") + "/" + filename, transformDir + opDir + "/" + filename)
                                current_app.logger.info("begin transforming - via2hollis")
                                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/via2hollis.xsl", transformDir + opDir, transformDir + opDir + "_hollis"])
                                current_app.logger.info("done transforming for " + setSpec)

                                for filename in os.listdir(transformDir + opDir):
                                    status = "add_update"
                                    try:
                                        if os.path.getsize(transformDir + opDir + "/" + filename) < 100: # must be a delete or drop if this small, else junk
                                            current_app.logger.info("Moving deletes and drops")
                                            with open(transformDir + opDir + "/" + filename) as input:
                                                for line in input:
                                                    matchDel = deleteRecordId.match(line)
                                                    matchDrop = dropRecordId.match(line) 
                                                    if matchDel:
                                                        shutil.move(transformDir + opDir + "/" + filename, os.getenv("JSTOR_DELETES_DIR") + "/" + setSpec + "_" + filename)
                                                        os.remove(transformDir + opDir + "_hollis/" + filename)
                                                        status = "delete"
                                                    elif matchDrop:
                                                        shutil.move(transformDir + opDir + "/" + filename, os.getenv("JSTOR_DROPS_DIR") + "/" + filename)
                                                        os.remove(transformDir + opDir + "_hollis/" + filename)
                                                        status = "drop"
                                                    else:
                                                        current_app.logger.info("No useful data, but not a drop or delete: " + filename)    
                                                                
                                        identifier = filename[:-4]
                                        totalTransformCount = totalTransformCount + 1
                                        #write/update record
                                        try:
                                            success = True
                                            self.write_record(job_ticket_id, identifier, harvestdate, setSpec, repository_name, repo_short_name,
                                                status, record_collection_name, success, mongo_db)
                                        except Exception as e:
                                            current_app.logger.error("Mongo error writing " + setSpec + " record: " +  identifier, exc_info=True)
                                            transform_successful = False
                                    except Exception as err:
                                        transform_successful = False
                                        current_app.logger.error("VIA/SSIO transform error for id " + identifier, exc_info=True)
                                        #log error to mongo
                                        status = "add_update"
                                        success = False
                                        try:
                                            self.write_record(job_ticket_id, identifier, harvestdate, setSpec, repository_name, repo_short_name, 
                                                status, record_collection_name, success, mongo_db, err)
                                        except Exception as e:
                                            current_app.logger.error("Mongo error writing " + setSpec + " record: " +  identifier, exc_info=True)
                        else:
                            current_app.logger.info("no records to transform for " + setSpec)                
                        #update harvest record
                        try:
                            self.write_harvest(job_ticket_id, harvestdate, setSpec, 
                                repository_name, repo_short_name, totalTransformCount, harvest_collection_name, mongo_db, jobname, transform_successful)
                        except Exception as e:
                            current_app.logger.error("Mongo error writing harvest record for : " +  setSpec, exc_info=True)
                            
                    elif  setSpec == harvestset:
                        current_app.logger.info("begin transforming for " + setSpec + " only")
                        if os.path.exists(harvestDir + opDir + "_oaiwrapped"):
                            if len(fnmatch.filter(os.listdir(harvestDir + opDir + "_oaiwrapped"), '*.xml')) > 0:
                                current_app.logger.info("begin transforming - strip oai")
                                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/strip_oai_ssio.xsl", harvestDir + opDir + "_oaiwrapped/", harvestDir + opDir])
                                current_app.logger.info("begin transforming - ssio2via")
                                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/" + ssio2viaXsl, harvestDir + opDir, transformDir + opDir])
                                current_app.logger.info("checking for group records")
                                if os.path.exists(os.getenv("JSTOR_LARGERCONTEXT_DIR")):
                                    if len(fnmatch.filter(os.listdir(os.getenv("JSTOR_LARGERCONTEXT_DIR")), '*.xml')) > 0:
                                        for filename in os.listdir(os.getenv("JSTOR_LARGERCONTEXT_DIR")):
                                            shutil.move(os.getenv("JSTOR_LARGERCONTEXT_DIR") + "/" + filename, transformDir + opDir + "/"  + setSpec + "_" + filename)
                                current_app.logger.info("begin transforming - via2hollis")
                                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/via2hollis.xsl", transformDir + opDir, transformDir + opDir + "_hollis"])
                                current_app.logger.info("done transforming for " + setSpec + " only")

                                for filename in os.listdir(transformDir + opDir):
                                    status = "add_update"
                                    try:
                                        if os.path.getsize(transformDir + opDir + "/" + filename) < 100: # must be a delete or drop if this small, else junk
                                            current_app.logger.info("Moving deletes and drops")
                                            with open(transformDir + opDir + "/" + filename) as input:
                                                for line in input:
                                                    matchDel = deleteRecordId.match(line)
                                                    matchDrop = dropRecordId.match(line) 
                                                    if matchDel:
                                                        shutil.move(transformDir + opDir + "/" + filename, os.getenv("JSTOR_DELETES_DIR") + "/" + filename)
                                                        os.remove(transformDir + opDir + "_hollis/" + filename)
                                                        status = "delete"
                                                    elif matchDrop:
                                                        shutil.move(transformDir + opDir + "/" + filename, os.getenv("JSTOR_DROPS_DIR") + "/" + filename)
                                                        os.remove(transformDir + opDir + "_hollis/" + filename)
                                                        status = "drop"
                                                    else:
                                                        current_app.logger.info("No useful data, but not a drop or delete: " + filename)                                    
                                        identifier = filename[:-4]
                                        totalTransformCount = totalTransformCount + 1
                                        #write/update record
                                        try:
                                            success = True
                                            self.write_record(job_ticket_id, identifier, harvestdate, setSpec, repository_name, repo_short_name, 
                                                status, record_collection_name, success, mongo_db)
                                        except Exception as e:
                                            current_app.logger.error("Mongo error writing " + setSpec + " record: " +  identifier, exc_info=True)
                                            transform_successful = False
                                    except Exception as err:
                                        transform_successful = False
                                        current_app.logger.error("VIA/SSIO transform error for id " + identifier, exc_info=True)
                                        #log error to mongo
                                        status = "add_update"
                                        success = False
                                        try:
                                            self.write_record(job_ticket_id, identifier, harvestdate, setSpec, repository_name, repo_short_name, 
                                                status, record_collection_name, success, mongo_db, err)
                                        except Exception as e:
                                            current_app.logger.error(e)
                                            current_app.logger.error("Mongo error writing " + setSpec + " record: " +  identifier, exc_info=True)
                        else:
                            current_app.logger.info("no records to transform for " + setSpec) 
                        #update harvest record
                        try:
                            self.write_harvest(job_ticket_id, harvestdate, setSpec, 
                                repository_name, repo_short_name, totalTransformCount, harvest_collection_name, mongo_db, jobname, transform_successful)
                        except Exception as e:
                            current_app.logger.error("Mongo error writing harvest record for : " +  setSpec, exc_info=True)

            if jobname == 'aspace' and jobname == job["jobName"]:
                harvestdate = datetime.today().strftime('%Y-%m-%d')     
                totalTransformCount = 0
                transform_successful = True      

                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/strip_oai_aspace.xsl", harvestDir + "aspace", transformDir + "aspace_stripwrapper"])
                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/aspace2valid.xsl", transformDir + "aspace_stripwrapper", transformDir + "aspace_valid"])
                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/aspace2oasis.xsl", transformDir + "aspace_valid", transformDir + "aspace_harvard"])
                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/ead2hollis_part1.xsl", transformDir + "aspace_harvard", transformDir + "aspace_hollis_part1"])
                subprocess.call(["java", props, "-cp", "lib/DLESETools.jar:lib/saxon9he-xslt-2-support.jar", "org.dlese.dpc.commands.RunXSLTransform", "xslt/ead2hollis_part2.xsl", transformDir + "aspace_hollis_part1", transformDir + "aspace_hollis_part2"])

                for filename in os.listdir(transformDir + "aspace_harvard"):
                    try:
                        identifier = filename[:-4]
                        totalTransformCount = totalTransformCount + 1
                        #write/update record
                        try:
                            status = "add_update"
                            success = True
                            self.write_record(job_ticket_id, identifier, harvestdate, setSpec, repository_name, repo_short_name, 
                                status, record_collection_name, success, mongo_db)
                        except Exception as e:
                            current_app.logger.error("Mongo error writing " + setSpec + " record: " +  identifier, exc_info=True)
                            transform_successful = False
                    except Exception as err:
                        transform_successful = False
                        current_app.logger.error("VIA/SSIO transform error for id " + identifier, exc_info=True)
                        #log error to mongo
                        status = "add_update"
                        success = False
                        try:
                            self.write_record(job_ticket_id, identifier, harvestdate, setSpec, repository_name, repo_short_name, 
                                status, record_collection_name, success, mongo_db, err)
                        except Exception as e:
                            current_app.logger.error("Mongo error writing " + setSpec + " record: " +  identifier, exc_info=True)
                    #update harvest record

                #update harvest record
                try:
                    self.write_harvest(job_ticket_id, harvestdate, "0000",
                        "aspace", "ASP", totalTransformCount, harvest_collection_name, mongo_db, jobname, transform_successful)
                except Exception as e:
                    current_app.logger.error("Mongo error writing harvest record for: aspace", exc_info=True)

        if (mongo_client is not None):            
            mongo_client.close()

    def write_harvest(self, harvest_id, harvest_date, repository_id, repository_name, repo_short_name, 
            total_harvested, collection_name, mongo_db, jobname, success):
        if mongo_db == None:
            current_app.logger.info("Error: mongo db not instantiated")
            return
        try:
            if harvest_date == None: #set harvest date to today if harvest date is None
                harvest_date = datetime.today().strftime('%Y-%m-%d') 
            harvest_date_obj = datetime.strptime(harvest_date, "%Y-%m-%d")
            last_update = datetime.now()
            harvest_record = { "id": harvest_id, "last_update": last_update, "harvest_date": harvest_date_obj, 
                "repository_id": repository_id, "repository_name": repository_name, "repo_short_name": repo_short_name, 
                "total_transformed_count": total_harvested, "jobname": jobname, "success": success }
            harvest_collection = mongo_db[collection_name]
            harvest_collection.insert_one(harvest_record)
            current_app.logger.info(repository_name + " harvest for " + harvest_date + " written to mongo ")
        except Exception as err:
            current_app.logger.info("Error: unable to connect to mongodb", exc_info=True)
        return

    def write_record(self, harvest_id, record_id, harvest_date, repository_id, repository_name, repo_short_name, 
            status, collection_name, success, mongo_db, error=None):
        err_msg = ""
        if error != None:
            err_msg = error
        if mongo_db == None:
            current_app.logger.info("Error: mongo db not instantiated")
            return
        try:
            if harvest_date == None: #set harvest date to today if harvest date is None
                harvest_date = datetime.today().strftime('%Y-%m-%d')  
            harvest_date_obj = datetime.strptime(harvest_date, "%Y-%m-%d")
            last_update = datetime.now()
            harvest_record = { "harvest_id": harvest_id, "last_update": last_update, "harvest_date": harvest_date_obj, "record_id": record_id, 
                "repository_id": repository_id, "repository_name": repository_name, "repo_short_name": repo_short_name, 
                "status": status, "success": success, "error": err_msg }
            record_collection = mongo_db[collection_name]
            record_collection.insert_one(harvest_record)
            #record_collection.update_one(query, harvest_record, upsert=True)
            current_app.logger.info("record " + str(record_id) + " of repo " + str(repository_id) + " written to mongo ")
        except Exception as err:
            current_app.logger.info("Error: unable to connect to mongodb", exc_info=True)
        return

    def load_repositories(self):
        repositories = {}
        try:
            mongo_url = os.environ.get('MONGO_URL')
            mongo_dbname = os.environ.get('MONGO_DBNAME')
            repository_collection_name = os.environ.get('REPOSITORY_COLLECTION', 'jstor_repositories')
            mongo_url = os.environ.get('MONGO_URL')
            mongo_dbname = os.environ.get('MONGO_DBNAME')
            mongo_client = MongoClient(mongo_url, maxPoolSize=1)

            mongo_db = mongo_client[mongo_dbname]
            repository_collection = mongo_db[repository_collection_name]
            repos = repository_collection.find({})
            for r in repos:
                k = r["_id"]
                v = { "displayname": r["displayname"], "shortname": r["shortname"] }
                repositories[k] = v 
            mongo_client.close()
            return repositories
        except Exception as err:
            current_app.logger.info("Error: unable to load repository table from mongodb", exc_info=True)
            return repositories

    #add more sophisticated healthchecking later
    def healthcheck(self):
        hc = "OK"
        return hc

    def revert_task(self, job_ticket_id, task_name):
        return True
