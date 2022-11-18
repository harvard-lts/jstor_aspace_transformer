# jstor_aspace_transformer

### To start transformer component:
- clone repository
- cp .env.example to .env
- cp celeryconfig.py.example to celeryconfig.py and put in credentials
- make sure logs/jstor_transformer directory exists (need to fix)
- bring up docker
- - docker-compose -f docker-compose-local.yml up --build -d --force-recreate
