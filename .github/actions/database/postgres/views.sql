SET search_path TO dams;

-- Change: create table ops_cfg_actions
-- to: create table dams.ops_cfg_actions

CREATE OR REPLACE VIEW V_OPS_CFG_ACTIVE_JOBS AS
        SELECT
          DISTINCT run.jobs_runtime_id as job_id,
          run.batch_id,
          meta.process_area,
          run.runtime_environment,
          coalesce(cast(run.run_parameters ->> 'priority' as int), 0) as priority
        FROM ops_cfg_jobs_runtime run
        JOIN ops_cfg_tbl_meta meta ON run.tbl_meta_id = meta.tbl_meta_id
        LEFT JOIN ops_cfg_trigger trig ON run.jobs_runtime_id = trig.jobs_runtime_id
          AND trig.f_trigger_active = 1
          AND trig.f_trigger = 0
          AND trig.trigger_type = 'IN'
        WHERE trig.trigger_id is NULL
          and run.f_jobs_runtime_active = 1
          AND run.completed = 0
          and run.run_status is null
;



CREATE OR REPLACE VIEW v_ops_cfg_batch_keyvalues
        AS SELECT child.batch_kv_id,
            child.title AS child_title,
            child.value AS child_value,
            par.par_title AS batch_id
          FROM ops_cfg_batch_keyvalues child
          JOIN ( SELECT kvs.title AS par_title,
                    kvs.batch_kv_id AS par_id
                  FROM ops_cfg_batch_keyvalues kvs
                  WHERE kvs.f_batch_kv_active = 1) par ON child.batch_kv_par_id = par.par_id
          WHERE child.f_batch_kv_active = 1
;

CREATE OR REPLACE VIEW v_ops_cfg_fw_keyvalues
        AS SELECT child.fw_kv_id,
            child.title AS child_title,
            child.value AS child_value,
            par.par_title
          FROM ops_cfg_fw_keyvalues child
            JOIN ( SELECT kvs.title AS par_title,
                    kvs.fw_kv_id AS par_id
                  FROM ops_cfg_fw_keyvalues kvs
                  WHERE kvs.f_fw_keyvalues_active = 1) par ON child.fw_kv_par_id = par.par_id
          WHERE child.f_fw_keyvalues_active = 1
;

CREATE OR REPLACE VIEW v_ops_cfg_src_tgt_meta
        as SELECT meta.tbl_meta_id,
            meta.operation,
            meta.category_type,
            meta.service_type,
            meta.main_script,
            meta.text_sql_where,
            meta.text_sql_predicates,
            meta.text_sql_fetchsize,
            meta.source_system,
            meta.pre_script AS meta_pre_script,
            meta.post_script AS meta_post_script,
            meta.process_area,
            meta.tbl_meta_info,
            meta.last_updated,
            dsn.connection_string AS src_connection_string,
            dsn.dsn_setup_info AS src_dsn_setup_info,
            dsn.db_type AS src_db_type,
            dsn.database_name AS src_database_name,
            dsn.schema_name AS src_schema_name,
            dsn2.connection_string AS tgt_connection_string,
            dsn2.dsn_setup_info AS tgt_dsn_setup_info,
            dsn2.db_type AS tgt_db_type,
            dsn.environment AS src_environment,
            dsn2.environment AS tgt_environment,
            tgto.target_object_id,
            tgto.source_system AS tgt_source_system,
            dsn2.database_name AS tgt_database_name,
            dsn2.schema_name AS tgt_schema_name,
            tgto.object_name AS tgt_object_name,
            tgto.pre_script AS tgt_pre_script,
            tgto.post_script AS tgt_post_script,
            tgto.target_object_info,
            meta.f_tbl_meta_active,
            dsn.f_dsn_setup_active,
            mto.f_tbl_meta_tgt_object_active
          FROM ops_cfg_tbl_meta meta
            JOIN ops_cfg_dsn_setup dsn ON meta.source_system = dsn.source_system
            JOIN ops_cfg_tbl_meta_target_object mto ON meta.tbl_meta_id = mto.tbl_meta_id
            JOIN ops_cfg_target_object tgto ON mto.target_object_id = tgto.target_object_id
            JOIN ops_cfg_dsn_setup dsn2 ON tgto.source_system = dsn2.source_system
          WHERE mto.f_tbl_meta_tgt_object_active = 1
;

CREATE OR REPLACE VIEW v_ops_cfg_runtime_meta
        AS SELECT runtime.jobs_runtime_id,
            runtime.actions_id,
            runtime.tbl_meta_id,
            meta.target_object_id,
            runtime.batch_id,
            runtime.action_type,
            runtime.run_info,
            runtime.run_parameters,
            runtime.run_status,
            runtime.run_output,
            runtime.run_start_time,
            runtime.run_end_time,
            runtime.runtime_environment,
            runtime.completed,
            meta.process_area,
            meta.operation,
            meta.category_type,
            meta.service_type,
            meta.main_script,
            meta.meta_pre_script,
            meta.meta_post_script,
            meta.text_sql_where,
            meta.text_sql_predicates,
            meta.text_sql_fetchsize,
            meta.tbl_meta_info,
            meta.tgt_pre_script,
            meta.tgt_post_script,
            meta.source_system,
            meta.src_db_type,
            meta.src_environment,
            meta.src_schema_name,
            meta.src_database_name,
            meta.src_connection_string,
            meta.src_dsn_setup_info,
            meta.tgt_source_system,
            meta.tgt_db_type,
            meta.tgt_environment,
            meta.tgt_schema_name,
            meta.tgt_database_name,
            meta.tgt_connection_string,
            meta.tgt_dsn_setup_info,
            meta.tgt_object_name,
            meta.target_object_info,
            actions.action_name,
            actions.action_call,
            runtime.f_jobs_runtime_active,
            meta.f_tbl_meta_active,
            actions.f_actions_active
          FROM ops_cfg_jobs_runtime runtime
            JOIN ops_cfg_actions actions ON runtime.actions_id = actions.actions_id
            JOIN v_ops_cfg_src_tgt_meta meta ON meta.tbl_meta_id = runtime.tbl_meta_id and runtime.src_environment = meta.src_environment and runtime.tgt_environment = meta.tgt_environment
;


CREATE OR REPLACE VIEW V_OPS_CFG_DEPENDENCY AS
        SELECT
            JOB_IN.JOBS_RUNTIME_ID,
            T_IN.TRIGGER_ID,
            META_IN.OPERATION,
            META_IN.CATEGORY_TYPE,
            META_IN.MAIN_SCRIPT,
            TGT_IN.SOURCE_SYSTEM,
            TGT_IN.OBJECT_NAME,
            JOB_IN.BATCH_ID,
            JOB_IN.RUN_STATUS,
            JOB_IN.RUN_OUTPUT ->> 'web_link' as WEB_LINK,
            META_IN.TBL_META_INFO ->> 'yml_configuration_file' as CONFIGURATION_FILE,
            JOB_IN.F_JOBS_RUNTIME_ACTIVE,
            T_IN.SECONDARY_OPSCONFIGID as DEP_OPSCONFIGID,
            JOB_OUT.JOBS_RUNTIME_ID as DEP_JOBS_RUNTIME_ID,
            T_IN.SECONDARY_TRIGGER_ID as DEP_TRIGGER_ID,
            META_OUT.MAIN_SCRIPT as DEP_MAIN_SCRIPT,
            META_OUT.TBL_META_INFO ->> 'yml_configuration_file' as DEP_CONFIGURATION_FILE,
            TGT_OUT.SOURCE_SYSTEM as DEP_TGT_SOURCE_SYSTEM,
            TGT_OUT.OBJECT_NAME as DEP_TGT_OBJECT_NAME,
            JOB_OUT.BATCH_ID as DEP_BATCH_ID,
            JOB_OUT.RUN_STATUS as DEP_RUN_STATUS,
            JOB_OUT.RUN_OUTPUT ->> 'web_link' as DEP_WEB_LINK,
            JOB_OUT.F_JOBS_RUNTIME_ACTIVE as F_DEP_JOBS_RUNTIME_ACTIVE,
            T_IN.TRIGGER_INFO,
            T_IN.F_TRIGGER,
            T_IN.LAST_TRIGGERED
        FROM OPS_CFG_JOBS_RUNTIME JOB_IN
        JOIN OPS_CFG_TBL_META META_IN on JOB_IN.TBL_META_ID = META_IN.TBL_META_ID
        JOIN OPS_CFG_TBL_META_TARGET_OBJECT MAP_IN on META_IN.TBL_META_ID = MAP_IN.TBL_META_ID
        JOIN OPS_CFG_TARGET_OBJECT TGT_IN on TGT_IN.TARGET_OBJECT_ID = MAP_IN.TARGET_OBJECT_ID
        JOIN ops_cfg_trigger T_IN ON T_IN.JOBS_RUNTIME_ID = JOB_IN.JOBS_RUNTIME_ID
        AND T_IN.TRIGGER_TYPE = 'IN'
        LEFT JOIN ops_cfg_trigger T_OUT ON T_IN.SECONDARY_TRIGGER_ID = T_OUT.TRIGGER_ID
        AND T_OUT.TRIGGER_TYPE = 'OUT'
        AND T_OUT.SECONDARY_OPSCONFIGID = T_IN.SECONDARY_OPSCONFIGID
        LEFT JOIN OPS_CFG_JOBS_RUNTIME JOB_OUT ON T_OUT.JOBS_RUNTIME_ID = JOB_OUT.JOBS_RUNTIME_ID
        LEFT JOIN OPS_CFG_TBL_META META_OUT on JOB_OUT.TBL_META_ID = META_OUT.TBL_META_ID
        LEFT JOIN OPS_CFG_TBL_META_TARGET_OBJECT MAP_OUT on META_OUT.TBL_META_ID = MAP_OUT.TBL_META_ID
        LEFT JOIN OPS_CFG_TARGET_OBJECT TGT_OUT on TGT_OUT.TARGET_OBJECT_ID = MAP_OUT.TARGET_OBJECT_ID
        where T_IN.F_TRIGGER_ACTIVE = 1
;


CREATE OR REPLACE VIEW v_ops_cfg_runtime_meta_hist
        AS SELECT runtime.jobs_runtime_id,
            runtime.actions_id,
            runtime.tbl_meta_id,
            meta.target_object_id,
            runtime.batch_id,
            runtime.action_type,
            runtime.run_info,
            runtime.run_parameters,
            runtime.run_status,
            runtime.run_output,
            runtime.run_start_time,
            runtime.run_end_time,
            runtime.runtime_environment,
            runtime.completed,
            meta.process_area,
            meta.operation,
            meta.category_type,
            meta.service_type,
            meta.main_script,
            meta.meta_pre_script,
            meta.meta_post_script,
            meta.text_sql_where,
            meta.text_sql_predicates,
            meta.text_sql_fetchsize,
            meta.tbl_meta_info,
            meta.tgt_pre_script,
            meta.tgt_post_script,
            meta.source_system,
            meta.src_db_type,
            meta.src_environment,
            meta.src_schema_name,
            meta.src_database_name,
            meta.src_connection_string,
            meta.src_dsn_setup_info,
            meta.tgt_source_system,
            meta.tgt_db_type,
            meta.tgt_environment,
            meta.tgt_schema_name,
            meta.tgt_database_name,
            meta.tgt_connection_string,
            meta.tgt_dsn_setup_info,
            meta.tgt_object_name,
            meta.target_object_info,
            actions.action_name,
            actions.action_call,
            runtime.f_jobs_runtime_active,
            meta.f_tbl_meta_active,
            actions.f_actions_active
          FROM ops_cfg_jobs_runtime_hist runtime
            JOIN ops_cfg_actions actions ON runtime.actions_id = actions.actions_id
            JOIN v_ops_cfg_src_tgt_meta meta ON meta.tbl_meta_id = runtime.tbl_meta_id and runtime.src_environment = meta.src_environment and runtime.tgt_environment = meta.tgt_environment
;


CREATE OR REPLACE VIEW v_ops_cfg_producer_consumer as
        SELECT p.produced_object_id
              , produced_object_type
              , produced_object
              , p.jobs_runtime_id as producer_jobs_runtime_id
              , p.job_execution_id as producer_job_execution_id
              , r.batch_id as producer_batch_id
              , produced_timestamp
              , business_date
              , c.opsconfigid as consumer_opsconfig_id
              , c.batch_id as consumer_batch_id
              , c.jobs_runtime_id as consumer_jobs_runtime_id
              , c.job_execution_id as consumed_job_execution_id
        FROM ops_cfg_produced_object p
        JOIN ops_cfg_jobs_runtime r on p.jobs_runtime_id = r.jobs_runtime_id
        LEFT JOIN ops_cfg_consumed_object c
        ON p.produced_object_id = c.produced_object_id and f_consumed_object_active = 1
        WHERE f_produced_object_active = 1
;


CREATE OR REPLACE VIEW V_OPS_CFG_PRODUCED_OBJECT_NORMALIZED AS
      SELECT
        r.PRODUCED_OBJECT_ID,
        r.PRODUCED_OBJECT_TYPE,
        r.PRODUCED_OBJECT,
        r.BATCH_EXECUTION_ID,
        r.JOBS_RUNTIME_ID,
        r.JOB_EXECUTION_ID,
        r.PRODUCED_TIMESTAMP,
        r.BUSINESS_DATE,
        r.PRODUCED_OBJECT_INFO,
        r.F_PURGED,
        r.F_PRODUCED_OBJECT_ACTIVE,
        r.DATA_CENTER,
        r.REPLICATION_STATUS,
        CASE
          WHEN PRODUCED_OBJECT_TYPE = 'hdfs' then substring(PRODUCED_OBJECT from 'hdfs://\w*(.*)')
          WHEN PRODUCED_OBJECT_TYPE = 's3' then substring(PRODUCED_OBJECT from 's3a:/(.*)')
          WHEN PRODUCED_OBJECT_TYPE = 'ozone' then substring(PRODUCED_OBJECT from 'ofs3*:/(.*)')
        ELSE PRODUCED_OBJECT END as PRODUCED_OBJECT_NORMALIZED
      FROM OPS_CFG_PRODUCED_OBJECT r
;


CREATE OR REPLACE VIEW V_OPS_CFG_REPLICATION AS
      select
        src.DATA_CENTER,
        src.PRODUCED_OBJECT_TYPE,
        src.PRODUCED_OBJECT_ID,
        src.PRODUCED_OBJECT,
        src.PRODUCED_OBJECT_NORMALIZED,
        src.PRODUCED_OBJECT_INFO,
        src.BATCH_EXECUTION_ID,
        src.JOBS_RUNTIME_ID,
        src.JOB_EXECUTION_ID,
        src.PRODUCED_TIMESTAMP,
        src.BUSINESS_DATE,
        src.F_PURGED as F_PURGED_SRC,
        coalesce( repl.F_PURGED , 0 )as F_PURGED_REPL,
        src.REPLICATION_STATUS
      from V_OPS_CFG_PRODUCED_OBJECT_NORMALIZED src
      full outer join V_OPS_CFG_PRODUCED_OBJECT_NORMALIZED repl
        on src.PRODUCED_OBJECT_NORMALIZED = repl.PRODUCED_OBJECT_NORMALIZED
        and src.DATA_CENTER != repl.DATA_CENTER
      join V_OPS_CFG_RUNTIME_META m on src.JOBS_RUNTIME_ID = m.JOBS_RUNTIME_ID
      where src.data_center is not null
        and src.F_PRODUCED_OBJECT_ACTIVE = 1
        and m.target_object_info ->> 'replication' = 'true'
        and src.f_purged = 0
;


-- CREATE OR REPLACE VIEW V_OPS_CFG_ASSET_OWNER AS
--   SELECT 
--     a.JOBS_RUNTIME_ID,
--     b.BATCH_ID,
--     a.SQUAD_NAME,
--     a.SOURCE_POC,
--     a.TARGET_USER,
--     a.SOURCE_ASSIGNMENT_GROUP,
--     a.INCIDENT_PRIORITY,
--     a.DEPLOYMENT_DATE,
--     a.OPS_HANDOVER_DATE,
--     a.DEPLOYMENT_LAST_MODIFIED,
--     b.F_JOBS_RUNTIME_ACTIVE
--   FROM OPS_CFG_ASSET_OWNER a
--   JOIN OPS_CFG_JOBS_RUNTIME b
--   ON a.JOBS_RUNTIME_ID = b.JOBS_RUNTIME_ID
--   WHERE a.F_ASSET_OWNER_ACTIVE = 1
--   ;