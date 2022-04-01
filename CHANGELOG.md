CHANGELOG
=========

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
