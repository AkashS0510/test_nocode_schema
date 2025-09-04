variable "character_set_name" {
  type        = string
  default     = null
  description = "(Optional) The character set name to use for DB encoding in Oracle and Microsoft SQL instances (collation). This can't be changed."
}

variable "db_name" {
  type        = list(string)
  default     = ["ORCL", "DB1", "DB2"]
  description = <<DESCRIPTION

    (Optional) The name of the database to create when the DB instance is created.
    If this parameter is not specified, no database is created in the DB instance. Note that this does not apply for Oracle or SQL Server engines.
    See the AWS documentation for more details on what applies for those engines.
    If you are providing an Oracle db name, it needs to be in all upper case. Cannot be specified for a replica.
    
  DESCRIPTION 
}

variable "engine_version" {
  type        = string
  default     = "19.0.0.0.ru-2024-04.rur-2024-04.r1"
  description = <<DESCRIPTION

    (Optional) The engine version to use. If `auto_minor_version_upgrade` is enabled, you can provide a prefix of the version such as 8.0 (for 8.0.36).
    The actual engine version used is returned in the `attribute engine_version_actual`, see Attribute Reference below.
        
  DESCRIPTION
}

variable "license_model" {
  type        = string
  default     = "bring-your-own-license"
  description = <<DESCRIPTION

    (Optional, but required for some DB engines, i.e., Oracle SE1) License model information for this DB instance.
    Valid values for this field are as follows:
    - RDS for MariaDB: `general-public-license`
    - RDS for Microsoft SQL Server: `license-included`
    - RDS for MySQL: `general-public-license`
    - RDS for Oracle: `bring-your-own-license` | `license-included`
    - RDS for PostgreSQL: `postgresql-license`
        
  DESCRIPTION
}

variable "instance_class" {
  type        = string
  default     = "db.m5.large"
  description = <<DESCRIPTION

    (Required) The instance type of the RDS instance.
    [Available Instance types for Oracle](https://aws.amazon.com/de/rds/oracle/instance-types/)
        
  DESCRIPTION
}

variable "identifier" {
  type        = string
  default     = "oracle-db"
  description = "(Optional) The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier. Required if `restore_to_point_in_time` is specified."
}

variable "engine" {
  type        = string
  default     = "oracle-ee-cdb"
  description = <<DESCRIPTION

    (Required unless a `snapshot_identifier?  or `replicate_source_db` is provided) The database engine to use.
    For supported values, see the Engine parameter in API action [CreateDBInstance](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html).
    Note that for Amazon Aurora instances the engine must match the [DB cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster's engine'.
    For information on the difference between the available Aurora MySQL engines see [Comparison between Aurora MySQL 1 and Aurora MySQL 2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraMySQLReleaseNotes/AuroraMySQL.Updates.20180206.html) in the Amazon RDS User Guide.
        
  DESCRIPTION 
}

variable "port" {
  type        = number
  default     = 1521
  description = "(Optional) The port on which the DB accepts connections."
}

variable "maintenance_window" {
  type        = string
  default     = "fri:22:26-fri:22:56"
  description = <<DESCRIPTION

    (Optional) The window to perform maintenance in.
    Syntax:
    "ddd:hh24:mi-ddd:hh24:mi". Eg: "Mon:00:00-Mon:03:00".
    See [RDS Maintenance Window docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#AdjustingTheMaintenanceWindow) for more information.
        
  DESCRIPTION
}

variable "backup_window" {
  type        = string
  default     = "22:56-23:26"
  description = "(Optional) The daily time range (in UTC) during which automated backups are created if they are enabled. Must not overlap with `maintenance_window`."
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "(Optional) The days to retain backups for. Must be between `0` and `35`."
}

variable "availability_zone" {
  type        = string
  default     = ""
  description = "(Optional) The AZ for the RDS instance"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = false
  description = "(Optional) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
}

variable "allocated_storage" {
  type        = number
  default     = 200
  description = <<DESCRIPTION

    (Required unless a snapshot_identifier or replicate_source_db is provided) The allocated storage in gibabytes.
    If `max_allocated_storage` is configured, this argument represents the initial storage allocation and differences from the configuration will be ignored automatically when Storage Autoscaling occurs.
    If `replicate_source_db` is set, the value is ignored during the creation of the instance.
    
  DESCRIPTION
}

variable "max_allocated_storage" {
  type        = number
  default     = 1000
  description = <<DESCRIPTION

    (Optional) When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. 
    Configuring this will automatically ignore differences to `allocated_storage`.
    Must be greater than or equal to `allocated_storage` or `0` to disable Storage Autoscaling.
        
  DESCRIPTION
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 0
  description = <<DESCRIPTION

    (Optional) Amount of time in days to retain Performance Insights data.
    Valid values are 7, 731 (2 years) or a multiple of 31.
    When specifying `performance_insights_retention_period`, `performance_insights_enabled` needs to be set to true.
        
  DESCRIPTION
}

variable "monitoring_role_arn" {
  type        = string
  default     = ""
  description = <<DESCRIPTION

    (Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs.
    You can find more information on the [AWS Documentation what IAM permissions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.html) are needed to allow Enhanced Monitoring for RDS Instances.
        
  DESCRIPTION
}

/*
    db_option_group variables
*/
variable "db_option_group_major_engine_version" {
  type        = string
  default     = "19"
  description = "(Required) Specifies the major version of the engine that this option group should be associated with."
}

variable "db_option_group_options" {
  type = map(object({
    option_name                    = string
    port                           = optional(number)
    version                        = optional(string)
    db_security_group_memberships  = optional(list(string))
    vpc_security_group_memberships = optional(list(string))
    option_settings = optional(map(object({
      name  = string
      value = string
    })))
  }))
  default = {
    efs_integration = {
      option_name = "EFS_INTEGRATION"
      option_settings = {
        use_iam_role = {
          name  = "USE_IAM_ROLE"
          value = "FALSE"
        }
        efs_id = {
          name  = "EFS_ID"
          value = "fs-0085d7582747bae0c"
        }
      }
    }
  }
  description = <<DESCRIPTION

    (Optional) The options to apply. See [option Block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_option_group#option-block) below for more details.

    option_name                            = (Required) Name of the option (e.g., MEMCACHED)
    port                                   = (Optional) Port number when connecting to the option (e.g., 11211).
    version                                = (Optional) Version of the option (e.g., 13.1.0.0).
    db_security_group_memberships          = (Optional) List of DB Security Groups for which the option is enabled.
    vpc_security_group_memberships         = (Optional) List of VPC Security Groups for which the option is enabled.
    option_settings                        = (Optional) The option settings to apply. See [option_settings Block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_option_group#option_settings-block) below for more details.
      name                                 = (Required) Name of the setting.
      value                                = (Required) Value of the setting.
    
  DESCRIPTION
}

/*
    db_parameter_group variables
*/
variable "db_parameter_group_family" {
  type        = string
  default     = "oracle-ee-cdb-19"
  description = " (Required, Forces new resource) The family of the DB parameter group."
}

variable "db_parameter_group_parameters" {
  type = map(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = {
    parameter_1 = {
      name         = "_add_col_optim_enabled"
      value        = "FALSE"
      apply_method = "immediate"
    }
    parameter_2 = {
      name         = "_allow_insert_with_update_check"
      value        = "FALSE"
      apply_method = "immediate"
    }
    parameter_3 = {
      name         = "_awr_mmon_cpuusage"
      value        = "TRUE"
      apply_method = "immediate"
    }
  }
  description = <<DESCRIPTION

    (Optional) The DB parameters to apply. 
    See [parameter Block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group#parameter-block) below for more details. 
    Note that parameters may differ from a family to an other.

    name                = (Required) The name of the DB parameter.
    value               = (Required) The value of the DB parameter.
    apply_method        = (Optional) "immediate" (default), or "pending-reboot". Some engines can't apply some parameters without a reboot, and you will need to specify "pending-reboot" here.
    
  DESCRIPTION
}

variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "prod", "test"], var.environment)
    error_message = "The `environment` must be one of the following: dev, prod, test."
  }
  description = "Choose for which environment to use `db_subnet_group_name`"
}

variable "recovery_window_in_days" {
  type        = number
  default     = 0
  description = <<DESCRIPTION

      (Optional) Number of days that AWS Secrets Manager waits before it can delete the secret.
      This value can be `0` to force deletion without recovery or range from `7` to `30` days.
      The default value is `30`.

  DESCRIPTION 
}

variable "password_length" {
  type        = number
  default     = 24
  description = "The length of the string desired."
}

variable "storage_throughput" {
  type        = number
  default     = null
  description = <<DESCRIPTION

    (Optional) The storage throughput value for the DB instance. Can only be set when `storage_type` is "gp3".
    Cannot be specified if the allocated_storage value is below a per-`engine` threshold.
        
  DESCRIPTION
}

variable "iops" {
  type        = string
  default     = null
  description = <<DESCRIPTION

    (Optional) The amount of provisioned IOPS. Setting this implies a `storage_type` of "io1" or "io2".
    Can only be set when `storage_type` is "io1", "io2 or "gp3".
    Cannot be specified for gp3 storage if the `allocated_storage` value is below a per-`engine` threshold.
        
  DESCRIPTION
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window."
}

/*
  StackGuardian cannot handle this special -- #$%&_=+?@- -- at deployment.
  If I test it locally it works without problems
*/
variable "override_special" {
  type        = string
  default     = "#$%&@"
  description = "Supply your own list of special characters to use for string generation. This overrides the default character list in the special argument."
}

/*
    Tagging variables specific for RE
*/
variable "reserviceoffering" {
  type        = string
  default     = ""
  description = "The service offering name from CMBD in Service Now"
}

variable "rebereitschaft" {
  type        = bool
  default     = false
  description = "Choose if this service is on-call service or not."
}

variable "redbhaconfig" {
  type        = string
  default     = ""
  description = "Choose which DB High Availability (HA) Configuration you want use for `redbhaconfig`"
}

variable "reapplication" {
  type        = string
  default     = ""
  description = "The CMDB CI application name"
}

/*
  AWS account specific variables
*/
variable "role_arn" {
  type        = string
  description = "Role to authenticate in AWS account & create resources"
}

variable "external_id" {
  type        = string
  description = "External ID of the IAM role"
}

/*
  Custom
*/
variable "debug_mode" {
  type    = string
  default = "False"
  validation {
    condition     = contains(["False", "True"], var.debug_mode)
    error_message = "The `debug_mode` must be one of the following: False, True."
  }
  description = <<DESCRIPTION

    (Optional) Choose in which debug level should run the python script for managing RDS tenant databases.
    If "False" the DEBUG_MODE is in `WARNING` = less verbose
    If "True" the DEBUG_MODE is in `DEBUG` = very verbose
        
  DESCRIPTION
}