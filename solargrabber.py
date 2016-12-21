import cv2
import numpy as np
import urllib2
import datetime
import os

os.chdir('C:\\Users\\lorky\\Desktop\\weathergrabber') 
head = 'Date, Irradiance Value'
otime = datetime.datetime.now()
text_file = open("yishun_solar.txt", "w")      ##set file name
text_file.write(head)
text_file.close()

while 1:
    if (datetime.datetime.now()-otime)>datetime.timedelta(minutes=1):
        hdr = {'User-Agent': 'Mozilla/5.0'}
        req = urllib2.Request('http://www.solar-repository.sg/ftp_up/irradiance/NSR_IrrMap.png', headers=hdr)
        con = urllib2.urlopen( req )
        im_array = np.asarray(bytearray(con.read()), dtype=np.uint8)
        im =  cv2.imdecode(im_array, cv2.IMREAD_COLOR)
        poi=(im[139, 629,:])
        valuelist=(im[510, 862:1117,:])
        #cv2.imshow('show',im)
        value =0
        if np.where(poi==valuelist)[1][1]==np.where(poi==valuelist)[1][2]:
            value = float(np.where(poi==valuelist)[1][1]+1)/255*1200
        text = datetime.datetime.now().strftime('%d %b %Y %H:%M')+', '+str(value)+ '\n'
        text_file = open("yishun_solar.txt", "a")
        text_file.write(text)
        text_file.close()
        otime = otime+datetime.timedelta(minutes=1)
        