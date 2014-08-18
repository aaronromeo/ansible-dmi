#!/bin/bash
 
NAME="breedfeedlaunch"                                  # Name of the application
DJANGODIR=/opt/myenv/breedfeedlaunch/breedfeedlaunch/             # Django project directory
SOCKFILE=/data/tmp/breedfeedlaunch_gunicorn.sock  # we will communicte using this unix socket
USER=deploy                                        # the user to run as
GROUP=deploy                                     # the group to run as
NUM_WORKERS=3                                     # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=breedfeedlaunch.settings             # which settings file should Django use
DJANGO_WSGI_MODULE=breedfeedlaunch.wsgi                     # WSGI module name
 
echo "Starting $NAME as `whoami`"
 
# Activate the virtual environment
cd $DJANGODIR
source /opt/myenv/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH
 
# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

source /home/deploy/.env

env

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec /opt/myenv/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --bind=unix:$SOCKFILE
