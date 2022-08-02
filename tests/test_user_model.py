# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
from main import KeycloakUser


def test_random_string_allowed_as_role():
    assert KeycloakUser(
        username="username",
        password="password",
        firstname="firstname",
        lastname="lastname",
        email="bruce@kung.fu",
        roles=["These", "are", "random", "strings"],
    )
