CHANGELOG
=========

3.16.2 - 2022-10-27
-------------------

[#52822] Forgot to add commit

3.16.1 - 2022-10-27
-------------------

[#52822] Set optional UUIDs on Keycloak users

3.16.0 - 2022-09-16
-------------------

[#52591] Make Admin not-owner

3.15.0 - 2022-09-15
-------------------

[#52556] Save tf state in integration builder

3.14.0 - 2022-09-13
-------------------

[#51382] Allow Standard Flow in integration builder

3.13.0 - 2022-09-09
-------------------

[#51382] Standard Flow for orgviewer

3.12.0 - 2022-08-02
-------------------

[#51683] Allow roles to be random strings

3.11.0 - 2022-07-13
-------------------

[#50496] Revert Delete integration-builder

3.10.0 - 2022-06-22
-------------------

[#50393] Download plugins at build time

3.9.6 - 2022-05-05
------------------

[#50143] Re-enable environment variable check

3.9.5 - 2022-05-05
------------------

[#50060] Removed deprecated ENV check

3.9.4 - 2022-04-30
------------------

[#48771] Fix bad variable renaming

3.9.3 - 2022-04-30
------------------

[#48771] Fix bad default

3.9.2 - 2022-04-30
------------------

[#48771] Fix missing 'to' in 'toset'.

3.9.1 - 2022-04-28
------------------

[#49668] Fix CI mistake

3.9.0 - 2022-04-28
------------------

[#49668] Integration client builder

3.8.0 - 2022-04-22
------------------

[#49745] Allow optional `TF_VAR_` prefix on settings

3.7.0 - 2022-04-04
------------------

[#47988] Implement token lifespans

3.6.0 - 2022-04-01
------------------

[#47988] Load orgviewer env vars

3.5.0 - 2022-04-01
------------------

[#47988] Include orgviewer client

3.4.0 - 2022-03-17
------------------

[#48873] Add support for clock skew. Defaults to 10 seconds.

3.3.3 - 2022-03-03
------------------

[#48990] Add Admin role to dipex client

3.3.2 - 2022-03-02
------------------

[#47868] Fix signed requests for IdP

3.3.1 - 2022-02-15
------------------

[#48553] Fix wrong claim name in mo-frontend client UUID mapper

Rename the internal attribute name to object-guid to more accurately describe
what this attribute actually is and where it came from

3.3.0 - 2022-02-15
------------------

[#48553] Add two new mappings

* Add mapping of Object GUID from IdP assertion to user 'uuid' attribute
* Add mapping of 'uuid' attribute to JWT for mo-frontend client.

3.2.0 - 2022-02-11
------------------

[#47514] Add RBAC role mapping

We currently add IdP broker mappings for the 'os2mo-admin' and 'os2mo-owner'
group-attributes to the corresponding groups.

3.1.0 - 2022-02-10
------------------

[#47514] Add LoRa DIPEX client

3.0.0 - 2022-02-07
------------------

[#47514] Reimplementation using Terraform

2.4.1 - 2022-01-21
------------------

[#48114] Added CD to Flux

0.1.0 - 2021-12-08
------------------

[#47507] Implement automatic versioning through autopub
