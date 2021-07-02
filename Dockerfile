FROM python:3.9-slim

WORKDIR /opt

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY keycloak.env .
COPY keycloak.json.j2 .
COPY keycloak-realm.json.j2 .
COPY filters.py .

COPY populate-template.sh .
ENTRYPOINT ["/bin/bash", "populate-template.sh"]
