# Mesop Frontend
This is an alternative frontend to use if you do not wish to use the unathenticated agent HTML chat window provided by a conversational agent. This frontend will make API Key authenticated calls to an API directly

## Prereqs
You have completed the Solar Agent setup already

## Local Development
From within this mesop folder, create a .env file with the following contents
```
MESOP_STATIC_FOLDER=static
MESOP_STATIC_URL_PATH=/static
APIGEE_KEY=YOUR_APIGEE_API_KEY
APIGEE_DOMAIN=YOUR_APIGEE_DOMAIN
```

Then start your venv and install requirements
```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Finally, run your mesop app
```
mesop main.py
```