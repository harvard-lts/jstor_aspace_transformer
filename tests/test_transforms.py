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
    #display records (8001654780)
    assert doc.xpath("//surrogate/coordinates/@altitude")[0] == "2776.7"
    assert doc.xpath("//surrogate/coordinates/latitude/@decimal")[0] == "36.6425966666667"
    assert doc.xpath("//surrogate/coordinates/longitude/@decimal")[0] == "71.45956"
    #location (8001654780)
    assert doc.xpath("//location/coordinates/latitude/@degree")[0] == "36"
    assert doc.xpath("//location/coordinates/longitude/@degree")[0] == "71"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001306196_via.xml", "-s:" "./tests/data/8001306196_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc2 = ET.parse("./tests/data/temp/8001306196_via.xml")
    #topic (8001306196)
    assert doc2.xpath("//topic[coordinates]/coordinates/latitude/@minute")[0] == "2"
    assert doc2.xpath("//topic[coordinates]/coordinates/longitude/@direction")[0] == "E"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001694596_via.xml", "-s:" "./tests/data/8001694596_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc3 = ET.parse("./tests/data/temp/8001694596_via.xml")
    #placeName (8001694596)
    assert doc3.xpath("//placeName[coordinates]/coordinates/latitude/@decimal")[0] == "31.8167"
    assert doc3.xpath("//placeName[coordinates]/coordinates/longitude/@degree")[0] == "8"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001694086_via.xml", "-s:" "./tests/data/8001694086_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc4 = ET.parse("./tests/data/temp/8001694086_via.xml")    
    #placeOfPublication (8001694086)
    assert doc4.xpath("//placeOfProduction[coordinates]/coordinates/latitude/@decimal")[0] == "21.0"
    assert doc4.xpath("//placeOfProduction[coordinates]/coordinates/longitude/@degree")[0] == "84"

    for i in os.listdir("./tests/data/temp"):
        print(i)
        os.remove("./tests/data/temp/" + i)
    os.rmdir("./tests/data/temp")    
    

def test_alternativeName():   
    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp")    
     
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/S39796_via.xml", "-s:" "./tests/data/S39796_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/S39796_via.xml")
    #Agents/Agent (S39796)
    assert doc.xpath("/viaRecord/work/creator/alternativeName")[0].text == "Borromino, Francesco"
     
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/W20012560_via.xml", "-s:" "./tests/data/W20012560_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/W20012560_via.xml")
    #Subjects/Subject (W20012560)
    assert doc.xpath("/viaRecord/work/associatedName/alternativeName")[0].text == "Anthony, Susan Brownell"
     
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/19344468_via.xml", "-s:" "./tests/data/19344468_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/19344468_via.xml")
    #Agents/Agent + Photographer (19344468)
    assert doc.xpath("/viaRecord/work/surrogate/creator/alternativeName")[0].text == "Alex S. MacLean"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001012729_via.xml", "-s:" "./tests/data/8001012729_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/8001012729_via.xml")
    #Locations/Repository (8001012729)
    assert doc.xpath("/viaRecord/work/repository/alternativeName")[0].text == "Muzeum Narodowe w Krakowie"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/S59783_via.xml", "-s:" "./tests/data/S59783_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/S59783_via.xml")
    #Locations/PrivateOwner (S59783)
    assert doc.xpath("/viaRecord/work/creator[nameElement='Church, Frederick Edwin']/alternativeName")[0].text == "Church, Frederic Edwin"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8000654865_via.xml", "-s:" "./tests/data/8000654865_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/8000654865_via.xml")
    #Image Subject (8000654865)
    #assert doc.xpath("/viaRecord/work/surrogate[componentID='7613106']/topic/alternativeName")[0].text == "Virgin Mary"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001630342_via.xml", "-s:" "./tests/data/8001630342_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/8001630342_via.xml")
    #Image Associated Name (8001630342)
    assert doc.xpath("/viaRecord/work/associatedName/alternativeName")[0].text == "Hugo, Victor Marie"

    for i in os.listdir("./tests/data/temp"):
        print(i)
        os.remove("./tests/data/temp/" + i)
    os.rmdir("./tests/data/temp")    

def test_materialTypes():   
    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp")    
     
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001623662_via.xml", "-s:" "./tests/data/8001623662_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/8001623662_via.xml")
    # (8001623662)
    assert doc.xpath("/viaRecord/work/materials")[0].text == "clay"
    assert doc.xpath("/viaRecord/work/materials")[1].text == "slip (clay)"

    for i in os.listdir("./tests/data/temp"):
        print(i)
        os.remove("./tests/data/temp/" + i)
    os.rmdir("./tests/data/temp")    

def test_startEndYear():   
    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp")    
     
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8000897470_via.xml", "-s:" "./tests/data/8000897470_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/8000897470_via.xml")
    # (8000897470)
    assert doc.xpath("//surrogate[@componentID = '9119955']/structuredDate/beginDate")[0].text == "1960"
    assert doc.xpath("//surrogate[@componentID = '9119955']/structuredDate/endDate")[0].text == "1970"

    for i in os.listdir("./tests/data/temp"):
        print(i)
        os.remove("./tests/data/temp/" + i)
    os.rmdir("./tests/data/temp")    

def test_badGroupItems():   
    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp")    
     
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/G12239_trunc_via.xml", "-s:" "./tests/data/G12239_trunc_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/G12239_trunc_via.xml")
    # Group with bad surr (G12239)
    assert doc.xpath("//surrogate/@componentID")[0] != "4099080'"

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/31013295_via.xml", "-s:" "./tests/data/31013295_ssio.xml", "-xsl:xslt/ssio2via.xsl"])  
    doc = ET.parse("./tests/data/temp/31013295_via.xml")
    # Work with good surr but now image, which is expected (31013295)
    assert doc.xpath("//surrogate/@componentID")[0] == "34013295"
    
    for i in os.listdir("./tests/data/temp"):
        print(i)
        os.remove("./tests/data/temp/" + i)
    os.rmdir("./tests/data/temp")    

def test_deletes():   
    if not os.path.exists("./tests/data/temp"):
        os.makedirs("./tests/data/temp") 
    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8001004229_via_delete.xml", "-s:" "./tests/data/8001004229_ssio_delete.xml", "-xsl:xslt/ssio2via.xsl"])  
    assert os.path.isfile("./tests/data/temp/8001004229_via_delete.xml") == False

    subprocess.call(["java", "-jar", "lib/saxon9he-xslt-2-support.jar", "-o:" "./tests/data/temp/8000483808_via_delete.xml", "-s:" "./tests/data/8000483808_ssio_delete.xml.xml", "-xsl:xslt/ssio2via.xsl"]) 
    assert os.path.isfile("./tests/data/temp/8000483808_via_delete.xml") == False  


    #TO DO - check the actual delete output
    #doc = ET.parse("/tmp/JSTORFORUM/DELETES/8001004229.xml")
    #assert doc.xpath("//deleteRecordId")[0] == "8001004229"

#def test_ead():
#    ead_ns = {'ead': 'urn:isbn:1-931666-22-9'}