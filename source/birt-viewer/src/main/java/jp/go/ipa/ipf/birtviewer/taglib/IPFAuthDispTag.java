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
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.TagSupport;

import jp.go.ipa.ipf.birtviewer.bean.UserPermissionBean;

/**
 * 権限の有無をチェックして、
 * 表示・非表示を制御するカスタムタグクラス
 */
public class IPFAuthDispTag extends TagSupport  {
    
    private static final long serialVersionUID = -692812772750980854L;
    
    public static final String BEAN_USER_PROJECT_PERMISSION = "jp.go.ipa.ipf.tablib.BEAN.USER_PERMISSION";
    
    /** 権限名（カンマ区切りで複数指定可能） */
    private String permissions = "";

    @Override
    public int doStartTag() throws JspException {
        
        Object bean = pageContext.getAttribute(BEAN_USER_PROJECT_PERMISSION, 
                PageContext.REQUEST_SCOPE);
        if (bean instanceof UserPermissionBean) {
            UserPermissionBean upb = (UserPermissionBean) bean;
            if (upb != null && upb.hasPermission(this.permissions)) {
                // 権限がある場合
                return EVAL_BODY_INCLUDE; 
            } else {
                // 権限がない場合
                return SKIP_BODY;
            }
        }
        return SKIP_BODY;
    }
    
    @Override
    public int doAfterBody() throws JspException {
        
        IPFAuthGroupDispTag authGroupDispTag 
            = (IPFAuthGroupDispTag) findAncestorWithClass(this, IPFAuthGroupDispTag.class);
        
        if (authGroupDispTag != null) {
            // IPFAuthGroupDisp タグがある場合、countDispTag をインクリメントする。
            authGroupDispTag.incrementDispTagCount();
        }
        
        return super.doAfterBody();
    }

    /**
     * 権限を設定します。
     * @param permission 権限
     */
    public void setPermissions(String permissions) {
        this.permissions = permissions;
    }

}
