# -*- coding: utf-8 -*-

#!/usr/bin/python

import re
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
#import bitly_api

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

mainItems = {"Electronics":"172282",
"Books": "1000",
"GourmetFood":"3580501",
"Industrial":"228239",
"Jewelry":"3880591",
"KindleStore":"133141011",
"Kitchen":"284507",
"LawnGarden":"2972638011",
"Magazines":"599872",
"Miscellaneous":"10304191",
"MobileApps":"2350149011",
"MP3Downloads":"195211011",
"Music":"301668",
"MusicalInstruments":"11091801",
"OfficeProducts":"1084128",
"OutdoorLiving":"286168",
"PCHardware":"541966",
"PetSupplies":"12923371",
"Photo":"502394",
"Software":"409488",
"SportingGoods":"3375251",
"Tools":"468240",
"Toys":"165793011",
"VHS":"404272",
"Video":"130",
"VideoGames":"468642",
"Watches":"377110011",
"Wireless":"508494",
"WirelessAccessories":"13900851"}
category = {"165993011": "Action & Toy Figures",
"166057011": "Arts & Crafts",
"196601011": "Baby & Toddler Toys",
"166224011": "Battle Tops",
"166310011": "Beauty & Fashion",
"256994011": "Bikes, Skates & Ride-Ons",
"166092011": "Building & Construction Toys",
"166508011": "Die-Cast & Toy Vehicles",
"166118011": "Dolls & Accessories",
"166309011": "Dress Up Games & Pretend Play",
"166316011": "Dressing Up & Costumes",
"166164011": "Electronics for Kids",
"166220011": "Games",
"3226142011": "Grown-Ups",
"276729011": "Hobbies",
"166210011": "Kids' Furniture & Room Decor",
"166269011": "Learning & Education",
"166326011": "Musical Instruments",
"166027011": "Novelty & Gag Toys",
"1266203011": "Party Supplies",
"166333011": "Puppets & Puppet Theaters",
"166359011": "Puzzles",
"166420011": "Sports & Outdoor Play",
"166461011": "Stuffed Animals & Plush",


"2474937011": "Mens Accessories",
"3455821": "Athletic clothing, Men's athletic clothing, Men's clothing",
"1045684": "Blazers, Suits , Sport coats, Men's clothing",
"1045830": "Jackets, Men's outerwear",
"1258644011": "Men's Hooded Fashion Sweatshirts",
"1045564": "Men's jeans, Men's clothing",
"1045558": "Men's pants, Jeans, Pants, Slacks, Men's clothing",
"1044440": "Men's shirts, Polos, Dress shirts, Henleys, Turtlenecks",
"1045560": "Men's shorts, Men's clothing",
"3455861": "Men's sleepwear, Men's pajamas, Men's robes",
"1045708": "Men's socks, Dress socks, Athletic socks, Crew socks",
"1044442": "Men's sweaters, Polos, Vests, Cardigans, Turtlenecks",
"1045706": "Men's underwear, Thongs, Boxers, Briefs, Jock straps",
"1046670": "Men's Swim",
"2476517011": "Men's Tops & Tees",

"3456051": "Athletic clothing, Women's athletic clothing, Women's clothing",
"1045112": "Blazers, Suit jackets, Women's clothing",
"5417873011": "Clothing Sets",
"1045024": "Dresses",
"1044454": "Dresses, Denim, Intimate Apparel & More",
"14333511": "Intimates",
"1048188": "Jeans, Skinny jeans, Maternity jeans, Bootcut jeans, Women's clothing",
"1285228011": "Maternity",
"5605243011": "Plus",
"1045022": "Skirts, Women's clothing, Pencil skirts, Mini skirts, Long skirts",
"2376202011": "Woman's Sleep & Lounge",
"1046622": "Woman's Swim",
"2368343011": "Women's Tops & Tees",
"1288627011": "Women's Button-Down Shirts",
"1044646": "Women's coats, Leather coats, Trench coats, Fleeces, Women's outerwear",
"1258603011": "Women's Hooded Fashion Sweatshirts",
"1044886": "Women's hosiery, Socks, Hose, Tights",
"2381887011": "Women's Jumpsuits & Rompers",
"1258967011": "Women's Leggings Pants",
"1048184": "Women's pants, Jeans, Chinos, Overalls, Women's clothing",
"1048186": "Women's shorts, Skorts, Culottes, Bermuda shorts, Women's clothing",
"1044460": "Women's suits, Women's suit separates, Women's blazers, Skirt suits, Suit jackets",
"1044456": "Women's sweaters, Vests, Cardigans, Ponchos, Turtlenecks",


"172282":"Electronics",
"1000": "Books",
"3580501": "GourmetFood",
"228239": "Industrial",
"3880591": "Jewelry",
"133141011": "KindleStore",
"284507": "Kitchen",
"2972638011": "LawnGarden",
"599872": "Magazines",
"10304191": "Miscellaneous",
"2350149011": "MobileApps",
"195211011": "MP3Downloads",
"301668": "Music",
"11091801": "MusicalInstruments",
"1084128": "OfficeProducts",
"286168": "OutdoorLiving",
"541966": "PCHardware",
"12923371": "PetSupplies",
"502394": "Photo",
"409488": "Software",
"3375251": "SportingGoods",
"468240": "Tools",
"165793011": "Toys",
"404272": "VHS",
"130": "Video",
"468642": "VideoGames",
"377110011": "Watches",
"508494": "Wireless",
"13900851":"WirelessAccessories"}

apparelItems = {"Accessories": "2474937011",
"Athletic clothing, Men's athletic clothing, Men's clothing": "3455821",
"Blazers, Suits , Sport coats, Men's clothing": "1045684",
"Jackets, Men's outerwear": "1045830",
"Men's Hooded Fashion Sweatshirts": "1258644011",
"Men's jeans, Men's clothing": "1045564",
"Men's pants, Jeans, Pants, Slacks, Men's clothing": "1045558",
"Men's shirts, Polos, Dress shirts, Henleys, Turtlenecks": "1044440",
"Men's shorts, Men's clothing": "1045560",
"Men's sleepwear, Men's pajamas, Men's robes": "3455861",
"Men's socks, Dress socks, Athletic socks, Crew socks": "1045708",
"Men's sweaters, Polos, Vests, Cardigans, Turtlenecks": "1044442",
"Men's underwear, Thongs, Boxers, Briefs, Jock straps": "1045706",
"Men's Swim": "1046670",
"Men's Tops & Tees": "2476517011",

"Athletic clothing, Women's athletic clothing, Women's clothing": "3456051",
"Blazers, Suit jackets, Women's clothing": "1045112",
"Clothing Sets": "5417873011",
"Dresses": "1045024",
"Dresses, Denim, Intimate Apparel & More": "1044454",
"Intimates": "14333511",
"Jeans, Skinny jeans, Maternity jeans, Bootcut jeans, Women's clothing": "1048188",
"Maternity": "1285228011",
"Plus": "5605243011",
"Skirts, Women's clothing, Pencil skirts, Mini skirts, Long skirts": "1045022",
"Woman's Sleep & Lounge": "2376202011",
"Woman's Swim": "1046622",
"Women's Tops & Tees": "2368343011",
"Women's Button-Down Shirts": "1288627011",
"Women's coats, Leather coats, Trench coats, Fleeces, Women's outerwear": "1044646",
"Women's Hooded Fashion Sweatshirts": "1258603011",
"Women's hosiery, Socks, Hose, Tights": "1044886",
"Women's Jumpsuits & Rompers": "2381887011",
"Women's Leggings Pants": "1258967011",
"Women's pants, Jeans, Chinos, Overalls, Women's clothing": "1048184",
"Women's shorts, Skorts, Culottes, Bermuda shorts, Women's clothing": "1048186",
"Women's suits, Women's suit separates, Women's blazers, Skirt suits, Suit jackets": "1044460",
"Women's sweaters, Vests, Cardigans, Ponchos, Turtlenecks": "1044456"}

apparelGender = {"2474937011": "mens",
"3455821": "mens",
"1045684": "mens",
"1045830": "mens",
"1258644011": "mens",
"1045564": "mens",
"1045558": "mens",
"1044440": "mens",
"1045560": "mens",
"3455861": "mens",
"1045708": "mens",
"1044442": "mens",
"1045706": "mens",
"1046670": "mens",
"2476517011": "mens",
"3456051": "mens",
"1045112": "mens",
"5417873011": "womens",
"1045024": "womens",
"1044454": "womens",
"14333511": "womens",
"1048188": "womens",
"1285228011": "womens",
"5605243011": "womens",
"1045022": "womens",
"2376202011": "womens",
"1046622": "womens",
"2368343011": "womens",
"1288627011": "womens",
"1044646": "womens",
"1258603011": "womens",
"1044886": "womens",
"2381887011": "womens",
"1258967011": "womens",
"1048184": "womens",
"1048186": "womens",
"1044460": "womens",
"1044456": "womens"}

toyItems = {"Action & Toy Figures": "165993011",
"Arts & Crafts": "166057011",
"Baby & Toddler Toys": "196601011",
"Battle Tops": "166224011",
"Beauty & Fashion": "166310011",
"Bikes, Skates & Ride-Ons": "256994011",
"Building & Construction Toys": "166092011",
"Die-Cast & Toy Vehicles": "166508011",
"Dolls & Accessories": "166118011",
"Dress Up Games & Pretend Play": "166309011",
"Dressing Up & Costumes": "166316011",
"Electronics for Kids": "166164011",
"Games": "166220011",
"Grown-Ups": "3226142011",
"Hobbies": "276729011",
"Kids' Furniture & Room Decor": "166210011",
"Learning & Education": "166269011",
"Musical Instruments": "166326011",
"Novelty & Gag Toys": "166027011",
"Party Supplies": "1266203011",
"Puppets & Puppet Theaters": "166333011",
"Puzzles": "166359011",
"Sports & Outdoor Play": "166420011",
"Stuffed Animals & Plush": "166461011"}
toyGender = {"165993011": "boy",
"166057011": "boy",
"196601011": "boy",
"166224011": "boy",
"256994011": "boy",
"166092011": "boy",
"166508011": "boy",
"166309011": "boy",
"166316011": "boy",
"166164011": "boy",
"166220011": "boy",
"3226142011": "boy",
"276729011": "boy",
"166210011": "boy",
"166269011": "boy",
"166326011": "boy",
"166027011": "boy",
"1266203011": "boy",
"166333011": "boy",
"166359011": "boy",
"166420011": "boy",
"166461011": "boy",
"166310011": "girl",
"166118011": "girl"}

fullItems = {"Electronics":"172282",
"Books": "1000",
"GourmetFood":"3580501",
"Industrial":"228239",
"Jewelry":"3880591",
"KindleStore":"133141011",
"Kitchen":"284507",
"LawnGarden":"2972638011",
"Magazines":"599872",
"Miscellaneous":"10304191",
"MobileApps":"2350149011",
"MP3Downloads":"195211011",
"Music":"301668",
"MusicalInstruments":"11091801",
"OfficeProducts":"1084128",
"OutdoorLiving":"286168",
"PCHardware":"541966",
"PetSupplies":"12923371",
"Photo":"502394",
"Software":"409488",
"SportingGoods":"3375251",
"Tools":"468240",
"Toys":"165793011",
"VHS":"404272",
"Video":"130",
"VideoGames":"468642",
"Watches":"377110011",
"Wireless":"508494",
"WirelessAccessories":"13900851",
"Apparel": "2474937011",
"Apparel": "3455821",
"Apparel": "1045684",
"Apparel": "1045830",
"Apparel": "1258644011",
"Apparel": "1045564",
"Apparel": "1045558",
"Apparel": "1044440",
"Apparel": "1045560",
"Apparel": "3455861",
"Apparel": "1045708",
"Apparel": "1044442",
"Apparel": "1045706",
"Apparel": "1046670",
"Apparel": "2476517011",
"Apparel": "3456051",
"Apparel": "1045112",
"Apparel": "5417873011",
"Apparel": "1045024",
"Apparel": "1044454",
"Apparel": "14333511",
"Apparel": "1048188",
"Apparel": "1285228011",
"Apparel": "5605243011",
"Apparel": "1045022",
"Apparel": "2376202011",
"Apparel": "1046622",
"Apparel": "2368343011",
"Apparel": "1288627011",
"Apparel": "1044646",
"Apparel": "1258603011",
"Apparel": "1044886",
"Apparel": "2381887011",
"Apparel": "1258967011",
"Apparel": "1048184",
"Apparel": "1048186",
"Apparel": "1044460",
"Apparel": "1044456",
"Toys": "165993011",
"Toys": "166057011",
"Toys": "196601011",
"Toys": "166224011",
"Toys": "166310011",
"Toys": "256994011",
"Toys": "166092011",
"Toys": "166508011",
"Toys": "166118011",
"Toys": "166309011",
"Toys": "166316011",
"Toys": "166164011",
"Toys": "166220011",
"Toys": "3226142011",
"Toys": "276729011",
"Toys": "166210011",
"Toys": "166269011",
"Toys": "166326011",
"Toys": "166027011",
"Toys": "1266203011",
"Toys": "166333011",
"Toys": "166359011",
"Toys": "166420011",
"Toys": "166461011"}

#p['ResponseGroup'] = 'MostWishedFor'
#p['ResponseGroup'] = 'OfferSummary,Images'
#p['ItemId'] = 'B00HBQWGXK,B006LSZECO,B00HDMMISA,B000FC2L1O,B0020BUWX2,B00BAXFECK,B00HQ2N52K,B00DPM7TIG,B00INIYH78,B000FC2L28'
#p['IdType'] = 'ASIN'
atag = 'jdt03-20'
pukey = 'AKIAI2MKYF4J4Q2JH4WA'
prkey = 'Oahq9neCrb2U0yNt9fyzHFNrn+eOU38KRDEgXSO4'



#bitly = bitly_api.Connection(access_token='ceb45471511fbdaee0e1518a06e6a111928cd4ee')

rootM = EF.Element("root")
#for catInd in range(len(cat)):
for k, dk in fullItems.iteritems():
    p['SearchIndex'] = k
    p['BrowseNode'] = dk
    p['Operation'] = 'ItemSearch'
    
    atag = k
    if atag == 'Apparel':
        atag = apparelGender[dk] + atag
        sex = apparelGender[dk]
    elif atag == 'Toys':
        atag = toyGender[dk] + atag
        sex = toyGender[dk]
    else:
        sex = ''

    atag = 'knag_' + re.sub(r"(\w)([A-Z])", r"\1_\2", atag).lower() + '-20'

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
                                            field2 = EF.SubElement(docM, "LargeImage")
                                            field2.text = li.text
                                        if "Height" in li.tag:
                                            field1.set("Height", li.text)
                                            field2.set("Height", li.text)
                                        if "Width" in li.tag:
                                            field1.set("Width", li.text)
                                            field2.set("Width", li.text)
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
                                    #field1.text = urllib.unquote(k.text)
                                    field1 = EF.SubElement(docM, "DetailPageURL")
                                    field1.text = k.text
                                    #field1.text = urllib.unquote(k.text)
                                    """
                                        data = bitly.shorten(field1.text)
                                        field1 = EF.SubElement(doc, "ShortURL")
                                        field1.text = data['url']
                                        field1 = EF.SubElement(docM, "ShortURL")
                                        field1.text = data['url']
                                        print field1.text
                                        """
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
                    
                        field1 = EF.SubElement(doc, "Sex")
                            field1.text = sex
                            field1 = EF.SubElement(docM, "Sex")
                            field1.text = sex
                            field1 = EF.SubElement(doc, "Category")
                            field1.text = category[dk]
                            field1 = EF.SubElement(docM, "Category")
                            field1.text = category[dk]
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
