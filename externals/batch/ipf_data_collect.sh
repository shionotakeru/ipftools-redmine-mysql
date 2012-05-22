#!/bin/bash

# ----------------------------------------------------------------------------
# 環境設定シェルインクルード
# ----------------------------------------------------------------------------
BATCH_BASE_DIR=$(cd $(dirname $0);pwd)
. "$BATCH_BASE_DIR/set-batch-env.sh"

# ----------------------------------------------------------------------------
# LOG_DIR : ログファイル出力先
# ----------------------------------------------------------------------------
MILS=$(printf '%03d' $(expr `date +%N` / 1000000))
TIMESTAMP=`date '+%Y%m%d_%H%M%S'`_$MILS

LOG_DIR=$BATCH_BASE_DIR/log
if [ ! -d $LOG_DIR ]; then
    mkdir -p $LOG_DIR
fi
LOG_FILE=$LOG_DIR/ipf_data_collect_${TIMESTAMP}.log

# ----------------------------------------------------------------------------
# エラーフラグ
# ----------------------------------------------------------------------------
ERR_FLAG=0

# ----------------------------------------------------------------------------
# project_a のデータ収集
# ----------------------------------------------------------------------------
sh -C "$BATCH_BASE_DIR/B001ROE/B001ROE_1.sh" project_a >> $LOG_FILE
RTN_CD=$?
if [ $RTN_CD -eq 0 ]; then
    sh -C "$BATCH_BASE_DIR/B003ISE/B003ISE.sh" project_a >> $LOG_FILE
fi
RTN_CD=$?
if [ $RTN_CD -ne 0 ]; then
    ERR_FLAG=1
fi

# ----------------------------------------------------------------------------
# project_b のデータ収集
# ----------------------------------------------------------------------------
#sh -C "$BATCH_BASE_DIR/B001TSE/B001TSE.sh" project_b >> $LOG_FILE
#RTN_CD=$?
#if [ $RTN_CD -eq 0 ]; then
#    sh -C "$BATCH_BASE_DIR/B003ISE/B003ISE.sh" project_b >> $LOG_FILE
#fi
#RTN_CD=$?
#if [ $RTN_CD -ne 0 ]; then
#    ERR_FLAG=1
#fi

# ----------------------------------------------------------------------------
# バッチ日付ファイル更新
# ----------------------------------------------------------------------------
if [ $ERR_FLAG -eq 0 ]; then
    sh -C "$BATCH_BASE_DIR/batch_date_update.sh" >> $LOG_FILE
    RTN_CD=$?
    if [ $RTN_CD -ne 0 ]; then
        ERR_FLAG=1
    fi
fi

RTN_CD=$ERR_FLAG
exit $RTN_CD
