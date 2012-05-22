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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * 配下の IPFAuthDisp タグが全て非表示の場合
 * BODY を非表示にするカスタムタグクラス
 */
public class IPFAuthGroupDispTag extends BodyTagSupport {

    private static final long serialVersionUID = 1018806773435257497L;
    
    /** 表示される配下の IPFAuthDisp タグの数 */
    private int countDispTag = 0;
    
    @Override
    public int doStartTag() throws JspException {
        countDispTag = 0;
        return EVAL_BODY_BUFFERED;
    }

    @Override
    public int doEndTag() throws JspException {
        
        if (this.countDispTag > 0) {
            // 配下の IPFAuthDisp タグが表示される場合
            try {
                JspWriter out = pageContext.getOut();
                bodyContent.writeOut(out);
                bodyContent.clearBody();
            } catch (Exception e) {
                throw new JspException("error in IPFAuthGroupDispTag: " + e);
            }
        }
        return EVAL_PAGE;
    }


    /**
     * 表示される配下の IPFAuthDisp タグの数をインクリメントする。
     */
    protected void incrementDispTagCount() {
        this.countDispTag ++;
    }

}
