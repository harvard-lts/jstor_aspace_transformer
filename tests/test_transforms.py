import subprocess, os
import lxml.etree as ET

def hello_world():
    return "Hello World"

def test_hello_world():
    assert hello_world()  == 'Hello World'



def test_geog_coordinates():

    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp")    
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001654780_via.xml", "-s:" "./tests/data/8001654780_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/8001654780_via.xml")
    #display records
    assert doc.xpath("//surrogate/coordinates/@altitude")[0] == "2776.7"
    assert doc.xpath("//surrogate/coordinates/latitude/@decimal")[0] == "36.6425966666667"
    assert doc.xpath("//surrogate/coordinates/longitude/@decimal")[0] == "71.45956"
    #location
    assert doc.xpath("//location/coordinates/latitude/@degree")[0] == "36"
    assert doc.xpath("//location/coordinates/longitude/@degree")[0] == "71"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001306196_via.xml", "-s:" "./tests/data/8001306196_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc2 = ET.parse("./tests/data/temp/8001306196_via.xml")
    #topic
    assert doc2.xpath("//topic[coordinates]/coordinates/latitude/@minute")[0] == "2"
    assert doc2.xpath("//topic[coordinates]/coordinates/longitude/@direction")[0] == "E"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001694596_via.xml", "-s:" "./tests/data/8001694596_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc3 = ET.parse("./tests/data/temp/8001694596_via.xml")
    #placeName
    assert doc3.xpath("//placeName[coordinates]/coordinates/latitude/@decimal")[0] == "31.8167"
    assert doc3.xpath("//placeName[coordinates]/coordinates/longitude/@degree")[0] == "8"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001694086_via.xml", "-s:" "./tests/data/8001694086_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc4 = ET.parse("./tests/data/temp/8001694086_via.xml")    
    #placeOfPublication
    assert doc4.xpath("//placeOfProduction[coordinates]/coordinates/latitude/@decimal")[0] == "21.0"
    assert doc4.xpath("//placeOfProduction[coordinates]/coordinates/longitude/@degree")[0] == "84"

    for i in os.listdir("./tests/data/temp"):
        print(i)
        os.remove("./tests/data/temp/" + i)
    os.rmdir("./tests/data/temp")    
    

#def test_ead():
#    ead_ns = {'ead': 'urn:isbn:1-931666-22-9'}