FROM python:3.9-slim

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY keycloak.env .
COPY keycloak.json.j2 .
COPY keycloak-realm.json.j2 .

COPY entrypoint.sh .
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
