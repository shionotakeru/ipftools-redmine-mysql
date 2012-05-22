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

import org.eclipse.birt.report.taglib.ParamTag;

/**
 * グラフパラメータ用カスタムタグクラス
 */
public class IPFGraphParamTag extends ParamTag  {
    
	private static final long serialVersionUID = 4919412170430537656L;
	
	private Object value;
	
    @Override
    public void setValue(Object value) {
        this.value = value;
        super.setValue(value);
    }

    @Override
    public int doEndTag() throws JspException {
        if (value != null) {
            // パラメータ追加
            return super.doEndTag();
        }
        return EVAL_PAGE;
    }
    
}
