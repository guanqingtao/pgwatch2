/* backends */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'backends',
9.0,
$sql$
with sa_snapshot as (
  select * from public.get_stat_activity() where pid != pg_backend_pid() and not query like 'autovacuum:%'
)
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select count(*) from sa_snapshot) as total,
  (select count(*) from sa_snapshot where state = 'active') as active,
  (select count(*) from sa_snapshot where state = 'idle') as idle,
  (select count(*) from sa_snapshot where state = 'idle in transaction') as idleintransaction,
  (select count(*) from sa_snapshot where waiting) as waiting,
  (select extract(epoch from (now() - backend_start))::int
    from sa_snapshot order by backend_start limit 1) as longest_session_seconds,
  (select extract(epoch from (now() - xact_start))::int
    from sa_snapshot where xact_start is not null order by xact_start limit 1) as longest_tx_seconds,
  (select extract(epoch from max(now() - query_start))::int
    from sa_snapshot where state = 'active') as longest_query_seconds;
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'backends',
9.4,
$sql$
with sa_snapshot as (
  select * from public.get_stat_activity() where pid != pg_backend_pid() and not query like 'autovacuum:%'
)
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select count(*) from sa_snapshot) as total,
  (select count(*) from sa_snapshot where state = 'active') as active,
  (select count(*) from sa_snapshot where state = 'idle') as idle,
  (select count(*) from sa_snapshot where state = 'idle in transaction') as idleintransaction,
  (select count(*) from sa_snapshot where waiting) as waiting,
  (select extract(epoch from (now() - backend_start))::int
    from sa_snapshot order by backend_start limit 1) as longest_session_seconds,
  (select extract(epoch from (now() - xact_start))::int
    from sa_snapshot where xact_start is not null order by xact_start limit 1) as longest_tx_seconds,
  (select extract(epoch from max(now() - query_start))::int
    from sa_snapshot where state = 'active') as longest_query_seconds,
  (select max(age(backend_xmin))::int8 from sa_snapshot) as max_xmin_age_tx;
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'backends',
9.6,
$sql$
with sa_snapshot as (
  select * from public.get_stat_activity() where pid != pg_backend_pid() and not query like 'autovacuum:%'
)
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select count(*) from sa_snapshot) as total,
  (select count(*) from sa_snapshot where state = 'active') as active,
  (select count(*) from sa_snapshot where state = 'idle') as idle,
  (select count(*) from sa_snapshot where state = 'idle in transaction') as idleintransaction,
  (select count(*) from sa_snapshot where wait_event_type in ('LWLockNamed', 'Lock', 'BufferPin')) as waiting,
  (select extract(epoch from (now() - backend_start))::int
    from sa_snapshot order by backend_start limit 1) as longest_session_seconds,
  (select extract(epoch from (now() - xact_start))::int
    from sa_snapshot where xact_start is not null order by xact_start limit 1) as longest_tx_seconds,
  (select extract(epoch from max(now() - query_start))::int
    from sa_snapshot where state = 'active') as longest_query_seconds,
  (select max(age(backend_xmin))::int8 from sa_snapshot) as max_xmin_age_tx;
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'backends',
10,
$sql$
with sa_snapshot as (
  select * from public.get_stat_activity()
  where pid != pg_backend_pid()
  and datname = current_database()
)
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select count(*) from sa_snapshot) as total,
  (select count(*) from sa_snapshot where backend_type = 'background worker') as background_workers,
  (select count(*) from sa_snapshot where state = 'active' and backend_type = 'client backend') as active,
  (select count(*) from sa_snapshot where state = 'idle' and backend_type = 'client backend') as idle,
  (select count(*) from sa_snapshot where state = 'idle in transaction' and backend_type = 'client backend') as idleintransaction,
  (select count(*) from sa_snapshot where wait_event_type in ('LWLock', 'Lock', 'BufferPin') and backend_type = 'client backend') as waiting,
  (select extract(epoch from (now() - backend_start))::int
    from sa_snapshot where backend_type = 'client backend' order by backend_start limit 1) as longest_session_seconds,
  (select extract(epoch from (now() - xact_start))::int
    from sa_snapshot where xact_start is not null and backend_type = 'client backend' order by xact_start limit 1) as longest_tx_seconds,
  (select extract(epoch from max(now() - query_start))::int
    from sa_snapshot where state = 'active' and backend_type = 'client backend') as longest_query_seconds,
  (select max(age(backend_xmin))::int8 from sa_snapshot) as max_xmin_age_tx;
$sql$
);

/* bgwriter */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'bgwriter',
9.0,
$sql$
select
   (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
   checkpoints_timed,
   checkpoints_req,
   checkpoint_write_time,
   checkpoint_sync_time,
   buffers_checkpoint,
   buffers_clean,
   maxwritten_clean,
   buffers_backend,
   buffers_backend_fsync,
   buffers_alloc
 from
   pg_stat_bgwriter;
$sql$
);

/* cpu_load */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'cpu_load',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  load_1min,
  load_5min,
  load_15min
from
  public.get_load_average();   -- needs the plpythonu proc from "metric_fetching_helpers" folder
$sql$
);


/* db_stats */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'db_stats',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  pg_database_size(datname) as size_b,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  tup_returned,
  tup_fetched,
  tup_inserted,
  tup_updated,
  tup_deleted,
  conflicts,
  temp_files,
  temp_bytes,
  deadlocks,
  blk_read_time,
  blk_write_time,
  extract(epoch from (now() - pg_postmaster_start_time()))::int8 as postmaster_uptime_s
from
  pg_stat_database
where
  datname = current_database();
$sql$
);

/* index_stats */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'index_stats',
9.0,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  schemaname::text as tag_schema,
  indexrelname::text as tag_index_name,
  quote_ident(schemaname)||'.'||quote_ident(indexrelname) as tag_index_full_name,
  relname::text as tag_table_name,
  quote_ident(schemaname)||'.'||quote_ident(relname) as tag_table_full_name,
  coalesce(idx_scan, 0) as idx_scan,
  coalesce(idx_tup_read, 0) as idx_tup_read,
  coalesce(idx_tup_fetch, 0) as idx_tup_fetch,
  coalesce(pg_relation_size(indexrelid), 0) as index_size_b,
  quote_ident(schemaname)||'.'||quote_ident(sui.indexrelname) as index_full_name_val,
  md5(regexp_replace(replace(pg_get_indexdef(sui.indexrelid),indexrelname,'X'), '^CREATE UNIQUE','CREATE')) as tag_index_def_hash,
  regexp_replace(replace(pg_get_indexdef(sui.indexrelid),indexrelname,'X'), '^CREATE UNIQUE','CREATE') as index_def,
  case when not i.indisvalid then 1 else 0 end as is_invalid_int,
  case when i.indisprimary then 1 else 0 end as is_pk_int
FROM
  pg_stat_user_indexes sui
  JOIN
  pg_index i USING (indexrelid)
WHERE
  NOT schemaname like E'pg\\_temp%'
ORDER BY
  schemaname, relname, indexrelname;
$sql$
);


/* kpi */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'kpi',
9.0,
$sql$
WITH q_stat_tables AS (
  SELECT * FROM pg_stat_user_tables t
  JOIN pg_class c ON c.oid = t.relid
  WHERE NOT schemaname LIKE E'pg\\_temp%'
  AND c.relpages > (1e7 / 8)    -- >10MB
),
q_stat_activity AS (
  SELECT * FROM public.get_stat_activity() WHERE pid != pg_backend_pid() AND datname = current_database()
)
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select pg_xlog_location_diff(pg_current_xlog_location(), '0/0'))::int8 AS wal_location_b,
  numbackends - 1 as numbackends,
  (select count(1) from q_stat_activity where state = 'active') AS active_backends,
  (select count(1) from q_stat_activity where waiting) AS blocked_backends,
  (select round(extract(epoch from now()) - extract(epoch from (select xact_start from q_stat_activity
    where datid = d.datid and not query like 'autovacuum:%' order by xact_start limit 1))))::int AS kpi_oldest_tx_s,
  xact_commit + xact_rollback AS tps,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  temp_bytes,
  (select sum(seq_scan) from q_stat_tables)::int8 AS seq_scans_on_tbls_gt_10mb,
  tup_inserted,
  tup_updated,
  tup_deleted,
  (select sum(calls) from pg_stat_user_functions where not schemaname like any(array[E'pg\\_%', 'information_schema']))::int8 AS sproc_calls,
  blk_read_time,
  blk_write_time,
  deadlocks
FROM
  pg_stat_database d
WHERE
  datname = current_database();
$sql$
);

/* kpi */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'kpi',
9.6,
$sql$
WITH q_stat_tables AS (
  SELECT * FROM pg_stat_user_tables t
  JOIN pg_class c ON c.oid = t.relid
  WHERE NOT schemaname LIKE E'pg\\_temp%'
  AND c.relpages > (1e7 / 8)    -- >10MB
),
q_stat_activity AS (
  SELECT * FROM public.get_stat_activity() WHERE pid != pg_backend_pid() AND datname = current_database()
)
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select pg_xlog_location_diff(pg_current_xlog_location(), '0/0'))::int8 AS wal_location_b,
  numbackends - 1 as numbackends,
  (select count(1) from q_stat_activity where state = 'active') AS active_backends,
  (select count(1) from q_stat_activity where wait_event_type is not null) AS blocked_backends,
  (select round(extract(epoch from now()) - extract(epoch from (select xact_start from q_stat_activity
    where datid = d.datid and not query like 'autovacuum:%' order by xact_start limit 1))))::int AS kpi_oldest_tx_s,
  xact_commit + xact_rollback AS tps,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  temp_bytes,
  (select sum(seq_scan) from q_stat_tables)::int8 AS seq_scans_on_tbls_gt_10mb,
  tup_inserted,
  tup_updated,
  tup_deleted,
  (select sum(calls) from pg_stat_user_functions where not schemaname like any(array[E'pg\\_%', 'information_schema']))::int8 AS sproc_calls,
  blk_read_time,
  blk_write_time,
  deadlocks
FROM
  pg_stat_database d
WHERE
  datname = current_database();
$sql$
);

/* kpi */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'kpi',
10,
$sql$
WITH q_stat_tables AS (
  SELECT * FROM pg_stat_user_tables t
  JOIN pg_class c ON c.oid = t.relid
  WHERE NOT schemaname LIKE E'pg\\_temp%'
  AND c.relpages > (1e7 / 8)    -- >10MB
),
q_stat_activity AS (
  SELECT * FROM public.get_stat_activity() WHERE pid != pg_backend_pid() AND datname = current_database()
)
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  (select pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0'))::int8 AS wal_location_b,
  numbackends - 1 as numbackends,
  (select count(1) from q_stat_activity where state = 'active') AS active_backends,
  (select count(1) from q_stat_activity where wait_event_type is not null) AS blocked_backends,
  (select round(extract(epoch from now()) - extract(epoch from (select xact_start from q_stat_activity
    where datid = d.datid and not query like 'autovacuum:%' order by xact_start limit 1))))::int AS kpi_oldest_tx_s,
  xact_commit + xact_rollback AS tps,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  temp_bytes,
  (select sum(seq_scan) from q_stat_tables)::int8 AS seq_scans_on_tbls_gt_10mb,
  tup_inserted,
  tup_updated,
  tup_deleted,
  (select sum(calls) from pg_stat_user_functions where not schemaname like any(array[E'pg\\_%', 'information_schema']))::int8 AS sproc_calls,
  blk_read_time,
  blk_write_time,
  deadlocks
FROM
  pg_stat_database d
WHERE
  datname = current_database();
$sql$
);


/* replication */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'replication',
9.2,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  application_name as tag_application_name,
  concat(coalesce(client_addr::text, client_hostname), '_', client_port::text) as tag_client_info,
  coalesce(pg_xlog_location_diff(pg_current_xlog_location(), write_location)::int8, 0) as write_lag_b,
  coalesce(pg_xlog_location_diff(pg_current_xlog_location(), flush_location)::int8, 0) as flush_lag_b,
  coalesce(pg_xlog_location_diff(pg_current_xlog_location(), replay_location)::int8, 0) as replay_lag_b,
  state,
  sync_state,
  case when sync_state in ('sync', 'quorum') then 1 else 0 end as is_sync_int
from
  pg_stat_replication;
$sql$
);

/* replication */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'replication',
10,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  application_name as tag_application_name,
  concat(coalesce(client_addr::text, client_hostname), '_', client_port::text) as tag_client_info,
  coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), write_lsn)::int8, 0) as write_lag_b,
  coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn)::int8, 0) as flush_lag_b,
  coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)::int8, 0) as replay_lag_b,
  state,
  sync_state,
  case when sync_state in ('sync', 'quorum') then 1 else 0 end as is_sync_int
from
  pg_stat_replication;

$sql$
);


/* sproc_stats */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'sproc_stats',
9.0,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  schemaname::text AS tag_schema,
  funcname::text  AS tag_function_name,
  quote_ident(schemaname)||'.'||quote_ident(funcname) as tag_function_full_name,
  p.oid::text as tag_oid, -- for overloaded funcs
  calls as sp_calls,
  self_time,
  total_time
FROM
  pg_stat_user_functions f
  JOIN
  pg_proc p ON p.oid = f.funcid;
$sql$
);

/* table_io_stats */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'table_io_stats',
9.0,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  schemaname::text as tag_schema,
  relname::text as tag_table_name,
  quote_ident(schemaname)||'.'||quote_ident(relname) as tag_table_full_name,
  heap_blks_read,
  heap_blks_hit,
  idx_blks_read,
  idx_blks_hit,
  toast_blks_read,
  toast_blks_hit,
  tidx_blks_read,
  tidx_blks_hit
FROM
  pg_statio_user_tables
WHERE
  NOT schemaname LIKE E'pg\\_temp%'
  AND (heap_blks_read > 0 OR heap_blks_hit > 0 OR idx_blks_read > 0 OR idx_blks_hit > 0 OR tidx_blks_read > 0 OR tidx_blks_hit > 0);
$sql$
);

/* table_stats */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'table_stats',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  quote_ident(schemaname) as tag_schema,
  quote_ident(relname) as tag_table_name,
  quote_ident(schemaname)||'.'||quote_ident(relname) as tag_table_full_name,
  pg_relation_size(relid) as table_size_b,
  pg_total_relation_size(relid) as total_relation_size_b,
  pg_relation_size((select reltoastrelid from pg_class where oid = ut.relid)) as toast_size_b,
  extract(epoch from now() - greatest(last_vacuum, last_autovacuum)) as seconds_since_last_vacuum,
  extract(epoch from now() - greatest(last_analyze, last_autoanalyze)) as seconds_since_last_analyze,
  seq_scan,
  seq_tup_read,
  idx_scan,
  idx_tup_fetch,
  n_tup_ins,
  n_tup_upd,
  n_tup_del,
  n_tup_hot_upd,
  vacuum_count,
  autovacuum_count,
  analyze_count,
  autoanalyze_count
from
  pg_stat_user_tables ut
where
  -- leaving out fully locked tables as pg_relation_size also wants a lock and would wait
  not exists (select 1 from pg_locks where relation = relid and mode = 'AccessExclusiveLock' and granted);
$sql$
);

/* wal */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'wal',
9.2,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  case
    when pg_is_in_recovery() = false then
      pg_xlog_location_diff(pg_current_xlog_location(), '0/0')::int8
    else
      pg_xlog_location_diff(pg_last_xlog_replay_location(), '0/0')::int8
    end as xlog_location_b,
  case when pg_is_in_recovery() then 1 else 0 end as in_recovery_int,
  extract(epoch from (now() - pg_postmaster_start_time()))::int8 as postmaster_uptime_s;
$sql$
);


/* wal */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'wal',
10,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  case
    when pg_is_in_recovery() = false then
      pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')::int8
    else
      pg_wal_lsn_diff(pg_last_wal_replay_lsn(), '0/0')::int8
    end as xlog_location_b,
  case when pg_is_in_recovery() then 1 else 0 end as in_recovery_int,
  extract(epoch from (now() - pg_postmaster_start_time()))::int8 as postmaster_uptime_s;
$sql$
);

/* stat_statements */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'stat_statements',
9.2,
$sql$
with q_data as (
  select
    (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
    queryid::text as tag_queryid,
    max(ltrim(regexp_replace(query, E'[ \\t\\n\\r]+' , ' ', 'g')))::varchar(16000) as tag_query,
    sum(s.calls)::int8 as calls,
    sum(s.total_time)::double precision as total_time,
    sum(shared_blks_hit)::int8 as shared_blks_hit,
    sum(shared_blks_read)::int8 as shared_blks_read,
    sum(shared_blks_written)::int8 as shared_blks_written,
    sum(shared_blks_dirtied)::int8 as shared_blks_dirtied,
    sum(temp_blks_read)::int8 as temp_blks_read,
    sum(temp_blks_written)::int8 as temp_blks_written,
    sum(blk_read_time)::double precision as blk_read_time,
    sum(blk_write_time)::double precision as blk_write_time
  from
    public.get_stat_statements() s
  where
    calls > 5
    and total_time > 0
    and dbid = (select oid from pg_database where datname = current_database())
    and not upper(s.query) like any (array['DEALLOCATE%', 'SET %', 'RESET %', 'BEGIN%', 'BEGIN;',
      'COMMIT%', 'END%', 'ROLLBACK%', 'SHOW%'])
  group by
    queryid
)
select * from (
  select
    *
  from
    q_data
  where
    total_time > 0
  order by
    total_time desc
  limit 100
) a
union
select * from (
  select
    *
  from
    q_data
  order by
    calls desc
  limit 100
) a
union
select * from (
  select
    *
  from
    q_data
  where
    shared_blks_read > 0
  order by
    shared_blks_read desc
  limit 100
) a
union
select * from (
  select
    *
  from
    q_data
  where
    shared_blks_written > 0
  order by
    shared_blks_written desc
  limit 100
) a
union
select * from (
  select
    *
  from
    q_data
  where
    temp_blks_read > 0
  order by
    temp_blks_read desc
  limit 100
) a
union
select * from (
  select
    *
  from
    q_data
  where
    temp_blks_written > 0
  order by
    temp_blks_written desc
  limit 100
) a;
$sql$
);

/* stat_statements_calls - enables to show QPS queries per second. "calls" works without the above wrapper also */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'stat_statements_calls',
9.2,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  coalesce(sum(calls), 0)::int8 as calls,
  coalesce(sum(total_time), 0)::float8 as total_time
from
  pg_stat_statements
where
  dbid = (select oid from pg_database where datname = current_database())
  and calls > 10
;
$sql$
);


/* buffercache_by_db */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'buffercache_by_db',
9.2,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  datname as tag_database,
  count(*) * (current_setting('block_size')::int8) as size_b
FROM
  pg_buffercache AS b,
  pg_database AS d
WHERE
  d.oid = b.reldatabase
GROUP BY
  datname;
$sql$
);

/* buffercache_by_type */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'buffercache_by_type',
9.2,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  CASE
    WHEN relkind = 'r' THEN 'Table'   -- TODO all relkinds covered?
    WHEN relkind = 'i' THEN 'Index'
    WHEN relkind = 't' THEN 'Toast'
    WHEN relkind = 'm' THEN 'Materialized view'
    ELSE 'Other'
  END as tag_relkind,
  count(*) * (current_setting('block_size')::int8) as size_b
FROM
  pg_buffercache AS b,
  pg_class AS d
WHERE
  d.oid = b.relfilenode
GROUP BY 
  relkind;
$sql$
);


/* pg_stat_ssl */       -- join with backends?
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'pg_stat_ssl',
9.5,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  ssl,
  count(*)
FROM
  pg_stat_ssl AS s,
  public.get_stat_activity() AS a
WHERE
  a.pid = s.pid
  AND a.datname = current_database()
GROUP BY
  1, 2
$sql$
);


/* pg_stat_database_conflicts */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'pg_stat_database_conflicts',
9.2,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  confl_tablespace,
  confl_lock,
  confl_snapshot,
  confl_bufferpin,
  confl_deadlock
FROM
  pg_stat_database_conflicts
WHERE
  datname = current_database();
$sql$
);


/* locks - counts only */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'locks',
9.0,
$sql$
WITH q_locks AS (
  select
    *
  from
    pg_locks
  where
    pid != pg_backend_pid()
    and database = (select oid from pg_database where datname = current_database())
)
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  locktypes AS tag_locktype,
  coalesce((select count(*) FROM q_locks WHERE locktype = locktypes), 0) AS count
FROM
  unnest('{relation, extend, page, tuple, transactionid, virtualxid, object, userlock, advisory}'::text[]) locktypes;
$sql$
);

/* locks - counts only */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'locks_mode',
9.0,
$sql$
WITH q_locks AS (
  select
    *
  from
    pg_locks
  where
    pid != pg_backend_pid()
    and database = (select oid from pg_database where datname = current_database())
)
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  lockmodes AS tag_lockmode,
  coalesce((select count(*) FROM q_locks WHERE mode = lockmodes), 0) AS count
FROM
  unnest('{AccessShareLock, ExclusiveLock, RowShareLock, RowExclusiveLock, ShareLock, ShareRowExclusiveLock,  AccessExclusiveLock, ShareUpdateExclusiveLock}'::text[]) lockmodes;
$sql$
);


/* blocking_locks - based on https://wiki.postgresql.org/wiki/Lock_dependency_information.
 not sure if it makes sense though, locks are quite volatile normally */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'blocking_locks',
9.2,
$sql$
SELECT
    (extract(epoch from now()) * 1e9)::int8 AS epoch_ns,
    waiting.locktype           AS tag_waiting_locktype,
    waiting_stm.usename        AS tag_waiting_user,
    coalesce(waiting.mode, 'null'::text) AS tag_waiting_mode,
    coalesce(waiting.relation::regclass::text, 'null') AS tag_waiting_table,
    waiting_stm.query          AS waiting_query,
    waiting.pid                AS waiting_pid,
    other.locktype             AS other_locktype,
    other.relation::regclass   AS other_table,
    other_stm.query            AS other_query,
    other.mode                 AS other_mode,
    other.pid                  AS other_pid,
    other_stm.usename          AS other_user
FROM
    pg_catalog.pg_locks AS waiting
JOIN
    public.get_stat_activity() AS waiting_stm
    ON (
        waiting_stm.pid = waiting.pid
    )
JOIN
    pg_catalog.pg_locks AS other
    ON (
        (
            waiting."database" = other."database"
        AND waiting.relation  = other.relation
        )
        OR waiting.transactionid = other.transactionid
    )
JOIN
    public.get_stat_activity() AS other_stm
    ON (
        other_stm.pid = other.pid
    )
WHERE
    NOT waiting.GRANTED
AND
    waiting.pid <> other.pid
AND
    other.GRANTED
AND
    waiting_stm.datname = current_database();
$sql$
);


/* approx. bloat - needs pgstattuple extension! superuser or pg_stat_scan_tables/pg_monitor builtin role required */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'table_bloat_approx_stattuple',
9.5,
$sql$
select
  quote_ident(n.nspname)||'.'||quote_ident(c.relname) as tag_full_table_name,
  approx_free_percent,
  approx_free_space_b,
  approx_tuple_count,
  dead_tuple_percent,
  dead_tuple_len_b
from
  pg_class c
  join lateral public.pgstattuple_approx(c.oid) st on (c.oid not in (select relation from pg_locks where mode = 'AccessExclusiveLock'))  -- skip locked tables,
  join pg_namespace n on n.oid = c.relnamespace
where
  relkind in ('r', 'm')
  and c.relpages >= 128 -- tables > 1mb
  and not n.nspname like any (array[E'pg\\_%', 'information_schema']);
$sql$
);

/* Stored procedure needed for fetching stat_statements data - needs pg_stat_statements extension enabled on the machine!
 NB! approx_free_percent is just an average. more exact way would be to calculate a weighed average in Go
*/
insert into pgwatch2.metric(m_name, m_pg_version_from, m_sql, m_comment, m_is_helper)
values (
'get_table_bloat_approx',
9.5,
$sql$
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA PUBLIC;

CREATE OR REPLACE FUNCTION public.get_table_bloat_approx(
  OUT approx_free_percent double precision, OUT approx_free_space double precision,
  OUT approx_free_percent double precision, OUT approx_free_space double precision
) AS
$$
    select
      avg(approx_free_percent)::double precision as approx_free_percent,
      sum(approx_free_space)::double precision as approx_free_space,
      avg(dead_tuple_percent)::double precision as dead_tuple_percent,
      sum(dead_tuple_len)::double precision as dead_tuple_len
    from
      pg_class c
      join
      pg_namespace n on n.oid = c.relnamespace
      join lateral public.pgstattuple_approx(c.oid) on (c.oid not in (select relation from pg_locks where mode = 'AccessExclusiveLock'))  -- skip locked tables
    where
      relkind in ('r', 'm')
      and c.relpages >= 128 -- tables >1mb
      and not n.nspname like any (array[E'pg\\_%', 'information_schema'])
$$ LANGUAGE sql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.get_table_bloat_approx() TO public;
COMMENT ON FUNCTION public.get_table_bloat_approx() is 'created for pgwatch2';

COMMIT;
$sql$,
'for internal usage - when connecting user is marked as superuser then the daemon will automatically try to create the needed helpers on the monitored db',
true
);

/* approx. bloat summary */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'table_bloat_approx_summary',
9.5,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  approx_free_percent,
  approx_free_space as approx_free_space_b,
  dead_tuple_percent,
  dead_tuple_len as dead_tuple_len_b
from
  public.get_table_bloat_approx()
where
  approx_free_space > 0
$sql$
);

/* "parent" setting for all of the below "*_hashes" metrics. only this parent "change_events" metric should be used in configs! */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'change_events',
9.0,
$sql$
$sql$
);

/* sproc hashes for change detection */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'sproc_hashes',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  p.oid::text as tag_oid,
  quote_ident(nspname)||'.'||quote_ident(proname) as tag_sproc,
  md5(prosrc)
from
  pg_proc p
  join
  pg_namespace n on n.oid = pronamespace
where
  not nspname like any(array[E'pg\\_%', 'information_schema']);
$sql$
);

/* table (and view) hashes for change detection  */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'table_hashes',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  quote_ident(table_schema)||'.'||quote_ident(table_name) as tag_table,
  md5((array_agg((c.*)::text order by ordinal_position))::text)
from (
 SELECT current_database()::information_schema.sql_identifier AS table_catalog,
    nc.nspname::information_schema.sql_identifier AS table_schema,
    c.relname::information_schema.sql_identifier AS table_name,
    a.attname::information_schema.sql_identifier AS column_name,
    a.attnum::information_schema.cardinal_number AS ordinal_position,
    pg_get_expr(ad.adbin, ad.adrelid)::information_schema.character_data AS column_default,
        CASE
            WHEN a.attnotnull OR t.typtype = 'd'::"char" AND t.typnotnull THEN 'NO'::text
            ELSE 'YES'::text
        END::information_schema.yes_or_no AS is_nullable,
        CASE
            WHEN t.typtype = 'd'::"char" THEN
            CASE
                WHEN bt.typelem <> 0::oid AND bt.typlen = '-1'::integer THEN 'ARRAY'::text
                WHEN nbt.nspname = 'pg_catalog'::name THEN format_type(t.typbasetype, NULL::integer)
                ELSE 'USER-DEFINED'::text
            END
            ELSE
            CASE
                WHEN t.typelem <> 0::oid AND t.typlen = '-1'::integer THEN 'ARRAY'::text
                WHEN nt.nspname = 'pg_catalog'::name THEN format_type(a.atttypid, NULL::integer)
                ELSE 'USER-DEFINED'::text
            END
        END::information_schema.character_data AS data_type,
    information_schema._pg_char_max_length(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.cardinal_number AS character_maximum_length,
    information_schema._pg_char_octet_length(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.cardinal_number AS character_octet_length,
    information_schema._pg_numeric_precision(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.cardinal_number AS numeric_precision,
    information_schema._pg_numeric_precision_radix(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.cardinal_number AS numeric_precision_radix,
    information_schema._pg_numeric_scale(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.cardinal_number AS numeric_scale,
    information_schema._pg_datetime_precision(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.cardinal_number AS datetime_precision,
    information_schema._pg_interval_type(information_schema._pg_truetypid(a.*, t.*), information_schema._pg_truetypmod(a.*, t.*))::information_schema.character_data AS interval_type,
    NULL::integer::information_schema.cardinal_number AS interval_precision,
    NULL::character varying::information_schema.sql_identifier AS character_set_catalog,
    NULL::character varying::information_schema.sql_identifier AS character_set_schema,
    NULL::character varying::information_schema.sql_identifier AS character_set_name,
        CASE
            WHEN nco.nspname IS NOT NULL THEN current_database()
            ELSE NULL::name
        END::information_schema.sql_identifier AS collation_catalog,
    nco.nspname::information_schema.sql_identifier AS collation_schema,
    co.collname::information_schema.sql_identifier AS collation_name,
        CASE
            WHEN t.typtype = 'd'::"char" THEN current_database()
            ELSE NULL::name
        END::information_schema.sql_identifier AS domain_catalog,
        CASE
            WHEN t.typtype = 'd'::"char" THEN nt.nspname
            ELSE NULL::name
        END::information_schema.sql_identifier AS domain_schema,
        CASE
            WHEN t.typtype = 'd'::"char" THEN t.typname
            ELSE NULL::name
        END::information_schema.sql_identifier AS domain_name,
    current_database()::information_schema.sql_identifier AS udt_catalog,
    COALESCE(nbt.nspname, nt.nspname)::information_schema.sql_identifier AS udt_schema,
    COALESCE(bt.typname, t.typname)::information_schema.sql_identifier AS udt_name,
    NULL::character varying::information_schema.sql_identifier AS scope_catalog,
    NULL::character varying::information_schema.sql_identifier AS scope_schema,
    NULL::character varying::information_schema.sql_identifier AS scope_name,
    NULL::integer::information_schema.cardinal_number AS maximum_cardinality,
    a.attnum::information_schema.sql_identifier AS dtd_identifier,
    'NO'::character varying::information_schema.yes_or_no AS is_self_referencing,
    'NO'::character varying::information_schema.yes_or_no AS is_identity,
    NULL::character varying::information_schema.character_data AS identity_generation,
    NULL::character varying::information_schema.character_data AS identity_start,
    NULL::character varying::information_schema.character_data AS identity_increment,
    NULL::character varying::information_schema.character_data AS identity_maximum,
    NULL::character varying::information_schema.character_data AS identity_minimum,
    NULL::character varying::information_schema.yes_or_no AS identity_cycle,
    'NEVER'::character varying::information_schema.character_data AS is_generated,
    NULL::character varying::information_schema.character_data AS generation_expression,
        CASE
            WHEN c.relkind = 'r'::"char" OR (c.relkind = ANY (ARRAY['v'::"char", 'f'::"char"])) AND pg_column_is_updatable(c.oid::regclass, a.attnum, false) THEN 'YES'::text
            ELSE 'NO'::text
        END::information_schema.yes_or_no AS is_updatable
   FROM pg_attribute a
     LEFT JOIN pg_attrdef ad ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum
     JOIN (pg_class c
     JOIN pg_namespace nc ON c.relnamespace = nc.oid) ON a.attrelid = c.oid
     JOIN (pg_type t
     JOIN pg_namespace nt ON t.typnamespace = nt.oid) ON a.atttypid = t.oid
     LEFT JOIN (pg_type bt
     JOIN pg_namespace nbt ON bt.typnamespace = nbt.oid) ON t.typtype = 'd'::"char" AND t.typbasetype = bt.oid
     LEFT JOIN (pg_collation co
     JOIN pg_namespace nco ON co.collnamespace = nco.oid) ON a.attcollation = co.oid AND (nco.nspname <> 'pg_catalog'::name OR co.collname <> 'default'::name)
  WHERE NOT pg_is_other_temp_schema(nc.oid) AND a.attnum > 0 AND NOT a.attisdropped AND (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char", 'f'::"char"]))

) c
where
  not table_schema like any (array[E'pg\\_%', 'information_schema'])
group by
  table_schema, table_name
order by
  table_schema, table_name;
$sql$
);


/* configuration settings hashes for change detection  */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'configuration_hashes',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  name as tag_setting,
  coalesce(reset_val, '') as value
from
  pg_settings;
$sql$
);

/* index hashes for change detection  */
insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'index_hashes',
9.0,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  quote_ident(nspname)||'.'||quote_ident(c.relname) as tag_index,
  quote_ident(nspname)||'.'||quote_ident(r.relname) as "table",
  i.indisvalid::text as is_valid,
  coalesce(md5(pg_get_indexdef(i.indexrelid)), random()::text) as md5
from
  pg_index i
  join
  pg_class c on c.oid = i.indexrelid
  join
  pg_class r on r.oid = i.indrelid
  join
  pg_namespace n on n.oid = c.relnamespace
where
  c.relnamespace not in (select oid from pg_namespace where nspname like any(array[E'pg\\_%', 'information_schema']));
$sql$
);


/* Stored procedure needed for CPU load - needs plpythonu! */
insert into pgwatch2.metric(m_name, m_pg_version_from, m_sql, m_comment, m_is_helper)
values (
'get_load_average',
9.0,
$sql$
BEGIN;

CREATE EXTENSION IF NOT EXISTS plpythonu;

DROP TYPE IF EXISTS public.load_average CASCADE;

CREATE TYPE public.load_average AS ( load_1min real, load_5min real, load_15min real );

CREATE OR REPLACE FUNCTION public.get_load_average() RETURNS public.load_average AS
$$
from os import getloadavg
return getloadavg()
$$ LANGUAGE plpythonu VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.get_load_average() TO public;

COMMENT ON FUNCTION public.get_load_average() is 'created for pgwatch2';

COMMIT;
$sql$,
'for internal usage - when connecting user is marked as superuser then the daemon will automatically try to create the needed helpers on the monitored db',
true
);

/* Stored procedure needed for fetching stat_statements data - needs pg_stat_statements extension enabled on the machine! */
insert into pgwatch2.metric(m_name, m_pg_version_from, m_sql, m_comment, m_is_helper)
values (
'get_stat_statements',
9.0,
$sql$
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

DO $OUTER$
DECLARE
  l_sproc_text text := $_SQL_$
CREATE OR REPLACE FUNCTION public.get_stat_statements() RETURNS SETOF pg_stat_statements AS
$$
  select s.* from pg_stat_statements s join pg_database d on d.oid = s.dbid and d.datname = current_database()
$$ LANGUAGE sql VOLATILE SECURITY DEFINER;
$_SQL_$;
BEGIN
  IF (regexp_matches(
  		regexp_replace(current_setting('server_version'), '(beta|devel).*', '', 'g'),
        E'\\d+\\.?\\d+?')
      )[1]::double precision > 9.1 THEN   --parameters normalized only from 9.2
    EXECUTE format(l_sproc_text);
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.get_stat_statements() FROM PUBLIC;';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.get_stat_statements() TO pgwatch2';
    EXECUTE 'COMMENT ON FUNCTION public.get_stat_statements() IS ''created for pgwatch2''';
  END IF;
END;
$OUTER$;
$sql$,
'for internal usage - when connecting user is marked as superuser then the daemon will automatically try to create the needed helpers on the monitored db',
true
);

/* Stored procedure wrapper for pg_stat_activity - needed for non-superuser to view session state */
insert into pgwatch2.metric(m_name, m_pg_version_from, m_sql, m_comment, m_is_helper)
values (
'pgbouncer_stats',
0,
'show stats',
'pgbouncer per db statistics',
false
);

/* Stored procedure needed for fetching backend/session data */
insert into pgwatch2.metric(m_name, m_pg_version_from, m_sql, m_comment, m_is_helper)
values (
'get_stat_activity',
9.0,
$sql$

CREATE OR REPLACE FUNCTION public.get_stat_activity() RETURNS SETOF pg_stat_activity AS
$$
  select * from pg_stat_activity where datname = current_database()
$$ LANGUAGE sql VOLATILE SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION public.get_stat_activity() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_stat_activity() TO pgwatch2;
COMMENT ON FUNCTION public.get_stat_activity() IS 'created for pgwatch2';

$sql$,
'for internal usage - when connecting user is marked as superuser then the daemon will automatically try to create the needed helpers on the monitored db',
true
);

/* replication slot info */

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'replication_slots',
9.4,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  slot_name::text as tag_slot_name,
  coalesce(plugin, 'physical')::text as tag_plugin,
  active,
  case when active then 0 else 1 end as non_active_int,
  pg_xlog_location_diff(pg_current_xlog_location(), restart_lsn)::int8 as restart_lsn_lag_b,
  greatest(age(xmin), age(catalog_xmin))::int8 as xmin_age_tx
from
  pg_replication_slots;
$sql$
);


insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'replication_slots',
10,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  slot_name::text as tag_slot_name,
  coalesce(plugin, 'physical')::text as plugin,
  active,
  case when active then 0 else 1 end as non_active_int,
  pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)::int8 as restart_lsn_lag_b,
  greatest(age(xmin), age(catalog_xmin))::int8 as xmin_age_tx
from
  pg_replication_slots;
$sql$
);


insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'psutil_cpu',
9.0,
$sql$

SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  cpu_utilization, load_1m_norm, load_1m, load_5m_norm, load_5m,
  "user", system, idle, iowait, irqs, other
from
  public.get_psutil_cpu();
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'psutil_mem',
9.0,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  total, used, free, buff_cache, available, percent,
  swap_total, swap_used, swap_free, swap_percent
from
  public.get_psutil_mem();
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'psutil_disk',
9.0,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  dir_or_tablespace as tag_dir_or_tablespace,
  path as tag_path,
  total, used, free, percent
from
  public.get_psutil_disk();
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'psutil_disk_io_total',
9.0,
$sql$
SELECT
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  read_count,
  write_count,
  read_bytes,
  write_bytes
from
  public.get_psutil_disk_io_total();
$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'archiver',
9.4,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  archived_count,
  failed_count,
  case when coalesce(last_failed_time, '1970-01-01'::timestamptz) > coalesce(last_archived_time, '1970-01-01'::timestamptz) then 1 else 0 end as is_failing_int,
  extract(epoch from now() - last_failed_time)::int8 as seconds_since_last_failure
from
  pg_stat_archiver
where
  current_setting('archive_mode') in ('on', 'always');
$sql$
);

/* Stored procedure for getting WAL folder size */
insert into pgwatch2.metric(m_name, m_pg_version_from, m_sql, m_comment, m_is_helper)
values (
'get_wal_size',
10,
$sql$

CREATE OR REPLACE FUNCTION public.get_wal_size() RETURNS int8 AS
$$
select (sum((pg_stat_file('pg_wal/' || name)).size))::int8 from pg_ls_waldir()
$$ LANGUAGE sql VOLATILE SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION public.get_wal_size() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_wal_size() TO pgwatch2;
COMMENT ON FUNCTION public.get_wal_size() IS 'created for pgwatch2';

$sql$,
'for internal usage - when connecting user is marked as superuser then the daemon will automatically try to create the needed helpers on the monitored db',
true
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'wal_size',
9.0,
$sql$$sql$
);

insert into pgwatch2.metric(m_name, m_pg_version_from,m_sql)
values (
'wal_size',
10,
$sql$
select
  (extract(epoch from now()) * 1e9)::int8 as epoch_ns,
  public.get_wal_size() as wal_size_b;
$sql$
);
