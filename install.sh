#!/bin/bash

# Initialize basic vars and helpers
source blueprint-lib/init.sh

##
# Add dependencies here
##

source blueprint-lib/python.sh
source blueprint-lib/docker.sh

##
# ADD BLUEPRINT CODE BELOW HERE
#
# BASE_PATH is the full path to the project root
# APP_NAME is the name of the Django app that will be modified
##

# Add django-photologue package
add_python_package django-photologue

# Add photologue and sortedm2m to apps
add_third_party_app photologue
add_third_party_app sortedm2m

# Add the URL to use to access the gallery (/photos)
# @TODO Abstract into a shared function
if ! grep -q "photologue" $PYTHON_URLS_PATH
then
  echo "Adding URL to $PYTHON_URLS_PATH"
  sed -i '' -e 's/\(admin.site.urls.*\)/\1\'$'\n    '"url(r'^photos\/', include('photologue.urls', namespace='photologue')),/" $PYTHON_URLS_PATH
fi

# Add required installs for pillow, used by django-photologue
add_dockerfile_dependency zlib-dev
add_dockerfile_dependency libjpeg-turbo-dev
