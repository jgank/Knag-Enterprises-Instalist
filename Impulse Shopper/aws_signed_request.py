# -*- coding: utf-8 -*-

#!/usr/bin/python

import time
import urllib
import base64
import hmac
import hashlib
import requests
import xml.etree.ElementTree as ET
from xml.etree import ElementTree as et
import codecs
import xml.etree.cElementTree as EF


def aws_signed_request(region, params, public_key, private_key, associate_tag=None, version='2011-08-01'):
    
    # some paramters
    method = 'GET'
    host = 'webservices.amazon.' + region
    uri = '/onca/xml'
    
    # additional parameters
    params['Service'] = 'AWSECommerceService'
    params['AWSAccessKeyId'] = public_key
    params['Timestamp'] = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    params['Version'] = version
    if associate_tag:
        params['AssociateTag'] = associate_tag
    
    # create the canonicalized query
    canonicalized_query = [urllib.quote(param).replace('%7E', '~') + '=' + urllib.quote(params[param]).replace('%7E', '~')
                            for param in sorted(params.keys())]
    canonicalized_query = '&'.join(canonicalized_query)
    
    # create the string to sign
    string_to_sign = method + '\n' + host + '\n' + uri + '\n' + canonicalized_query;
    #print string_to_sign
    
    # calculate HMAC with SHA256 and base64-encoding
    signature = base64.b64encode(hmac.new(key=private_key, msg=string_to_sign, digestmod=hashlib.sha256).digest())
    
    # encode the signature for the request
    signature = urllib.quote(signature).replace('%7E', '~')

    #print 'http://' + host + uri + '?' + canonicalized_query + '&Signature=' + signature
    return 'http://' + host + uri + '?' + canonicalized_query + '&Signature=' + signature

class XMLCombiner(object):
    def __init__(self, filenames):
        assert len(filenames) > 0, 'No filenames!'
        # save all the roots, in order, to be processed later
        self.roots = [et.parse(f).getroot() for f in filenames]

    def combine(self):
        for r in self.roots[1:]:
            # combine each element with the first one, and update that
            self.combine_element(self.roots[0], r)
        # return the string representation
        return et.tostring(self.roots[0])

    def combine_element(self, one, other):
        """
        This function recursively updates either the text or the children
        of an element if another element is found in `one`, or adds it
        from `other` if not found.
        """
        # Create a mapping from tag name to element, as that's what we are fltering with
        mapping = {el.tag: el for el in one}
        for el in other:
            if len(el) == 0:
                # Not nested
                try:
                    # Update the text
                    mapping[el.tag].text = el.text
                except KeyError:
                    # An element with this name is not in the mapping
                    mapping[el.tag] = el
                    # Add it
                    one.append(el)
            else:
                try:
                    # Recursively process the element, and update it in the same way
                    self.combine_element(mapping[el.tag], el)
                except KeyError:
                    # Not in the mapping
                    mapping[el.tag] = el
                    # Just add it
                    one.append(el)


p = {} 
p['Operation'] = 'ItemSearch'
p['BrowseNode'] = '468642'
p['SearchIndex'] = 'VideoGames'
p['Sort'] = 'salesrank'
p['ItemPage'] = str(1) 

cat =["Electronics", "GourmetFood", "Industrial", "Jewelry", "KindleStore", "Kitchen", "LawnGarden", "Magazines", "Miscellaneous", "MobileApps", "MP3Downloads", "Music", "MusicalInstruments", "OfficeProducts", "OutdoorLiving", "PCHardware", "PetSupplies", "Photo", "Software", "SportingGoods", "Tools", "Toys", "VHS", "Video", "VideoGames", "Watches", "Wireless", "WirelessAccessories"]

catNum =["172282", "3580501", "228239", "3880591", "133141011", "284507", "2972638011", "599872", "10304191", "2350149011", "195211011", "301668", "11091801", "1084128", "286168", "541966", "12923371", "502394", "409488", "3375251", "468240", "165793011", "404272", "130", "468642", "377110011", "508494", "13900851"]

#p['ResponseGroup'] = 'MostWishedFor'
#p['ResponseGroup'] = 'OfferSummary,Images'
#p['ItemId'] = 'B00HBQWGXK,B006LSZECO,B00HDMMISA,B000FC2L1O,B0020BUWX2,B00BAXFECK,B00HQ2N52K,B00DPM7TIG,B00INIYH78,B000FC2L28'
#p['IdType'] = 'ASIN'
atag = 'jdt03-20'
pukey = 'AKIAI2MKYF4J4Q2JH4WA'
prkey = 'Oahq9neCrb2U0yNt9fyzHFNrn+eOU38KRDEgXSO4'





rootM = EF.Element("root")
for catInd in range(len(cat)):
    p['SearchIndex'] = cat[catInd]
    p['BrowseNode'] = catNum[catInd]
    p['Operation'] = 'ItemSearch'
    

    a = []
    acount = 0
    acountt = 0
    for q in range(1,11):
        p['ItemPage'] = str(q)
        r = requests.get(aws_signed_request('com', p, pukey, prkey, atag))
        time.sleep(1)

        #print r.url
        ju = str(r.text.encode('utf8', 'replace'))
        root = ET.fromstring(ju)
        acount = 0
        for i in root:
                for j in i:
                    if "Item" in j.tag:
                        for k in j:
                            if "ASIN" in k.tag and "ParentASIN" not in k.tag:
                                acount += 1
                                acountt += 1
                                a.append(k.text)

    a = list(set(a))
    print a
    print len(a)
    p['Operation'] = 'ItemLookup'
    p['ResponseGroup'] = 'Large'
    del p['SearchIndex']
    filenames = [] 

    f = open('combine.xml', 'w')
    fd = 0
    root1 = EF.Element("root")
    tson = []

    for i in range(len(a)):
        if (i+1) % 5 == 0 or i+1 == len(a):
            fd += 5
            if (i+1) == len(a):
                p['ItemId'] = a[((len(a)/5)-1)*5]
                for las in range(((len(a)/5))*5+1,len(a)):
                    p['ItemId'] += ',' + a[las]
            else:
                p['ItemId'] = a[i]+','+a[i-1]+','+a[i-2]+','+a[i-3]+','+a[i-4]
            print p['ItemId']
            r = requests.get(aws_signed_request('com', p, pukey, prkey, atag))

            ju = str(r.text.encode('utf8', 'replace'))
            print ju
            root = ET.fromstring(ju)

            for i in root:
                    for j in i:
                        if "Item" in j.tag:
                            doc = EF.SubElement(root1, "Item")
                            docM = EF.SubElement(rootM, "Item")
                            for k in j:
                                if "ASIN" in k.tag and "ParentASIN" not in k.tag:
                                    field1 = EF.SubElement(doc, "ASIN")
                                    field1.text = k.text
                                    field1 = EF.SubElement(docM, "ASIN")
                                    field1.text = k.text
                                if "LargeImage" in k.tag:
                                    for li in k:
                                        if "URL" in li.tag:
                                            field1 = EF.SubElement(doc, "LargeImage")
                                            field1.text = li.text
                                            field1 = EF.SubElement(docM, "LargeImage")
                                            field1.text = li.text
                                elif "ImageSet" in k.tag:
                                    for li in k:
                                        if "SwatchImage" in li.tag:
                                            for si in li:
                                                if "LargeImage" in si.tag:
                                                    for lur in si:
                                                        if "URL" in lur.tag:
                                                            field1 = EF.SubElement(doc, "LargeImage")
                                                            field1.text = lur.text
                                                            field2 = EF.SubElement(docM, "LargeImage")
                                                            field2.text = lur.text
                                                        if "Height" in lur.tag:
                                                            field1.set("Height", lur.text)
                                                            field2.set("Height", lur.text)
                                                        if "Width" in lur.tag:
                                                            field1.set("Width", lur.text)
                                                            field2.set("Width", lur.text)
                                if "SmallImage" in k.tag:
                                    for li in k:
                                        if "URL" in li.tag:
                                            field1 = EF.SubElement(doc, "SmallImage")
                                            field1.text = li.text
                                            field2 = EF.SubElement(docM, "SmallImage")
                                            field2.text = li.text
                                        if "Height" in li.tag:
                                            field1.set("Height", li.text)
                                            field2.set("Height", li.text)
                                        if "Width" in li.tag:
                                            field1.set("Width", li.text)
                                            field2.set("Width", li.text)
                                if "DetailPageURL" in str(k.tag):
                                    field1 = EF.SubElement(doc, "DetailPageURL")
                                    field1.text = k.text
                                    field1 = EF.SubElement(docM, "DetailPageURL")
                                    field1.text = k.text
                                """
                                if "EditorialReviews" in k.tag:
                                    for ia in k:
                                        if "EditorialReview" in ia.tag:
                                            for lp in ia:
                                                if "Content" in lp.tag:
                                                    field1 = EF.SubElement(doc, "Content")
                                                    field1.text = lp.text
                                                    field1 = EF.SubElement(docM, "Content")
                                                    field1.text = lp.text
                                """
                                if "ItemAttributes" in k.tag:
                                    for ia in k:
                                        if "Title" in ia.tag:
                                            field1 = EF.SubElement(doc, "Title")
                                            field1.text = ia.text
                                            field1 = EF.SubElement(docM, "Title")
                                            field1.text = ia.text
                                        if "ListPrice" in ia.tag:
                                            for lp in ia:
                                                if "FormattedPrice" in lp.tag:
                                                    field1 = EF.SubElement(doc, "FormattedPrice")
                                                    field1.text = lp.text
                                                    field1 = EF.SubElement(docM, "FormattedPrice")
                                                    field1.text = lp.text
                                        if "ProductGroup" in ia.tag:
                                            field1 = EF.SubElement(doc, "ProductGroup")
                                            field1.text = ia.text
                                            field1 = EF.SubElement(docM, "ProductGroup")
                                            field1.text = ia.text

            time.sleep(1)
            #print r.url
            ju = str(r.text.encode('utf8', 'replace'))
            #print ju
            f.write(str(ju))

    tree1 = EF.ElementTree(root1)
    #tree1.write(cat[catInd] + ".xml")
    tree1 = EF.ElementTree(rootM)
    tree1.write("combined.xml")
    #tree1.write("/Users/jgank/Dropbox/Impulse Shopper/Impulse Shopper/combined.xml")

    print fd
    f.close()
