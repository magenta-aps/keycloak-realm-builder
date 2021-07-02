FROM python:3.9-slim

ADD requirements.txt .
RUN pip install -r requirements.txt

ADD keycloak.env .
ADD keycloak.json.j2 .
ADD keycloak-realm.json.j2 .

ADD entrypoint.sh .
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
