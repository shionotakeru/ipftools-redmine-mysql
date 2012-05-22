#!/bin/bash

# ----------------------------------------------------------------------------
# 環境設定シェルインクルード
# ----------------------------------------------------------------------------
BASE_DIR=$(cd $(dirname $0);pwd)
cd $BASE_DIR
BATCH_BASE_DIR=$(cd $BASE_DIR/..;pwd)
. "$BATCH_BASE_DIR/set-batch-env.sh"

# ----------------------------------------------------------------------------
# バッチID取得
# ----------------------------------------------------------------------------
BAT_FILE=${0##*/}
BAT_ID=${BAT_FILE%.*}
BAT_UNQ_ID=${BAT_ID}

# ----------------------------------------------------------------------------
# パラメータ
# [1] Trac プロジェクトID
# ----------------------------------------------------------------------------
PROJECT_ID=$1
PROJECT_DIR=$RM_PROJECT_ROOT/$PROJECT_ID

# ----------------------------------------------------------------------------
# Kettle ジョブファイル名
# ----------------------------------------------------------------------------
JOB_FILES="B002-S14.kjb B002-S14-LIST.kjb"

# ----------------------------------------------------------------------------
# LOG_LEVEL : ログレベル
#  Error    : Only show errors
#  Nothing  : Don't show any output
#  Minimal  : Only use minimal logging
#  Basic    : This is the default basic logging level
#  Detailed : Give detailed logging output
#  Debug    : For debugging purposes, very detailed output.
#  Rowlevel : Logging at a row level, this can generate a lot of data.
# ----------------------------------------------------------------------------
LOG_LEVEL=Basic

# ----------------------------------------------------------------------------
# ロックファイルの有効期間（分）
# ----------------------------------------------------------------------------
export LOCK_TIME=1

# ----------------------------------------------------------------------------
# バッチ日付ファイル
# ----------------------------------------------------------------------------
BATCH_FILE=$BATCH_BASE_DIR/batch_date_file/batch_file
BATCH_DIR=$BATCH_BASE_DIR/batch_date_file

MILS=$(printf '%03d' $(expr `date +%N` / 1000000))
TIMESTAMP=`date '+%Y%m%d_%H%M%S'`_$MILS

if [ "$PROJECT_ID" != "" ]; then
    if [ ! -d $BATCH_DIR ]; then
        mkdir -p $BATCH_DIR
    fi
    if [ ! -e $BATCH_FILE ]; then
        date '+%Y/%m/%d' > $BATCH_FILE
    fi
fi

# ----------------------------------------------------------------------------
# RESULT_DIR : 結果ファイル出力先
# ----------------------------------------------------------------------------
if [ "$PROJECT_ID" != "" ]; then
    RESULT_DIR=$PROJECT_DIR/batch/result
else
    RESULT_DIR=$BATCH_BASE_DIR/result
fi
if [ ! -d $RESULT_DIR ]; then
    mkdir -p $RESULT_DIR
fi
# ----------------------------------------------------------------------------
# LOG_DIR : ログファイル出力先
# ----------------------------------------------------------------------------
if [ "$PROJECT_ID" != "" ]; then
    LOG_DIR=$PROJECT_DIR/batch/log
else
    LOG_DIR=$BATCH_BASE_DIR/log
fi
if [ ! -d $LOG_DIR ]; then
    mkdir -p $LOG_DIR
fi
LOG_FILE=$LOG_DIR/${BAT_ID}_${TIMESTAMP}.log

# ----------------------------------------------------------------------------
# ERR_FILE_PATH : エラーリストファイル出力先
# ----------------------------------------------------------------------------
if [ "$PROJECT_ID" != "" ]; then
    ERR_FILE_PATH=$PROJECT_DIR/batch/errlist/$BAT_ID
else
    ERR_FILE_PATH=$BATCH_BASE_DIR/errlist/$BAT_ID
fi
if [ ! -d $ERR_FILE_PATH ]; then
    mkdir -p $ERR_FILE_PATH
fi

# ----------------------------------------------------------------------------
# PENTAHO_JAVA_HOME : Pentaho 用 Java ホームディレクトリ
# ----------------------------------------------------------------------------
if [ "$JAVA_HOME" != "" ]; then
    PENTAHO_JAVA_HOME=$JAVA_HOME
fi

# ----------------------------------------------------------------------------
# KETTLE_HOME : KETTLEホームディレクトリ(デフォルトはユーザのホームディレクトリ)
# ----------------------------------------------------------------------------
export KETTLE_HOME=$BATCH_BASE_DIR/pentaho
KETTLE_PROP_FILE=$KETTLE_HOME/.kettle/kettle.properties

# ----------------------------------------------------------------------------
# バッチ処理で利用するファイルのパス
# ----------------------------------------------------------------------------
export MSG_FILE=$RESULT_DIR/$BAT_ID_$TIMESTAMP.msg
export LOCK_FILE=$RESULT_DIR/$BAT_UNQ_ID.lock
export OK_FILE=$RESULT_DIR/$BAT_UNQ_ID.ok
export ERR_FILE=$RESULT_DIR/$BAT_UNQ_ID.err
export ERR_FILE_PATH
export BATCH_DATE_FILE=$BATCH_FILE


# ----------------------------------------------------------------------------
# コマンドパラメータ生成
# ----------------------------------------------------------------------------
CMD_LINE_ARGS=
CMD_LINE_ARGS="$CMD_LINE_ARGS $RM_PROJECT_ROOT"
CMD_LINE_ARGS="$CMD_LINE_ARGS $PROJECT_ID"

echo Using RESULT_DIR           : $RESULT_DIR
echo Using LOG_DIR              : $LOG_DIR
echo Using PENTAHO_JAVA_HOME    : $PENTAHO_JAVA_HOME
echo Using PENTAHO_HOME         : $PENTAHO_HOME
echo Using EXEC_KITCHEN         : $EXEC_KITCHEN
echo Using KETTLE_HOME          : $KETTLE_HOME
echo Using RM_PROJECT_ROOT      : $RM_PROJECT_ROOT
echo Using CMD_LINE_ARGS        : $CMD_LINE_ARGS


# ----------------------------------------------------------------------------
# Kitchen 実行
# ----------------------------------------------------------------------------
if [ -e $OK_FILE ]; then
    rm $OK_FILE
fi
if [ -e $ERR_FILE ]; then
    rm $ERR_FILE
fi
if [ -r $KETTLE_PROP_FILE ]; then
    for JOB_FILE in $JOB_FILES
    do
        KETTLE_JOB_FILE=$KETTLE_HOME/job/$JOB_FILE
        echo Run KETTLE_JOB_FILE : $KETTLE_JOB_FILE
        sh -C $EXEC_KITCHEN -file="$KETTLE_JOB_FILE" $CMD_LINE_ARGS -level=$LOG_LEVEL >> $LOG_FILE
        RTN_CD=$?
        if [ $RTN_CD -ne 0 ]; then
            break
        fi
    done
else
    DATETIME=`date '+%Y/%m/%d %H:%M:%S'`
    MSG="${DATETIME} Unable to read file '${KETTLE_PROP_FILE}'"
    echo $MSG >> $LOG_FILE
    echo $MSG >> $ERR_FILE
    RTN_CD=1
fi

if [ -e $MSG_FILE ]; then
    cat $MSG_FILE
fi
if [ -e $MSG_FILE ]; then
    rm -f $MSG_FILE
fi

echo RTN_CD:$RTN_CD
exit $RTN_CD
