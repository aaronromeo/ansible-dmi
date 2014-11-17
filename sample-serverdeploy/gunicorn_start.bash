#!/bin/bash
 
NAME="{{project.name}}"                                  # Name of the application
DJANGODIR=/data/venv_{{project.name}}/{{project.name}}/{{project.name}}/             # Django project directory
SOCKFILE=/data/tmp/{{project.name}}_gunicorn.sock  # we will communicte using this unix socket
USER={{os.username}}                                        # the user to run as
GROUP={{os.usergroup}}                                     # the group to run as
NUM_WORKERS=3                                     # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE={{project.name}}.settings             # which settings file should Django use
DJANGO_WSGI_MODULE={{project.name}}.wsgi                     # WSGI module name
 
echo "Starting $NAME as `whoami`"
 
# Activate the virtual environment
cd $DJANGODIR
source /data/venv_{{project.name}}/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH
 
# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

source /data/venv_{{project.name}}/{{project.name}}/serverdeploy/vars.secure

env

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec /data/venv_{{project.name}}/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --bind=unix:$SOCKFILE
