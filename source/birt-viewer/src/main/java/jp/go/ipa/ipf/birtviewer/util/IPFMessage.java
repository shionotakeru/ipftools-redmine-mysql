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
package jp.go.ipa.ipf.birtviewer.util;

import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

/**
 * IPFのメッセージリソースを取得するクラス
 */
public class IPFMessage {
    
    protected static Logger log = Logger.getLogger(IPFMessage.class);
    
    /** リソースバンドル */
    private ResourceBundle bundle;
    
    private IPFMessage() { }
    
    /**
     * IPFメッセージリソースのインスタンスを返す
     * 
     * @param locale ロケール
     * @return IPFメッセージリソース
     */
    public static IPFMessage getInstance(Locale locale) {
        IPFMessage message = new IPFMessage();
        try {
            ResourceBundle bundle = ResourceBundle.getBundle("ipfMessage", locale);
            message.setBundle(bundle);
        } catch (MissingResourceException e) {
            e.printStackTrace();
        }
        return message;
    }
    
    /**
     * IPFメッセージリソースのインスタンスを返す
     * 
     * @return IPFメッセージリソース
     */
    public static IPFMessage getInstance() {
        IPFMessage message = new IPFMessage();
        try {
            ResourceBundle bundle = ResourceBundle.getBundle("ipfMessage");
            message.setBundle(bundle);
        } catch (MissingResourceException e) {
            e.printStackTrace();
        }
        return message;
    }

    /**
     * bundleを取得します。
     * @return bundle
     */
    public ResourceBundle getBundle() {
        return bundle;
    }

    /**
     * bundleを設定します。
     * @param bundle bundle
     */
    public void setBundle(ResourceBundle bundle) {
        this.bundle = bundle;
    }
    
    /**
     * キーに該当するメッセージを返す。
     * @param key キー
     * @return キーに該当するメッセージ
     */
    public String getString(String key) {
        String message = "";
        try {
            message = this.bundle.getString(key);
        } catch (Exception e) {
            e.printStackTrace();
            log.warn(e);
        }
        return message;
    }

    /**
     * キーに該当するメッセージを返す。
     * 存在しない場合はデフォルト文字列を返す。
     * @param key キー
     * @param defaultStr デフォルト文字列
     * @return キーに該当するメッセージ。存在しない場合はデフォルト文字列。
     */
    public String getString(String key, String defaultStr) {
        return StringUtils.defaultString(this.getString(key), defaultStr);
    }
    
    /**
     * キーに該当するメッセージをフォーマットして返す。
     * @param key キー
     * @param objects フォーマット引数
     * @return　フォーマットされたキーに該当するメッセージ。
     */
    public String getFormatString(String key, Object... objects) {
        String message = "";
        try {
            String format = this.bundle.getString(key);
            message = String.format(format, objects);
        } catch (Exception e) {
            e.printStackTrace();
            log.warn(e);
        }
        return message;
    }
    
}
