#!/bin/bash
echo -------------mytable  query_delay------
asrcsv=asr_result.csv

/home/work/mysql/bin/mysql * -e "
use ivr_admin_dev;
load data local
infile '$asrcsv'
into table query_delay
fields terminated by','
lines terminated by'\n' ignore 0 lines (QUERY_ID,ASR_START_TIME,ASR_END_TIME);
"
ttscsv=tts_result.csv
/home/work/mysql/bin/mysql * -e "
use ivr_admin_dev;
load data local
infile '$ttscsv'
into table query_delay
fields terminated by','
lines terminated by'\n' ignore 0 lines (QUERY_ID,TTS_START_TIME,TTS_END_TIME);
"

/home/work/mysql/bin/mysql * -e "
use ivr_admin_dev;
update query_delay qd  inner join
(select r.query_id,q.ASR_START_TIME ast,q.ASR_END_TIME aet from query_delay q,query_channel_rel r
where q.QUERY_ID= r.channel_req_id) asr_result on qd.QUERY_ID=asr_result.query_id
set qd.ASR_START_TIME=asr_result.ast,qd.ASR_END_TIME=asr_result.aet;
delete from query_delay  where QUERY_ID like '%*_%*_%' escape '*';
"

