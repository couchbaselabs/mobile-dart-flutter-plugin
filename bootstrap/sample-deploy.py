#!/usr/bin/python3
import sys
import json
import urllib.request
from time import sleep


class WORK():

    cbHost = "localhost"
    cbPort = "8091"
    cbAdminUsername = "Administrator"
    cbAdminPassword = "password"
    sgHostUrl = "127.0.0.1"
    cbBucketName = "message"
    cbScopeName = "chat"
    cbCollectionName = "message"
    sgRbacUser = "syncGatewayUser"
    sgRbacUserPassword = "password"
    sgDbName = "examplechat"
    sgAdminPort = "4985"
    sgDbConfigJsonFile = "sgDb.json"
    sgDbUserList = ["bob","tim"]
    sgHostSecure = "http"
    debug = False

    def __init__(self, file):
        self.readConfigFile(file);
    
    def readConfigFile(self,configFile):
        a = open(configFile, "r" )
        b = json.loads(a.read())
        self.cbHost = b["cb"]["host"]
        self.cbPort = b["cb"]["port"]
        self.cbAdminUsername = b["cb"]["adminUsername"]
        self.cbAdminPassword = b["cb"]["adminPassword"]
        if b["cb"]['hostSecure']:
            self.cbHostSecure = "https"
        else:
            self.cbHostSecure = "http"
        self.sgHostUrl = b["sg"]["hostUrl"]
        self.cbBucketName = b["cb"]["bucketName"]
        self.cbScopeName = b["cb"]["scopeName"]
        self.cbCollectionName = b["cb"]["collectionName"]
        self.sgRbacUser = b["sg"]['rbacUser']
        self.sgRbacUserPassword = b["sg"]['rbacUserPassword']
        self.sgDbName = b["sg"]['dbName']
        self.sgAdminPort = b["sg"]['adminPort']
        self.sgDbConfigJsonFile = b["sg"]['dbConfigJsonFile']
        self.sgDbUserList = b["sg"]['dbUserList']
        if b["sg"]['hostSecure']:
            self.sgHostSecure = "https"
        else:
            self.sgHostSecure = "http"
        self.debug = b['debug']
        a.close()

    def httpGet(self,url='',userName='',password='',retry=0):

        password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        password_mgr.add_password(None, url, userName, password)
        auth_handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)
        urllib.request.install_opener(opener)
        
        try:
            response = urllib.request.urlopen(url)
            if self.debug:
                print("Request URL:", url)
                print("Response Code:", response.getcode())
                print("Response Headers:")
                for header in response.getheaders():
                    print(header[0], ":", header[1])    

            return self.jsonChecker(response.read())
        except urllib.error.HTTPError as e:
            print("HTTP Error:", e.code, e.reason)
            return False
        except urllib.error.URLError as e:
            print("URL Error:", e.reason)
            return False
        except Exception as e:
            if e:
                if hasattr(e, 'code'):
                    print("Error: HTTP GET: " + str(e.code))
            if retry == 3:
                if self.debug == True:
                    print("DEBUG: Tried 3 times could not execute: GET")				
                if e:
                    if hasattr(e, 'code'):
                        if self.debug == True:
                            print("DEBUG: HTTP CODE ON: GET - "+ str(e.code))	
                        return e.code
                    else:
                        return False
            sleep(0.02)

            return self.httpGet(url,userName,password , retry+1)
        
    def httpPutJson(self, url='', userName='', password='', data={}, retry=0):

        if self.jsonChecker(data):
            json_data = data
        else:
            json_data = json.dumps(data).encode('utf-8')  # Convert dictionary to JSON and encode

        password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        password_mgr.add_password(None, url, userName, password)
        auth_handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)
        urllib.request.install_opener(opener)

        try:
            req = urllib.request.Request(url, data=json_data, headers={'Content-Type': 'application/json'}, method='PUT')
            with urllib.request.urlopen(req) as response:
                if self.debug:
                    print("Request URL:", url)
                    print("Response Code:", response.getcode())
                    print("Response Headers:")
                    for header in response.getheaders():
                        print(header[0], ":", header[1])
                    print("Response Code:", response.getcode())
                return self.jsonChecker(response.read())
        except urllib.error.HTTPError as e:
            print("HTTP Error:", e.code)
        except urllib.error.URLError as e:
            print("URL Error:", e.reason)
        except Exception as e:
            if retry == 3:
                if self.debug == True:
                    print("DEBUG: Tried 3 times could not execute: PUT")				
                if e and hasattr(e, 'code'):
                    if self.debug == True:
                        print("DEBUG: HTTP CODE ON: PUT - "+ str(e.code))	
                    return e.code
                else:
                    return False
            sleep(0.02)
            return self.httpPut(url, userName, password, data, retry+1)

    
    def httpPut(self, url='', userName='', password='', data={}, retry=0):
        form_data = '&'.join([f"{key}={value}" for key, value in data.items()]).encode('utf-8')  # Convert dictionary to form-encoded data
        
        password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        password_mgr.add_password(None, url, userName, password)
        auth_handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)
        urllib.request.install_opener(opener)

        try:
            req = urllib.request.Request(url, data=form_data, headers={'Content-Type': 'application/x-www-form-urlencoded'}, method='PUT')
            with urllib.request.urlopen(req) as response:
                if self.debug:
                    print("Request URL:", url)
                    print("Response Code:", response.getcode())
                    print("Response Headers:")
                    for header in response.getheaders():
                        print(header[0], ":", header[1])
                print("Response Code:", response.getcode())
                return self.jsonChecker(response.read())
        except urllib.error.HTTPError as e:
            print("HTTP Error:", e.code)
        except urllib.error.URLError as e:
            print("URL Error:", e.reason)
        except Exception as e:
            if retry == 3:
                if self.debug == True:
                    print("DEBUG: Tried 3 times could not execute: PUT")				
                if e and hasattr(e, 'code'):
                    if self.debug == True:
                        print("DEBUG: HTTP CODE ON: PUT - "+ str(e.code))	
                    return e.code
                else:
                    return False
            sleep(0.02)
            return self.httpPut(url, userName, password, data, retry+1)

    def httpPost(self,url='',userName='',password='',data={},retry=0):

        form_data = '&'.join([f"{key}={value}" for key, value in data.items()]).encode('utf-8')  # Convert dictionary to form-encoded data

        password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
        password_mgr.add_password(None, url, userName, password)
        auth_handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)
        urllib.request.install_opener(opener)

        try:
            req = urllib.request.Request(url, data=form_data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
            with urllib.request.urlopen(req) as response:
                if self.debug:
                    print("Request URL:", url)
                    print("Response Code:", response.getcode())
                    print("Response Headers:")
                    for header in response.getheaders():
                        print(header[0], ":", header[1])  
                print("Response Code:", response.getcode())
                return self.jsonChecker(response.read())
        except urllib.error.HTTPError as e:
            print("HTTP Error:", e.code, e.reason)
        except urllib.error.URLError as e:
            print("URL Error:", e.reason)
        except Exception as e:
            if e:
                if hasattr(e, 'code'):
                    print("Error: HTTP POST: " + str(e.code))
            if retry == 3:
                if self.debug == True:
                    print("DEBUG: Tried 3 times could not execute: POST")				
                if e:
                    if hasattr(e, 'code'):
                        if self.debug == True:
                            print("DEBUG: HTTP CODE ON: POST - "+ str(e.code))	
                        return e.code
                    else:
                        return False
            sleep(0.02)
            return self.httpPost(url,userName,password,data,retry+1)

    def httpDelete(self,url='',retry=0):
        try:
            opener = urllib.build_opener(urllib.HTTPHandler)
            req = urllib.Request(url, None)
            req.get_method = lambda: 'DELETE'  # creates the delete method
            return self.jsonChecker(urllib.urlopen(req))
        except Exception as e:
            if e:
                if hasattr(e, 'code'):
                    print("Error: HTTP DELETE: " + str(e.code))
            if retry == 3:
                if self.debug == True:
                    print("DEBUG: Tried 3 times could not execute: DELETE")				
                if e:
                    if hasattr(e, 'code'):
                        if self.debug == True:
                            print("DEBUG: HTTP CODE ON: DELETE - "+ str(e.code))
                        return e.code
                    else:
                        return False
            #sleep(0.05)
            return self.httpDelete(url,retry+1)

    def jsonChecker(self, data=''):
        #checks if its good json and if so return back Python Dictionary
        try:
            checkedData = json.loads(data)
            return checkedData
        except Exception as e:
            return False
        
    def makeCbBucket(self):

        print("CB URL is:", "http://"+ self.cbHost+":"+self.cbPort)
        ### MAKE BUCKET
        urlBucket = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/pools/default/buckets/"+self.cbBucketName
        bucketExists = {}
        try:         
            bucketExists = self.httpGet(urlBucket,self.cbAdminUsername,self.cbAdminPassword)
        except Exception as e:
            print("No - Bucket Name: ",self.cbBucketName)
        
        if isinstance(bucketExists, dict) and "name" in bucketExists and bucketExists["name"] == self.cbBucketName:
                print("Yes - Bucket Name: ",self.cbBucketName)
        else:
            #make the bucket
            print("Making Bucket Name: ",self.cbBucketName)
            urlBucketPost = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/pools/default/buckets"
            bucketConfig = { "name":self.cbBucketName, "ramQuota":100 , "bucketType":"couchbase", "storageBackend":"couchstore","maxTTL":0}
            self.httpPost(urlBucketPost,self.cbAdminUsername,self.cbAdminPassword,bucketConfig)

        ### MAKE SCOPE
        urlBucketScope = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/pools/default/buckets/"+self.cbBucketName+"/scopes"
        scopeExists = None
        try:         
            scopeExists = self.httpGet(urlBucketScope,self.cbAdminUsername,self.cbAdminPassword)
        except Exception as e:
            print("No - Scope Name: ",self.cbScopeName)

        foundScopes = False
        foundCollectionList = []

        for x in scopeExists["scopes"]:
            if x["name"] == self.cbScopeName:
                foundScopes = True
                for y in x["collections"]:
                    if y["name"] == self.cbCollectionName:
                        foundCollectionList.append(self.cbCollectionName)

        if foundScopes == True:
            print("Yes - Scope Name: ",self.cbScopeName)
        else:
            #make the scope
            print("Making Scope Name: ",self.cbScopeName)
            urlBucketScopePost = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/pools/default/buckets/"+self.cbBucketName+"/scopes"
            scopeConfig = { "name":self.cbScopeName}
            self.httpPost(urlBucketScopePost,self.cbAdminUsername,self.cbAdminPassword,scopeConfig)
            

        ### MAKE COLLECTION
        
        if self.cbCollectionName in foundCollectionList:
            print("Yes - Collection Name: ",self.cbCollectionName)
        else:
            #make the collection
            print("Making Collection Name: ",self.cbCollectionName)
            urlBucketCollectionPost = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/pools/default/buckets/"+self.cbBucketName+"/scopes/"+self.cbScopeName+"/collections"
            collectionConfig = { "name":self.cbCollectionName,"maxTTL":0}
            self.httpPost(urlBucketCollectionPost,self.cbAdminUsername,self.cbAdminPassword,collectionConfig)

    def makeRbacUser(self):

        ### MAKE RBAC USER
        urlRbac = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/settings/rbac/users"
        try:         
            rbacExists = self.httpGet(urlRbac,self.cbAdminUsername,self.cbAdminPassword)
        except Exception as e:
            print("No - RBAC USER: ",self.cbScopeName)
        #make the RBAC SG USER
        foundRbacUser = False            
        for x in rbacExists:
            if x["id"] == self.sgRbacUser:
                foundRbacUser = True

        if foundRbacUser == True:
            print("Yes - RBAC Name: ",self.sgRbacUser)
        else:
            print("Making RBAC USER: ",self.sgRbacUser)
            urlRbacPut = self.cbHostSecure+"://"+ self.cbHost+":"+self.cbPort+"/settings/rbac/users/local/"+self.sgRbacUser
            rbacConfig = { "password":self.sgRbacUserPassword,"roles":"mobile_sync_gateway[*]"}
            self.httpPut(urlRbacPut,self.cbAdminUsername,self.cbAdminPassword,rbacConfig)

    def sgProcessCheck(self):

        url = self.sgHostSecure+"://"+self.sgHostUrl+":"+self.sgAdminPort
        response = {}
        try:
            response = self.httpGet(url,self.cbAdminUsername,self.cbAdminPassword)
            print(response)
            return True
        except Exception as e:
            print("SG is not running or is not reachable at: ",url)
            return False
        
    def sgDbExists(self):

        url = self.sgHostSecure+"://"+self.sgHostUrl+":"+self.sgAdminPort+"/"+self.sgDbName
        response = {}
        try:
            response = self.httpGet(url,self.cbAdminUsername,self.cbAdminPassword)
            print(response)
            return response
        except Exception as e:
            print("SG is not running or is not reachable at: ",url)
            return False
        
    def sgDbMake(self):

        a = open(self.sgDbConfigJsonFile, "r" )
        data = json.loads(a.read())
        a.close()
        data["name"] = self.sgDbName
        data["bucket"] = self.cbBucketName
        print("Config for SG DB: ",self.sgDbName," JSON: ",data)
        url = self.sgHostSecure+"://"+self.sgHostUrl+":"+self.sgAdminPort+"/"+self.sgDbName+"/"
        try:
           req = self.httpPutJson(url,self.cbAdminUsername,self.cbAdminPassword, data)
           print(req)
        except Exception as e:
            print(e)

    def sgMakeUsers(self):
        
        for x in self.sgDbUserList:
            open("sgUser-"+x+".json", "r" )
            rawJsonData = a.read()
            a.close()
            url = self.sgHostSecure+"://"+self.sgHostUrl+":"+self.sgAdminPort+"/"+self.sgDbName+"/_user/"+x
            print("Making SG User:",x)
            try:
                req = self.httpPutJson(url,self.cbAdminUsername,self.cbAdminPassword, rawJsonData)
                print(req)
            except Exception as e:
                print(e)


    #------END OF CLASS WORK -------#

if __name__ == "__main__":
    
    config = str(sys.argv[1]) 
    a = WORK(config)
    ##Check If Bucket,Scope & Collection(s) Exists Already ELSE make them
    a.makeCbBucket()
    ##Check IF the CB RBAC for SG Exists ELSE make them
    a.makeRbacUser()
    ##Check IF SG IS RUNNING
    sgRunning = a.sgProcessCheck()
    if sgRunning == False:
        print("Try Again Later after Sync Gateway is reachable. Check your ports and your URL of Sync Gateway")
        exit()
    sgDbRunning = a.sgDbExists()

    if sgDbRunning == False:
        b = a.sgDbMake()

    if sgDbRunning:
        a.sgMakeUsers()
    