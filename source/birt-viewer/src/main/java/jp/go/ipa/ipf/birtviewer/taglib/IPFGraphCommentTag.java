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
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * ダッシュボードのグラフコメント表示用カスタムタグクラス
 */
public class IPFGraphCommentTag extends BodyTagSupport  {
    
	private static final long serialVersionUID = 5921835664142211115L;

	@Override
	public int doEndTag() throws JspException {
		
        IPFGraphTag ipfGraphTag 
        	= (IPFGraphTag) findAncestorWithClass(this, IPFGraphTag.class);
    
		String comment = bodyContent.getString();
		ipfGraphTag.setComment(comment);
		
		return super.doAfterBody();
	}
}
