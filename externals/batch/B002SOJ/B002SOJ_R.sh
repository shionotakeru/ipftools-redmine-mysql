#!/bin/bash
# ------------------------------------------------------------------------------#
#    <Quantitative project management tool.>                                    #
#    Copyright (C) 2012 IPA, Japan.                                             #
#                                                                               #
#    This program is free software: you can redistribute it and/or modify       #
#    it under the terms of the GNU General Public License as published by       #
#    the Free Software Foundation, either version 3 of the License, or          #
#    (at your option) any later version.                                        #
#                                                                               #
#    This program is distributed in the hope that it will be useful,            #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#    GNU General Public License for more details.                               #
#                                                                               #
#    You should have received a copy of the GNU General Public License          #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.      #
#                                                                               #
# ------------------------------------------------------------------------------#

export LANG=ja_JP.UTF-8
#export LANG=

MILS=$(printf '%03d' $(expr `date +%N` / 1000000))
START_TIME="`date '+%Y/%m/%d %H:%M:%S'`.$MILS [START]"

# ----------------------------------------------------------------------------
# 環境設定シェルインクルード
# ----------------------------------------------------------------------------
BASE_DIR=$(cd $(dirname $0);pwd)
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
# [1] Redmine プロジェクト識別子
# [2] 収集開始リビジョン番号（任意、デフォルト1）
# ----------------------------------------------------------------------------
PROJECT_ID=$1
START_REV=$2

# ----------------------------------------------------------------------------
# LOG_DIR : ログファイル出力先
# ----------------------------------------------------------------------------
MILS=$(printf '%03d' $(expr `date +%N` / 1000000))
TIMESTAMP=`date '+%Y%m%d_%H%M%S'`_$MILS

if [ "$PROJECT_ID" != "" ]; then
    LOG_DIR=$BATCH_BASE_DIR/log/$PROJECT_ID
else
    LOG_DIR=$BATCH_BASE_DIR/log
fi
if [ ! -d $LOG_DIR ]; then
    mkdir -p $LOG_DIR
fi
LOG_FILE=$LOG_DIR/${BAT_ID}_${TIMESTAMP}.log

echo $START_TIME >> $LOG_FILE

# ----------------------------------------------------------------------------
# KETTLE_HOME : KETTLEホームディレクトリ(デフォルトはユーザのホームディレクトリ)
# ----------------------------------------------------------------------------
export KETTLE_HOME=$BATCH_BASE_DIR/pentaho
export KETTLE_PROP_FILE=$KETTLE_HOME/.kettle/kettle.properties


# ----------------------------------------------------------------------------
# RUN_JAVA : Java コマンド
# ----------------------------------------------------------------------------
RUNJAVA=$JAVA_HOME/bin/java


# ----------------------------------------------------------------------------
# CLASSPATH 設定
# ----------------------------------------------------------------------------
CLASSPATH=$BASE_DIR
CLASSPATH=$CLASSPATH:$BATCH_BASE_DIR/commonJ
for i in $BATCH_BASE_DIR/commonJ/lib/*.jar; do set_classpath $i; done

# ----------------------------------------------------------------------------
# コマンドライン
# ----------------------------------------------------------------------------
CMD_LINE_ARGS="$PROJECT_ID"
CMD_LINE_ARGS="$CMD_LINE_ARGS $START_REV"

# ----------------------------------------------------------------------------
# バッチ実行
# ----------------------------------------------------------------------------
MAINCLASS=jp.go.ipa.ipf.sourcescale.SourceScaleCountRedmineSVN

#echo "Using RUNJAVA               : $RUNJAVA"
#echo "Using CLASSPATH             : $CLASSPATH"
#echo "Using MAINCLASS             : $MAINCLASS"
#echo "Using CMD_LINE_ARGS         : $CMD_LINE_ARGS"
#echo "Using KETTLE_PROP_FILE      : $KETTLE_PROP_FILE"
#echo "Using REDMINE_PROJECT_ROOT  : $REDMINE_PROJECT_ROOT"
#echo "Using LOG_FILE              : $LOG_FILE"

"$RUNJAVA" -classpath "$CLASSPATH" $MAINCLASS $CMD_LINE_ARGS >> $LOG_FILE
RTN_CD=$?

MILS=$(printf '%03d' $(expr `date +%N` / 1000000))
END_TIME="`date '+%Y/%m/%d %H:%M:%S'`.$MILS [END]"
echo $END_TIME >> $LOG_FILE

exit $RTN_CD

