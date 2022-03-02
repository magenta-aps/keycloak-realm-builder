CHANGELOG
=========

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
