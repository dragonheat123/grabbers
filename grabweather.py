import urllib2
#from bs4 import BeautifulSoup
import datetime 
import os

os.chdir('C:\\Users\\lorky\\Desktop\\weathergrabber')            ### set where the weather file should be saved
 
head = 'TimeSGT,TemperatureC,Dew PointC,Humidity,Sea Level PressurehPa,VisibilityKm,Wind Direction,Wind SpeedKm/h,Gust SpeedKm/h,Precipitationmm,Events,Conditions,WindDirDegrees,DateUTC'

text_file = open("changi1.txt", "w")      ##set file name
text_file.write(head)
text_file.close()

opener = urllib2.build_opener()
opener.addheaders = [('User-agent', 'Mozilla/5.0')]

startdate = datetime.datetime(2015, 9, 3, 0, 0)   ####start date, initialize as 1 day before actual startdate

while startdate!=datetime.datetime(2015, 12, 31, 0, 0):  ###end date
    startdate =startdate + datetime.timedelta(days = 1)
    date = str(startdate).replace('-','/').replace(' 00:00:00','')
    ## for changi, can change to where you want it based on the weatherunderground site
    url = 'https://www.wunderground.com/history/airport/WSSS/'+ date + '/DailyHistory.html?req_city=Changi&req_state=&req_statename=Singapore&reqdb.zip=00000&reqdb.magic=60&reqdb.wmo=48698&format=1'
    ## for seleta, nearest to yishun
    #url = 'https://www.wunderground.com/history/airport/WSSS/'+ date + '/DailyHistory.html?req_city=Johor%20Bahru&req_statename=Singapore&reqdb.zip=00000&reqdb.magic=321&reqdb.wmo=48692&format=1'
    response = opener.open(url)
    page = response.read()
    text = str(page)
    text = text.replace('<br />','')
    text = text.replace(head,'')
    text_file = open("changi1.txt", "a")
    text_file.write(text)
    text_file.close()
    print str(startdate)
  