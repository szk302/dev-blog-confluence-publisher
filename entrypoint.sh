#!/bin/ash
set -eo pipefail

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
  ./${WORK_DIR}/build.sh ${filePath##*/}
done