SET search_path TO dams;

-- Change: create table ops_cfg_actions
-- to: create table dams.ops_cfg_actions

create table if not exists ops_cfg_actions (
   actions_id integer NOT NULL,
   action_name varchar(4000) NOT NULL,
   action_call json NULL,
   f_actions_active integer NOT NULL,
   CONSTRAINT ops_cfg_actions_pkey PRIMARY KEY (actions_id),
   CONSTRAINT ops_cfg_actions_action_name_unique UNIQUE (action_name)
);

create table if not exists ops_cfg_dsn_setup (
   dsn_setup_id integer NOT NULL,
   source_system varchar(1000) NOT NULL,
   connection_string varchar(4000) NULL,
   environment varchar(255) NOT NULL,
   database_name varchar(200) NOT NULL,
   schema_name varchar(200) NOT NULL,
   db_type varchar(200) NOT NULL,
   dsn_setup_info JSON NULL,
   f_dsn_setup_active integer NOT NULL,

   CONSTRAINT ops_cfg_dsn_setup_pkey PRIMARY KEY (dsn_setup_id),
   CONSTRAINT ops_cfg_dsn_setup_source_system_environment_unique UNIQUE (source_system, environment)
);

create table if not exists ops_cfg_tbl_meta (
   tbl_meta_id integer NOT NULL,
   operation varchar(500) NOT NULL,
   category_type varchar(500) NOT NULL,
   service_type varchar(255) NOT NULL,
   main_script text NOT NULL,
   text_sql_where text NULL,
   text_sql_predicates text NULL,
   text_sql_fetchsize integer NULL,
   source_system varchar(200) NOT NULL,
   pre_script json NULL,
   post_script json NULL,
   process_area varchar(512) NOT NULL,
   f_tbl_meta_active integer NOT NULL,
   tbl_meta_info json NULL,
   last_updated timestamp NULL,

   CONSTRAINT ops_cfg_tbl_meta_pkey PRIMARY KEY (tbl_meta_id)
);

create table if not exists ops_cfg_jobs_runtime (
   jobs_runtime_id integer NOT NULL,
   actions_id integer NOT NULL,
   tbl_meta_id integer NOT NULL,
   batch_id varchar(255) NOT NULL,
   action_type json NULL,
   run_info json NULL,
   src_environment varchar(4000) not NULL,
   tgt_environment varchar(4000) not NULL,
   run_parameters json NULL,
   run_status varchar(4000) NULL,
   run_output json NULL,
   run_start_time timestamp NULL,
   run_end_time timestamp NULL,
   runtime_environment varchar(255) NOT NULL,
   f_jobs_runtime_active integer NOT NULL,
   completed integer NOT NULL,

   CONSTRAINT ops_cfg_jobs_runtime_pkey PRIMARY KEY (jobs_runtime_id),
   CONSTRAINT ops_cfg_jobs_runtime_tbl_meta_id_fkey FOREIGN KEY (tbl_meta_id) REFERENCES ops_cfg_tbl_meta(tbl_meta_id),
   CONSTRAINT ops_cfg_jobs_runtime_actions_id_fkey FOREIGN KEY (actions_id) REFERENCES ops_cfg_actions(actions_id)
);

create table if not exists ops_cfg_jobs_runtime_hist (
   jobs_runtime_id integer NOT NULL,
   actions_id integer NOT NULL,
   tbl_meta_id integer NOT NULL,
   batch_id varchar(255) NOT NULL,
   action_type json NULL,
   run_info json NULL,
   src_environment varchar(4000) not NULL,
   tgt_environment varchar(4000) not NULL,
   run_parameters json NULL,
   run_status varchar(4000) NULL,
   run_output json NULL,
   run_start_time timestamp NULL,
   run_end_time timestamp NULL,
   runtime_environment varchar(255) NOT NULL,
   f_jobs_runtime_active integer NOT NULL,
   completed integer NOT NULL,

   CONSTRAINT ops_cfg_jobs_runtime_hist_tbl_meta_id_fkey FOREIGN KEY (tbl_meta_id) REFERENCES ops_cfg_tbl_meta(tbl_meta_id),
   CONSTRAINT ops_cfg_jobs_runtime_hist_actions_id_fkey FOREIGN KEY (actions_id) REFERENCES ops_cfg_actions(actions_id)
);

create table if not exists ops_cfg_target_object (
   target_object_id integer NOT NULL,
   object_name varchar(2000) NULL,
   source_system varchar(200) NULL,
   pre_script json NULL,
   post_script json NULL,
   target_object_info json NULL,
   f_target_object_active integer NULL,
   CONSTRAINT ops_cfg_target_object_pkey PRIMARY KEY (target_object_id)
);

create table if not exists ops_cfg_tbl_meta_target_object (
   tbl_meta_id integer NULL,
   target_object_id integer NULL,
   f_tbl_meta_tgt_object_active integer NULL,
   CONSTRAINT ops_cfg_tbl_meta_target_object_tbl_meta_id_fkey FOREIGN KEY (tbl_meta_id) REFERENCES ops_cfg_tbl_meta(tbl_meta_id),
   CONSTRAINT ops_cfg_tbl_meta_target_object_target_object_id_fkey FOREIGN KEY (target_object_id) REFERENCES ops_cfg_target_object(target_object_id),
   CONSTRAINT ops_cfg_tbl_meta_target_object_meta_id_unique UNIQUE (tbl_meta_id)
);

create table if not exists ops_cfg_fw_keyvalues (
   fw_kv_id integer NOT NULL,
   fw_kv_par_id integer NULL,
   title varchar(4000) NULL,
   value varchar(4000) NULL,
   f_fw_keyvalues_active integer NULL,
   CONSTRAINT ops_cfg_fw_keyvalues_pkey PRIMARY KEY (fw_kv_id),
   CONSTRAINT ops_cfg_fw_keyvalues_fk_fw_keyvalues_par_id FOREIGN KEY (fw_kv_par_id) REFERENCES ops_cfg_fw_keyvalues(fw_kv_id),
   CONSTRAINT ops_cfg_fw_keyvalues_par_title_unique unique (fw_kv_par_id, title)
);

create table if not exists ops_cfg_batch_keyvalues (
   batch_kv_id integer NOT NULL,
   batch_kv_par_id integer NULL,
   title varchar(4000) NULL,
   value varchar(4000) NULL,
   f_batch_kv_active integer NULL,
   CONSTRAINT ops_cfg_batch_keyvalues_pkey PRIMARY KEY (batch_kv_id),
   CONSTRAINT ops_cfg_batch_keyvalues_fk_par_id FOREIGN KEY (batch_kv_par_id) REFERENCES ops_cfg_batch_keyvalues(batch_kv_id),
   CONSTRAINT ops_cfg_run_id_keyvalues_par_title_unique unique (batch_kv_par_id, title)
);

create table if not exists ops_cfg_trigger (
   trigger_id  integer NOT NULL,
   trigger_type varchar(255) NOT NULL,
   jobs_runtime_id integer NOT NULL,
   secondary_opsconfigid varchar(255) NOT NULL,
   secondary_trigger_id integer NOT NULL,
   f_trigger integer NOT NULL,
   trigger_info json NULL,
   f_trigger_active integer NULL,
   last_triggered timestamp NULL,
   f_optional integer DEFAULT 0,
   settings json null,
   CONSTRAINT ops_cfg_triggers_pkey PRIMARY KEY (trigger_id),
   CONSTRAINT ops_cfg_triggers_ops_cfg_jobs_runtime_id_fkey FOREIGN KEY (jobs_runtime_id) REFERENCES ops_cfg_jobs_runtime(jobs_runtime_id)
);

create table if not exists ops_cfg_scheduling (
   scheduling_id integer NOT NULL,
   scheduling_type varchar(255) NOT NULL,
   scheduling_value varchar(255) NOT NULL,
   cron_statement varchar(255) NULL,
   scheduling_info json null,
   last_updated timestamp  DEFAULT CURRENT_TIMESTAMP,
   f_scheduling_active integer NULL,
   CONSTRAINT ops_cfg_scheduling_pk_test PRIMARY KEY (scheduling_id)
);

create table if not exists ops_cfg_produced_object (
   produced_object_id SERIAL,
   produced_object_type varchar(255) NOT NULL,
   produced_object text,
   batch_execution_id varchar(255) NOT NULL,
   jobs_runtime_id integer NOT NULL,
   job_execution_id varchar(255),
   produced_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   business_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   data_center varchar(255),
   replication_status varchar(255),
   produced_object_info json,
   f_purged integer DEFAULT 0,
   f_produced_object_active integer DEFAULT 1,
   CONSTRAINT ops_cfg_produced_object_id_pk PRIMARY KEY (produced_object_id),
   CONSTRAINT ops_cfg_produced_object_jobs_runtime_id_fkey FOREIGN KEY (jobs_runtime_id) REFERENCES ops_cfg_jobs_runtime(jobs_runtime_id)
);

create table if not exists ops_cfg_consumed_object (
   consumed_object_id  SERIAL,
   produced_object_id integer NOT NULL,
   opsconfigid varchar(255),
   batch_id varchar(255),
   batch_execution_id varchar(255) NOT NULL,
   jobs_runtime_id integer NOT NULL,
   job_execution_id varchar(255) NULL,
   consumed_timestamp TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
   consumed_object_info json,
   f_consumed_object_active integer DEFAULT 1,
   CONSTRAINT ops_cfg_consumed_object_id_pk PRIMARY KEY (consumed_object_id),
   CONSTRAINT ops_cfg_consumed_object_produced_object_id_fkey FOREIGN KEY (produced_object_id) REFERENCES ops_cfg_produced_object(produced_object_id)
);

create table if not exists ops_cfg_version (
   version_id integer NOT NULL,
   version_number varchar(255) NOT NULL,
   version_description json NOT NULL,
   last_updated timestamp  DEFAULT CURRENT_TIMESTAMP,
   CONSTRAINT ops_cfg_version_id_pk PRIMARY KEY (version_id),
   CONSTRAINT ops_cfg_version_version_number_unique UNIQUE (version_number)
);

create table if not exists ops_cfg_alerting (
   alerting_id integer NOT NULL,
   alert_type varchar(255) NOT NULL,
   alert_target varchar(255) NOT NULL,
   alert_info json NOT NULL,
   f_alerting_active integer DEFAULT 1,
   CONSTRAINT ops_cfg_alerting_pk PRIMARY KEY (alerting_id)
);

create table if not exists ops_cfg_operations (
   operations_id serial,
   operation_user varchar(255)  NOT NULL,
   operation_type varchar(255)  NOT NULL,
   args json  NOT NULL,
   operation_result varchar(255)  NOT NULL,
   operations_timestamp timestamp DEFAULT CURRENT_TIMESTAMP,
   operations_info json,
   CONSTRAINT ops_cfg_operations_pkey PRIMARY KEY (operations_id)
);

create table if not exists ops_cfg_restart_queue (
   restart_queue_id SERIAL,
   restart_user varchar(255)  NOT NULL,
   restart_value varchar(255)  NOT NULL,
   business_date varchar(255),
   args json  NOT NULL,
   restart_queue_info json,
   restart_queue_timestamp timestamp default current_timestamp,
   f_restart_queue_active integer default 1,
   CONSTRAINT ops_cfg_restart_queue_pkey PRIMARY KEY (restart_queue_id)
);

create table if not exists ops_cfg_jobs_backup (
   jobs_runtime_id numeric(10) NOT NULL,
   tbl_meta_id numeric(10) NOT NULL,
   batch_id varchar(255) NOT NULL,
   src_environment varchar(4000) NOT NULL,
   tgt_environment varchar(4000) NOT NULL,
   run_status varchar(4000) NULL,
   run_output text NULL,
   runtime_environment varchar(255) NOT NULL,
   main_script text NOT NULL,
   process_area varchar(255) NOT NULL,
   source_system varchar(255) NOT NULL,
   category_type varchar(255) NOT NULL,
   operation varchar(255) NOT NULL,
   service_type varchar(255) NOT NULL
);

create table if not exists ops_cfg_produced_object_backup (
   produced_object_id integer,
   produced_object_type varchar(255) NOT NULL,
   produced_object text,
   batch_execution_id varchar(255) NOT NULL,
   jobs_runtime_id integer NOT NULL,
   job_execution_id varchar(255),
   produced_timestamp timestamp,
   business_date timestamp,
   data_center varchar(255),
   replication_status varchar(255),
   produced_object_info json,
   f_purged integer,
   f_produced_object_active integer
);

create table if not exists ops_cfg_asset_owner (
   asset_owner_id serial,
   jobs_runtime_id integer NOT NULL,
   squad_name varchar(255),
   source_poc varchar(255),
   target_user varchar(255),
   source_assignment_group varchar(100),
   incident_priority varchar(10),
   asset_owner_info json,
   f_asset_owner_active integer DEFAULT 1,
   constraint ops_cfg_asset_owner_pkey primary key (asset_owner_id),
   constraint ops_cfg_asset_owner_jobs_runtime_id_fkey foreign key (jobs_runtime_id) references ops_cfg_jobs_runtime(jobs_runtime_id)
);