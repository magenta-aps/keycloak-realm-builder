# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
terraform {
  backend "pg" {}
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.3.1"
    }
  }
}

variable "keycloak_admin_client_id" {
  type        = string
  description = ""
  default     = "admin-cli"
}

variable "keycloak_admin_username" {
  type        = string
  description = ""
  default     = "admin"
}

variable "keycloak_admin_password" {
  type        = string
  description = ""
}

variable "keycloak_url" {
  type        = string
  description = ""
  default     = "http://localhost:8081"
}

variable "keycloak_realm_display_name" {
  type        = string
  description = ""
}

variable "keycloak_mo_client_redirect_uri" {
  type        = list(string)
  description = ""
}

variable "keycloak_mo_client_web_origin" {
  type        = list(string)
  description = ""
}

variable "keycloak_orgviewer_client_enabled" {
  type        = bool
  description = ""
  default     = false
}

variable "keycloak_orgviewer_client_secret" {
  type        = string
  description = ""
  sensitive   = true
}

variable "keycloak_realm_users" {
  type = list(object({
    username  = string
    password  = string
    firstname = string
    lastname  = string
    email     = string
    uuid      = optional(string, null)
    roles     = list(string)
    enabled   = bool
  }))
  description = ""
}

variable "keycloak_idp_enable" {
  type        = bool
  description = ""
  default     = false
}

# NOT IMPLEMENTED
variable "keycloak_idp_encryption_key" {
  type        = string
  description = ""
  default     = ""
}

variable "keycloak_idp_signing_certificate" {
  type        = string
  description = ""
}

variable "keycloak_idp_signed_requests" {
  type        = bool
  description = ""
}

variable "keycloak_idp_name_id_policy_format" {
  type        = string
  description = ""
}

variable "keycloak_idp_entity_id" {
  type        = string
  description = ""
}

variable "keycloak_idp_logout_service_url" {
  type        = string
  description = ""
}

variable "keycloak_idp_signon_service_url" {
  type        = string
  description = ""
}

variable "keycloak_idp_clock_skew" {
  type        = string
  description = ""
}

variable "keycloak_ssl_required_mo" {
  type        = string
  description = ""
  default     = "all"
}

variable "keycloak_mo_token_lifespan" {
  type        = number
  description = ""
}

variable "keycloak_orgviewer_token_lifespan" {
  type        = number
  description = ""
}

provider "keycloak" {
  client_id = var.keycloak_admin_client_id
  username  = var.keycloak_admin_username
  password  = var.keycloak_admin_password
  url       = var.keycloak_url
  base_path = "/auth"
}

# Realms
resource "keycloak_realm" "mo" {
  realm        = "mo"
  enabled      = true
  display_name = var.keycloak_realm_display_name
  ssl_required = var.keycloak_ssl_required_mo
}

# TODO: Fetch these from OS2mo
locals {
  # TODO: you can remove "auditlog" once #64270 is deploed everywhere
  collections = [
    "address", "association", "auditlog", "accesslog", "class",
    "configuration", "employee", "engagement_association", "engagement",
    "event", "event_listener", "event_namespace", "facet", "file", "health",
    "itsystem", "ituser", "kle", "leave", "manager", "owner", "org",
    # TODO: You can remove "role" once #59798 is deployed everywhere
    "org_unit", "registration", "related_unit", "role", "rolebinding", "version"
  ]
  permission_types = [
    "read", "create", "update", "terminate", "delete", "refresh"
  ]
}
locals {
  os2mo_permission = merge({
    for tup in setproduct(local.permission_types, local.collections) :
    "${tup[0]}_${tup[1]}" => "${tup[0]}-access for ${tup[1]}"
    }, {
    # Files
    list_files     = "List files stored in MO"
    download_files = "Download files stored in MO"
    upload_files   = "Upload files to MO"

    # Events
    send_event        = "Send events"
    fetch_event       = "Fetch events"
    acknowledge_event = "Acknowledge events"
    silence_event     = "Silence events"
    unsilence_event   = "Unsilence events"
    read_event_all    = "Read all events, regardless of owner"
  })
}

resource "keycloak_role" "roles" {
  for_each = local.os2mo_permission

  realm_id    = keycloak_realm.mo.id
  name        = each.key
  description = each.value
}

locals {
  composite_roles = merge({
    "reader" : ["^read_.*", "Read access to everything"],
    "creator" : ["^create_.*", "Create access to everything"],
    "updater" : ["^update_.*", "Update access to everything"],
    "terminator" : ["^terminate_.*", "Terminate access to everything"],
    "deleter" : ["^delete_.*", "Delete access to everything"],
    "refresher" : ["^refresh_.*", "Refresh access to everything"],
    }, {
    for collection in local.collections :
    "${collection}_admin" => [
      "^(${join("|", local.permission_types)})_${collection}$",
      "Full access to ${collection}"
    ]
    }, {
    "file_admin" : [".*_files", "Full access to files"],
  })
}

resource "keycloak_role" "composite_roles" {
  for_each = local.composite_roles

  realm_id    = keycloak_realm.mo.id
  name        = each.key
  description = each.value[1]
  composite_roles = [
    for role in keycloak_role.roles :
    role.id if can(regex(each.value[0], role.name))
  ]
}

resource "keycloak_role" "writer" {
  realm_id    = keycloak_realm.mo.id
  name        = "writer"
  description = "Write access to everything"
  composite_roles = [
    keycloak_role.composite_roles["creator"].id,
    keycloak_role.composite_roles["updater"].id,
    keycloak_role.composite_roles["terminator"].id,
    keycloak_role.composite_roles["deleter"].id,
    keycloak_role.composite_roles["refresher"].id,
  ]
}

resource "keycloak_role" "owner" {
  realm_id    = keycloak_realm.mo.id
  name        = "owner"
  description = "Special write access role, allowing only write acces to entities of which the user is owner in MO"
  composite_roles = [
    # TODO: The owner role should be completely separate from the reader role,
    # but we have kind of grandfathered in some customers that haven't mapped
    # the os2mo-reader role individually, so removing it breaks their access.
    # This composite role should be removed.
    keycloak_role.composite_roles["reader"].id,
  ]
}

locals {
  subroles = merge(
    {
      for role in keycloak_role.roles : role.name => role.id
    },
    {
      for role in keycloak_role.composite_roles : role.name => role.id
    },
    {
      owner  = keycloak_role.owner.id
      writer = keycloak_role.writer.id
    }
  )
}

resource "keycloak_role" "admin" {
  realm_id    = keycloak_realm.mo.id
  name        = "admin"
  description = "Full access to everything"
  composite_roles = [
    for name, id in local.subroles :
    id
  ]
}

resource "keycloak_role" "service_api" {
  realm_id    = keycloak_realm.mo.id
  name        = "service_api"
  description = "Can access OS2mo's old Service API"
}

resource "keycloak_role" "lora_api" {
  realm_id    = keycloak_realm.mo.id
  name        = "lora_api"
  description = "Can access OS2mo's very old LoRa API"
}


locals {
  roles = merge(
    local.subroles,
    {
      admin       = keycloak_role.admin.id
      service_api = keycloak_role.service_api.id
      lora_api    = keycloak_role.lora_api.id
    }
  )
}

# Clients

resource "keycloak_openid_client" "mo_frontend" {
  realm_id  = keycloak_realm.mo.id
  client_id = "mo-frontend"
  enabled   = true

  name                         = "OS2mo Frontend"
  access_type                  = "PUBLIC"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  access_token_lifespan        = var.keycloak_mo_token_lifespan

  valid_redirect_uris = var.keycloak_mo_client_redirect_uri
  web_origins         = var.keycloak_mo_client_web_origin
  authentication_flow_binding_overrides {
    browser_id = var.keycloak_idp_enable ? keycloak_authentication_flow.mo_idp_browser_flow.id : ""
  }
}

resource "keycloak_openid_user_attribute_protocol_mapper" "mo_client_uuid_mapper" {
  realm_id  = keycloak_realm.mo.id
  client_id = keycloak_openid_client.mo_frontend.id
  name      = "uuid-mapper"

  user_attribute = "object-guid"
  claim_name     = "uuid"
}

resource "keycloak_openid_client" "orgviewer" {
  count     = var.keycloak_orgviewer_client_enabled == true ? 1 : 0
  realm_id  = keycloak_realm.mo.id
  client_id = "orgviewer"
  enabled   = var.keycloak_orgviewer_client_enabled

  name                     = "ORGVIEWER"
  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
  access_token_lifespan    = var.keycloak_orgviewer_token_lifespan

  standard_flow_enabled = true
  valid_redirect_uris   = ["*"]
  web_origins           = ["*"]

  client_secret = var.keycloak_orgviewer_client_secret
}

resource "keycloak_openid_client_service_account_realm_role" "orgviewer_reader_role" {
  count                   = var.keycloak_orgviewer_client_enabled == true ? 1 : 0
  realm_id                = keycloak_realm.mo.id
  service_account_user_id = keycloak_openid_client.orgviewer[0].service_account_user_id
  role                    = keycloak_role.composite_roles["reader"].name
}

resource "keycloak_openid_hardcoded_claim_protocol_mapper" "orgviewer_uuid_claim" {
  count = var.keycloak_orgviewer_client_enabled == true ? 1 : 0

  realm_id  = keycloak_realm.mo.id
  client_id = keycloak_openid_client.orgviewer[0].id
  name      = "hardcoded-uuid"

  claim_name  = "uuid"
  claim_value = "03800000-baad-c0de-006F-726776696577"
}

# Users
resource "keycloak_user" "mo_user" {
  realm_id = keycloak_realm.mo.id
  username = each.value.username
  enabled  = each.value.enabled

  email      = each.value.email
  first_name = each.value.firstname
  last_name  = each.value.lastname

  initial_password {
    value = each.value.password
  }

  attributes = {
    object-guid = each.value.uuid
  }

  for_each = { for user in var.keycloak_realm_users : user.username => user }
}

# User roles
resource "keycloak_user_roles" "mo_user_roles" {
  realm_id = keycloak_realm.mo.id
  user_id  = keycloak_user.mo_user[each.key].id

  role_ids = [for role in each.value.roles : lookup(local.roles, role)]

  for_each = { for user in var.keycloak_realm_users : user.username => user }
}

# Login flow
resource "keycloak_authentication_flow" "mo_login_flow" {
  realm_id = keycloak_realm.mo.id
  alias    = "mo-login-flow"
}

resource "keycloak_authentication_execution" "mo_create_user" {
  realm_id          = keycloak_realm.mo.id
  parent_flow_alias = keycloak_authentication_flow.mo_login_flow.alias
  authenticator     = "idp-create-user-if-unique"
  requirement       = "REQUIRED"
}

# Browser flow
resource "keycloak_authentication_flow" "mo_idp_browser_flow" {
  realm_id = keycloak_realm.mo.id
  alias    = "mo-idp-browser-flow"
}

resource "keycloak_authentication_execution" "mo_idp_browser_flow_cookie" {
  realm_id          = keycloak_realm.mo.id
  parent_flow_alias = keycloak_authentication_flow.mo_idp_browser_flow.alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "mo_idp_browser_flow_idp_redirector" {
  realm_id          = keycloak_realm.mo.id
  parent_flow_alias = keycloak_authentication_flow.mo_idp_browser_flow.alias
  authenticator     = "identity-provider-redirector"
  requirement       = "ALTERNATIVE"
  # Use depends_on to control ordering of executions
  # We should always check for cookie before initiating login
  depends_on = [
    keycloak_authentication_execution.mo_idp_browser_flow_cookie
  ]
}

resource "keycloak_authentication_execution_config" "config" {
  realm_id     = keycloak_realm.mo.id
  execution_id = keycloak_authentication_execution.mo_idp_browser_flow_idp_redirector.id
  alias        = "saml"
  config = {
    defaultProvider = "saml"
  }
}

# IdP broker
resource "keycloak_saml_identity_provider" "adfs" {
  count = var.keycloak_idp_enable == true ? 1 : 0
  realm = keycloak_realm.mo.id
  # Part of the metadata URL. Metadata needs to be reimported if changed.
  alias   = "saml"
  enabled = var.keycloak_idp_enable
  # Always force reimport of users to get updated groups for RBAC
  sync_mode = "FORCE"

  # TODO: encryption key?
  validate_signature    = true
  signing_certificate   = var.keycloak_idp_signing_certificate
  name_id_policy_format = var.keycloak_idp_name_id_policy_format
  principal_type        = "SUBJECT"

  first_broker_login_flow_alias = keycloak_authentication_flow.mo_login_flow.alias

  post_binding_response      = true
  post_binding_authn_request = true
  entity_id                  = var.keycloak_idp_entity_id
  single_sign_on_service_url = var.keycloak_idp_signon_service_url
  single_logout_service_url  = var.keycloak_idp_logout_service_url

  signature_algorithm = var.keycloak_idp_signed_requests == true ? "RSA_SHA256" : null

  extra_config = {
    allowedClockSkew = var.keycloak_idp_clock_skew
  }
}

# IdP RBAC role mappers
resource "keycloak_custom_identity_provider_mapper" "adfs_admin_role_mapper" {
  count                    = var.keycloak_idp_enable == true ? 1 : 0
  realm                    = keycloak_realm.mo.id
  name                     = "admin-mapper"
  identity_provider_alias  = keycloak_saml_identity_provider.adfs[0].alias
  identity_provider_mapper = "saml-role-idp-mapper"

  # extra_config with syncMode is required in Keycloak 10+
  extra_config = {
    syncMode          = "INHERIT"
    "attribute.name"  = "http://schemas.xmlsoap.org/claims/Group"
    "attribute.value" = "os2mo-admin"
    "role"            = keycloak_role.admin.name
  }
}

resource "keycloak_custom_identity_provider_mapper" "adfs_owner_role_mapper" {
  count                    = var.keycloak_idp_enable == true ? 1 : 0
  realm                    = keycloak_realm.mo.id
  name                     = "owner-mapper"
  identity_provider_alias  = keycloak_saml_identity_provider.adfs[0].alias
  identity_provider_mapper = "saml-role-idp-mapper"

  # extra_config with syncMode is required in Keycloak 10+
  extra_config = {
    syncMode          = "INHERIT"
    "attribute.name"  = "http://schemas.xmlsoap.org/claims/Group"
    "attribute.value" = "os2mo-owner"
    "role"            = keycloak_role.owner.name
  }
}

resource "keycloak_custom_identity_provider_mapper" "adfs_reader_role_mapper" {
  count                    = var.keycloak_idp_enable == true ? 1 : 0
  realm                    = keycloak_realm.mo.id
  name                     = "reader-mapper"
  identity_provider_alias  = keycloak_saml_identity_provider.adfs[0].alias
  identity_provider_mapper = "saml-role-idp-mapper"

  # extra_config with syncMode is required in Keycloak 10+
  extra_config = {
    syncMode          = "INHERIT"
    "attribute.name"  = "http://schemas.xmlsoap.org/claims/Group"
    "attribute.value" = "os2mo-reader"
    "role"            = keycloak_role.composite_roles["reader"].name
  }
}

resource "keycloak_hardcoded_role_identity_provider_mapper" "adfs_service_api_access" {
  count                   = var.keycloak_idp_enable == true ? 1 : 0
  realm                   = keycloak_realm.mo.id
  name                    = "service-api-access"
  identity_provider_alias = keycloak_saml_identity_provider.adfs[0].alias
  role                    = keycloak_role.service_api.name

  extra_config = {
    syncMode = "INHERIT"
  }
}

resource "keycloak_custom_identity_provider_mapper" "adfs_object_guid_mapper" {
  count                    = var.keycloak_idp_enable == true ? 1 : 0
  realm                    = keycloak_realm.mo.id
  name                     = "guid-mapper"
  identity_provider_alias  = keycloak_saml_identity_provider.adfs[0].alias
  identity_provider_mapper = "saml-user-attribute-idp-mapper"

  extra_config = {
    syncMode         = "INHERIT"
    "attribute.name" = "object-guid"
    "user.attribute" = "object-guid"
  }
}
