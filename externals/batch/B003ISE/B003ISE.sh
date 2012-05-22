#!/bin/bash

# ----------------------------------------------------------------------------
# 環境設定シェルインクルード
# ----------------------------------------------------------------------------
BASE_DIR=$(cd $(dirname $0);pwd)
cd $BASE_DIR
BATCH_BASE_DIR=$(cd $BASE_DIR/..;pwd)
. "$BATCH_BASE_DIR/set-batch-env.sh"

# ----------------------------------------------------------------------------
# パラメータ
# [1] Trac プロジェクトID
# ----------------------------------------------------------------------------
PROJECT_ID=$1
if [ "$PROJECT_ID" = "" ]; then
    echo Arguments ProjectID is required.
    exit 1
fi

PROJECT_DIR=$RM_PROJECT_ROOT/$PROJECT_ID

# ----------------------------------------------------------------------------
# バッチ実行
# ----------------------------------------------------------------------------

ERR_FLAG=0

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_1.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_2.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_3.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_4.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_5.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_6.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_7.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_8.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

sh -C "$BATCH_BASE_DIR/B004IOE/B004IOE_9.sh" $PROJECT_ID
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

if [ $ERR_FLAG -eq 0 ]; then
    RTN_CD=0
else
    RTN_CD=1
fi

exit $RTN_CD
