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
package jp.go.ipa.ipf.birtviewer.taglib;

import java.io.IOException;
import java.util.Locale;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.taglib.TagUtils;

import jp.go.ipa.ipf.birtviewer.util.IPFMessage;

/**
 * ロケールに対応するIPFメッセージを表示するクラス
 */
public class IPFMessageTag extends TagSupport {

    /** メッセージのキー */
    private String key;
    
    /** デフォルト文字列 */
    private String defaultStr;
    
    @Override
    public int doStartTag() throws JspException {
        try {
            Locale locale = pageContext.getRequest().getLocale();
            String message = IPFMessage.getInstance(locale).getString(key, defaultStr);
            pageContext.getOut().print(message);
        } catch (IOException e) {
            e.printStackTrace();
            throw new JspException(e);
        }
        return SKIP_BODY;
    }

    /**
     * メッセージのキーを取得します。
     * @return メッセージのキー
     */
    public String getKey() {
        return key;
    }

    /**
     * メッセージのキーを設定します。
     * @param key メッセージのキー
     */
    public void setKey(String key) {
        this.key = key;
    }

    /**
     * デフォルト文字列を取得します。
     * @return デフォルト文字列
     */
    public String getDefaultStr() {
        return defaultStr;
    }

    /**
     * デフォルト文字列を設定します。
     * @param defaultStr デフォルト文字列
     */
    public void setDefaultStr(String defaultStr) {
        this.defaultStr = defaultStr;
    }

}
