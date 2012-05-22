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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

import org.apache.commons.lang.StringUtils;
import org.eclipse.birt.report.taglib.ViewerTag;
import org.eclipse.birt.report.taglib.component.ParameterField;

/**
 * ダッシュボードのグラフ縮小表示表示用カスタムタグクラス
 */
public class IPFGraphTag extends ViewerTag {
    
    private static final long serialVersionUID = 2348109486542508496L;
    
    /** デフォルトパラメータ */
    private final static Map<String, String> defaultParamMap = new HashMap<String, String>();
    /** 幅 */
    private final static String defaultWidth = "440";
    /** 高さ */
    private final static String defaultHight = "300";
    /** パターン */
    private final static String defaultPattern = "run";
    /** フォーマット */
    private final static String defaultFormat = "html";
    /** パラメータ画面表示 */
    private final static String defaultShotParameterPage = "false";
    
    /** タイトル */
    protected String title;
    
    /** コメント */
    protected String comment;
    
    static {
        defaultParamMap.put("NAVI_CREATE_FLAG", "false");
        defaultParamMap.put("DRILL_FLAG", "true");
        defaultParamMap.put("DRILL_FIRST_FLAG", "true");
        defaultParamMap.put("INDEX", "0");
        defaultParamMap.put("LIMMIT", "10");
        defaultParamMap.put("BIND_OFFSET", "10");
        defaultParamMap.put("HELP_FLAG", "true");
        defaultParamMap.put("NEW_WINDOW_FLAG", "false");
    }
    
    @Override
    public int doAfterBody() throws JspException {
    	
        this.setPattern(defaultPattern);
        this.setHeight(defaultHight);
        this.setWidth(defaultWidth);
        this.setFormat(defaultFormat);
        this.setShowParameterPage(defaultShotParameterPage);
        
        for (Map.Entry<String, String> entry : defaultParamMap.entrySet()) {
            ParameterField pf = new ParameterField();
            pf.setName(entry.getKey());
            pf.setValue(entry.getValue());
            this.addParameter(pf);
        }
        
    	String contextPath = this.pageContext.getServletContext().getContextPath();
    	
    	
    	StringBuilder onClickSb = new StringBuilder();
    	onClickSb.append("javascript:subWindowOpen('");
    	onClickSb.append(contextPath);
    	onClickSb.append("/");
    	onClickSb.append(viewer.getReportDesign());
    	onClickSb.append("?");
    	
    	// パラメータ組立
    	List<String> paramList = new ArrayList<String>();
    	for (Iterator it = super.parameters.entrySet().iterator(); it.hasNext(); ) {
    		Map.Entry entry = (Map.Entry)it.next();
    		ParameterField pf = (ParameterField) entry.getValue();
    		if (pf.getValue() != null) {
        		paramList.add(pf.getName() + "=" + pf.getValue());
    		}
    	}
    	onClickSb.append(StringUtils.join(paramList, "&"));
    	onClickSb.append("');");
    	
        JspWriter writer = this.pageContext.getOut();
        try {
            writer.write("<div class=\"dashboard_graph\">\n");
            writer.write("<div class=\"dashboard_title\"><a href=\"javascript:void(0)\" onclick=\"" + onClickSb.toString() + "\">\n");
            writer.write(title + "</a><img src=\"" + contextPath + "/images/newwindow.png\"/></div>\n");
            writer.write("<div class=\"dashboard_content\">\n");
        } catch (Exception e) {
            e.printStackTrace();
            throw new JspException(e);
        }
        
    	return super.doAfterBody();
    }
    
    @Override
    public int doEndTag() throws JspException {
        int rtn = super.doEndTag();
        
        JspWriter writer = this.pageContext.getOut();
        try {
            writer.write("<!-- dashboard_content --></div>\n");
            writer.write("<div class=\"dashboard_comment\">\n");
            writer.write(comment);
            writer.write("<!-- dashboard_comment --></div>\n");
            writer.write("<!-- dashboard_graph --></div>\n");
        } catch (Exception e) {
            e.printStackTrace();
            throw new JspException(e);
        }
        return rtn;
    }

	/**
	 * タイトルを取得します。
	 * @return タイトル
	 */
	public String getTitle() {
	    return title;
	}

	/**
	 * タイトルを設定します。
	 * @param title タイトル
	 */
	public void setTitle(String title) {
	    this.title = title;
	}
	
	/**
	 * コメントを取得します。
	 * @return コメント
	 */
	public String getComment() {
	    return comment;
	}

	/**
	 * コメントを設定します。
	 * @param comment コメント
	 */
	public void setComment(String comment) {
	    this.comment = comment;
	}

}
