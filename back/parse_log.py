#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
"""
解析
Date:    '2017/08/09'
"""

import re
import sys
import csv
import datetime


def handle_asr_data():
    """
    解析asr响应延时
    :return:
    """
    start = "end send last audio chunk timestamp:"
    end = "Send RECOGNIZE_COMPLETE timestamp:"
    asr_dict = {}
    with open(atarget, 'w') as target:
        csv_write = csv.writer(target)
        # csv_write.writerow(('QUERY_ID','ASR_START_TIME','ASR_END_TIME'))
        print "parse to asr csv file " + atarget
        for line in open(asource):
            try:
                if not re.findall(start, line) and not re.findall(end, line):
                    continue
                if re.findall(start, line):
                    sn_asr = re.findall(r"sn:(.+?)]", line)
                    start_time = re.findall(r"end send last audio chunk timestamp:(.+?)\n", line)
                    sn_key = sn_asr[0] + "_start"
                    asr_dict[sn_key] = start_time[0]
                if re.findall(end, line):
                    sn_asr = re.findall(r"sn:(.+?)]", line)
                    time_end = re.findall(r"Send RECOGNIZE_COMPLETE timestamp:(.+?)\n", line)
                    key = sn_asr[0] + "_start"
                    if key in asr_dict:
                        time_start = asr_dict.get(key)
                        if time_start is not None and time_end:
                            csv_write.writerow([sn_asr[0].strip(), time_start.strip(), time_end[0].strip()])
                            del asr_dict[key]
            except BaseException as exception:
                print "parse to asr error %s \n %s" % (line, exception)


def handle_tts_data():
    """
    :return:
    """
    start = "start synthesize timestamp:"
    end = "first recv audio timestamp:"
    tts_dict = {}
    with open(ttarget, 'w') as target:
        csv_write = csv.writer(target)
        # csv_write.writerow(('QUERY_ID','TTS_START_TIME','TTS_END_TIME'))
        print "parse to tts csv file " + ttarget
        for line in open(tsource):
            try:
                if not re.findall(start, line) and not re.findall(end, line):
                    continue
                if re.findall(start, line):
                    sn_tts = re.findall(r"queryId:(.+?)]", line)
                    if not sn_tts:
                        continue
                    start_time = re.findall(r"start synthesize timestamp:(.+?)\n", line)
                    sn_key = sn_tts[0] + "_start"
                    tts_dict[sn_key] = start_time[0]
                if re.findall(end, line):
                    sn_tts = re.findall(r"queryId:(.+?)]", line)
                    if not sn_tts:
                        continue
                    time_end = re.findall(r"first recv audio timestamp:(.+?)\n", line)
                    key = sn_tts[0] + "_start"
                    if key in tts_dict:
                        time_start = tts_dict.get(key)
                        if time_start is not None and time_end:
                            csv_write.writerow([sn_tts[0].strip(), time_start.strip(), time_end[0].strip()])
                            del tts_dict[key]
            except BaseException as exception:
                print "parse to tts error %s \n %s" % (line, exception)


if __name__ == "__main__":
    reload(sys)
    sys.setdefaultencoding('utf-8')
    asource = 'mrcp-asr_debug.log'
    atarget = 'asr_result.csv'
    tsource = 'mrcp-proxy_debug.log'
    ttarget = 'tts_result.csv'
    print "asr target file " + atarget + "asr source file " + asource
    print "tts target file " + ttarget + "tts source file " + tsource
    handle_asr_data()
    handle_tts_data()

