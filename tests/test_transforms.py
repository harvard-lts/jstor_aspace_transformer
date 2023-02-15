import subprocess, os
import lxml.etree as ET

def hello_world():
    return "Hello World"

def test_hello_world():
    assert hello_world()  == 'Hello World'

def test_transforms():
    ead_ns = {'ead': 'urn:isbn:1-931666-22-9'}
    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp")
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001654780_via.xml", "-s:" "./tests/data/8001654780_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    #with open("./tests/data/temp/8001654780_via.xml") as f:
    #    geog_coord_xml = f.read()
    doc = ET.parse("./tests/data/temp/8001654780_via.xml")
    recid = doc.xpath("//recordId")[0].text
    assert recid == "8001654780"
