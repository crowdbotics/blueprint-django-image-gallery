#!/bin/bash

# BASE_PATH is the full path to the project root
BASE_PATH="$1"
# APP_NAME is the name of the Django app that will be modified
APP_NAME="$2"

PIPFILE_FILE="$BASE_PATH/Pipfile"
SETTINGS_FILE="$BASE_PATH/$APP_NAME/settings.py"
URLS_FILE="$BASE_PATH/$APP_NAME/urls.py"
DOCKERFILE_FILE="$BASE_PATH/Dockerfile"

# Add a django app to INSTALLED_APPS
add_to_installed_apps() {
  echo "Adding $1 to INSTALLED_APPS"
  sed -i '' -e 's/\(INSTALLED_APPS =.*\)/\1\'$'\n    '"'$1',/" $SETTINGS_FILE
}

# Add an app to THIRD_PARTY_APPS
add_to_third_party_apps() {
  echo "Adding $1 to THIRD_PARTY_APPS"
  sed -i '' -e 's/\(THIRD_PARTY_APPS =.*\)/\1\'$'\n    '"'$1',/" $SETTINGS_FILE
}

# Add a system dependency to the dockerfile
add_dep_to_dockerfile() {
  if [ -f "$DOCKERFILE_FILE" ] && ! grep -q $1 $DOCKERFILE_FILE
  then
    echo "Adding dependency $1 to Dockerfile"
    sed -i '' -e 's/\(RUN apk add.*\)/\1\'$'\n  '"$1 \\\/" $DOCKERFILE_FILE
  fi
}

# Add comma in INSTALLED_APPS if missing
sed -i '' -e "s/\('django.contrib.sites'\)$/\1,/" $SETTINGS_FILE

# Add django-photologue package
if ! grep -q "django-photologue" $PIPFILE_FILE
then
    echo "Adding django-photologue to Pipfile"
    echo "django-photologue = \"*\"" >> $PIPFILE_FILE
fi

# Add photologue and sortedm2m to apps
if ! grep -q "photologue" $SETTINGS_FILE
then
  add_to_third_party_apps photologue
  add_to_third_party_apps sortedm2m
fi

# Add MEDIA_ROOT if it's not set
if ! grep -q "MEDIA_ROOT" $SETTINGS_FILE
then
  echo "Adding MEDIA_ROOT to $SETTINGS_FILE"
  echo 'MEDIA_ROOT = os.path.join(BASE_DIR, "media")' >> $SETTINGS_FILE
fi

# Add the URL to use to access the gallery (/photos)
if ! grep -q "photologue" $URLS_FILE
then
  echo "Adding URL to $URLS_FILE"
  sed -i '' -e 's/\(admin.site.urls.*\)/\1\'$'\n    '"url(r'^photos\/', include('photologue.urls', namespace='photologue')),/" $URLS_FILE
fi

# Add required installs for pillow, used by django-photologue
add_dep_to_dockerfile zlib-dev
add_dep_to_dockerfile libjpeg-turbo-dev
