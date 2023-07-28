#ID=e3e38a1e-4a23-4d21-9ff5-03d0589517f5 python:3.11.0b1-buster 
FROM python:3.12.0b4-buster 

# set work directory
WORKDIR /app
#Adcionado um User para resolver a vulnerabilidade "ID:xxx"
USER MyUser 

# dependencies for psycopg2
RUN apt-get update && apt-get install --no-install-recommends -y dnsutils=1:9.11.5.P4+dfsg-5.1+deb10u7 libpq-dev=11.16-0+deb10u1 python3-dev=3.7.3-1 
\ && apt-get clean 
\ && rm -rf /var/lib/apt/lists/*

# IAC 3714275d-9459-4407-a036-3b947c3d7e17
# e932bde2-5e9c-41c7-bfa9-df20780023a5
#FROM nginx:1.13
#ENV ADMIN_USER="ng"
#RUN echo $ADMIN_USER > ./ng
#RUN unset ADMIN_USER
#HEALTHCHECK --interval=30s --timeout=3s \
#  CMD curl -f http://localhost/ || exit 1
#EXPOSE 80

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


# Install dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt pip==22.0.4


# copy project
COPY . /app/


# install pygoat
EXPOSE 8000


RUN python3 /app/manage.py migrate
WORKDIR /app/pygoat/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers","6", "pygoat.wsgi"]
