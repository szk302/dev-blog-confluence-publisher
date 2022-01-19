#!/bin/ash
set -eo pipefail

TEAM=$1
USER_ID=$2
API_KEY=$3
SPACE_KEY=$4
ANCESTOR_ID=$5

if [ -f ./.env ]; then
  source .env
fi

WORK_DIR=work

mkdir -p ${WORK_DIR}
cp build.sh ${WORK_DIR}/
cp template.body.json ${WORK_DIR}/

cd content
updatedFiles=`git log --pretty="" -1 --name-only -- *.adoc`
cd ..

echo ${updatedFiles}

for filePath in $updatedFiles; do
  echo ${filePath}
  cp "content/${filePath}" ${WORK_DIR}/
  ./${WORK_DIR}/build.sh "${TEAM}" "${USER_ID}" "${API_KEY}" "${SPACE_KEY}" "${ANCESTOR_ID}" ${filePath##*/} 
done