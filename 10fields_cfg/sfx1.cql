CREATE TABLE ks_sfx.standard1 ( 
key blob PRIMARY KEY,
"C0" blob, 
"C1" blob, 
"C2" blob, 
"C3" blob,
"C4" blob 
) WITH COMPACT STORAGE AND bloom_filter_fp_chance = 0.01 
AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'} 
AND comment = '' 
AND compaction = {'class': 'SizeTieredCompactionStrategy'} 
AND compression = {} 
AND crc_check_chance = 1.0
AND dclocal_read_repair_chance = 0.1 
AND default_time_to_live = 0 
AND gc_grace_seconds = 864000 
AND max_index_interval = 2048 
AND memtable_flush_period_in_ms = 0 
AND min_index_interval = 128 
AND read_repair_chance = 0.0 
AND speculative_retry = '99.0PERCENTILE';
