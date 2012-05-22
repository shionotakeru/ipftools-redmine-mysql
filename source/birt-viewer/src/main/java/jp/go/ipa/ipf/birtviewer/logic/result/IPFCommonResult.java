/**
 *   <Quantitative project management tool.>
 *   Copyright (C) 2012 IPA, Japan.
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package jp.go.ipa.ipf.birtviewer.logic.result;

import java.io.Serializable;

/**
 * 処理結果を格納する共通クラス。
 */
public class IPFCommonResult implements Serializable {

    private static final long serialVersionUID = -1208282236090141736L;

    /** エラーメッセージ */
    protected String errMsg;
    
    /** スタックトレース */
    protected String stackTrace;
    
    /** ログレベル */
    protected int logLevel;
    
    /** システム日時 */
    protected long t;
    
    /** CSS用ロケール名 */
    protected String cssLocale;
    
    /**
     * エラーメッセージを取得します。
     * @return エラーメッセージ
     */
    public String getErrMsg() {
        return errMsg;
    }

    /**
     * エラーメッセージを設定します。
     * @param errMsg エラーメッセージ
     */
    public void setErrMsg(String errMsg) {
        this.errMsg = errMsg;
    }

    /**
     * スタックトレースを取得します。
     * @return スタックトレース
     */
    public String getStackTrace() {
        return stackTrace;
    }

    /**
     * スタックトレースを設定します。
     * @param stackTrace スタックトレース
     */
    public void setStackTrace(String stackTrace) {
        this.stackTrace = stackTrace;
    }

    /**
     * ログレベルを取得します。
     * @return ログレベル
     */
    public int getLogLevel() {
        return logLevel;
    }

    /**
     * ログレベルを設定します。
     * @param logLevel ログレベル
     */
    public void setLogLevel(int logLevel) {
        this.logLevel = logLevel;
    }

    /**
     * システム日時を取得します。
     * @return システム日時
     */
    public long getT() {
        return t;
    }

    /**
     * システム日時を設定します。
     * @param t システム日時
     */
    public void setT(long t) {
        this.t = t;
    }

    /**
     * CSS用ロケール名を取得します。
     * @return CSS用ロケール名
     */
    public String getCssLocale() {
        return cssLocale;
    }

    /**
     * CSS用ロケール名を設定します。
     * @param cssLocale CSS用ロケール名
     */
    public void setCssLocale(String cssLocale) {
        this.cssLocale = cssLocale;
    }

}
