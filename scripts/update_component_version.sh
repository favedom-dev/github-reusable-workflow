#/bin/bash

# REQUIREMENTS:
# The YAML_FILE MUST have ELEMENT_NAME_2 on the next line after ELEMENT_NAME_1
#
# example WORKS because ELEMENT_NAME_1=name and ELEMENT_NAME_2=version is immediately on the next line:
#   - name: test-spring-boot-app
#     version: 0.0.108
#     chart: releases/test-spring-boot-app
#     namespace: '{{ requiredEnv "DEPLOY_NAMESPACE"}}'
#     installed: true
#
# example FAILS because ELEMENT_NAME_1=name and ELEMENT_NAME_2=version is NOT immediately on the next line:
#   - name: test-spring-boot-app
#     chart: releases/test-spring-boot-app
#     version: 0.0.108
#     namespace: '{{ requiredEnv "DEPLOY_NAMESPACE"}}'
#     installed: true

# YAML_FILE="helmfile.yaml"
# VERSION="9.9.999"
# NAME="test-spring-boot-app"

ELEMENT_NAME_1="name"
ELEMENT_NAME_2="version"

echo "--------------:--------------"
echo "NAME          : ${NAME}"
echo "VERSION       : ${VERSION}"
echo "YAML_FILE     : ${YAML_FILE}"
echo "ELEMENT_NAME_1: ${ELEMENT_NAME_1}"
echo "ELEMENT_NAME_2: ${ELEMENT_NAME_2}"
echo "--------------:--------------"

sed -i -e '/'${ELEMENT_NAME_1}': '${NAME}'$/{n' -e 's/'${ELEMENT_NAME_2}': [0-9,.]*/'${ELEMENT_NAME_2}': '${VERSION}'/' -e '}' ${YAML_FILE}
