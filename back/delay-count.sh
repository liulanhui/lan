#!/bin/bash
echo -------------begin count delay task-------------------------------
dt=$(date -d"now" +"%F")
echo -------------first get $dt log------------------------------------
cd /home/work/opbin/delay/
sh /home/work/opbin/delay/get-asr-log.sh "grep -E '$dt' /home/audio/mrcp-asr/log/mrcp-asr_debug.log">>/home/work/opbin/delay/mrcp-asr_debug.log
sh /home/work/opbin/delay/get-tts-log.sh "grep -E '$dt' /home/audio/mrcp-proxy/log/mrcp-proxy_debug.log">>/home/work/opbin/delay/mrcp-proxy_debug.log
echo -------------parse log-----------------------------------------
python /home/work/opbin/delay/parse_log.py
echo -------------result to db-----------------------------------------
sh /home/work/opbin/delay/update-db.sh
echo -------------record result-----------------------------------------
mv mrcp-asr_debug.log ./result/mrcp-asr_debug-$dt.log
mv mrcp-proxy_debug.log ./result/mrcp-proxy_debug-$dt.log
mv asr_result.csv ./result/asr_result-$dt.csv
mv tts_result.csv ./result/tts_result-$dt.csv

