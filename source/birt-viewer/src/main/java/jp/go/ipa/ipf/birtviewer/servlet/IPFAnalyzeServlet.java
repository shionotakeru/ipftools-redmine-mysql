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
package jp.go.ipa.ipf.birtviewer.servlet;

import java.io.File;
import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.go.ipa.ipf.birtviewer.dao.entity.ProjectInfo;
import jp.go.ipa.ipf.birtviewer.logic.IPFAnalyzeLogic;
import jp.go.ipa.ipf.birtviewer.logic.param.IPFAnalyzeLogicParam;
import jp.go.ipa.ipf.birtviewer.logic.result.IPFAnalyzeLogicResult;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.commons.lang.builder.ToStringStyle;
import org.apache.log4j.Logger;
import org.eclipse.birt.report.exception.ViewerException;
import org.eclipse.birt.report.session.ViewingSessionUtil;

/**
 * 定量的分析診断機能を提供するサーブレットクラス
 * 
 */
public class IPFAnalyzeServlet extends HttpServlet {

    protected static Logger log = Logger.getLogger(IPFAnalyzeServlet.class);
    
    private static final long serialVersionUID = 6847796189346482811L;

    @Override
    public void init() throws ServletException {
        super.init();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doPost(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession();
        
        res.setContentType("text/html; charset=UTF-8");
        
        try {
            // BIRT VIEWER セッション切れ対策？
            ViewingSessionUtil.createSession(req);
        } catch (ViewerException e) {
            e.printStackTrace();
        }
        
        IPFAnalyzeLogicParam prm = new IPFAnalyzeLogicParam();
        
        // ユーザID、ユーザ名取得
        Integer userId = null;
        String userName = null;
        if (session != null) {
            userId = (Integer) session.getAttribute("USER_ID");
            userName = (String) session.getAttribute("USER_NAME");
        }
        prm.setUserId(userId);
        prm.setUserName(userName);
        req.setAttribute("USER_NAME", userName);
        
        // プロジェクトID、プロジェクト名取得
        prm.setProjectId((Integer) req.getAttribute("PROJECT_ID"));
        prm.setProjectName((String) req.getAttribute("PROJECT_NAME"));
        prm.setProjectPath((String) req.getAttribute("PROJECT_PATH"));
        
        // プロジェクト一覧取得
        List<ProjectInfo> projectList = (List<ProjectInfo>) session.getAttribute("PROJECT_LIST");
        prm.setProjectList(projectList);
        
        // グラフID取得
        prm.setGraphId((String) req.getAttribute("GRAPH_ID"));
        
        // レポートファイルパス取得
        prm.setReportFilePath((String) req.getAttribute("REPORT_FILE_PATH"));
        
        // JSPファイルパスを取得
        prm.setJspPaht(req.getParameter("JSP_PATH"));
        
        // コンテキストパス（絶対パス）取得
        ServletContext application = getServletContext();
        File contextRealPath = new File(application.getRealPath("/"));
        prm.setContextRealPath(contextRealPath.getAbsolutePath());
        
        // ロケール設定
        prm.setLocale(req.getLocale());
        
        //-----------------------------------------------------
        // ビジネスロジック実行
        //-----------------------------------------------------
        log.debug("prm:" + ToStringBuilder.reflectionToString(prm, ToStringStyle.MULTI_LINE_STYLE));
        IPFAnalyzeLogicResult result = new IPFAnalyzeLogic().doLogic(prm);
        log.debug("result:" + ToStringBuilder.reflectionToString(result, ToStringStyle.MULTI_LINE_STYLE));
        //-----------------------------------------------------
        
        // ビジネスロジック処理結果をリクエスト属性に設定
        req.setAttribute("result", result);
        req.setAttribute("TODAY", result.getToday());
        req.setAttribute("ONE_MONTH_AGO", result.getOneMonthAgo());
        req.setAttribute("ONE_MONTH_AFTER", result.getOneMonthAfter());
        req.setAttribute("TOP_WBS_TICKET", result.getTopWbsTicket());
        req.setAttribute("TOP_WBS_TICKET_RS02", result.getTopWbsTicketRs02());
        
        if (StringUtils.equals(result.getGraphId(), "R_M01") 
                && StringUtils.isNotBlank(req.getParameter("digest"))) {
            // 定量管理ダッシュボード（認証情報あり）のURLでアクセスされた場合 
            // → 認証情報なしの定量管理ダッシュボードにリダイレクト
            
            String contextPath = req.getContextPath();
            
            StringBuilder sb = new StringBuilder();
            sb.append(contextPath);
            sb.append("/dashboard");
            sb.append("?PROJECT_ID=");
            sb.append(result.getPROJECT_ID());
            sb.append("&t=");
            sb.append(result.getT());
            
            String url = sb.toString();
            log.info("redirect url=" + url);
            res.sendRedirect(url);
        } else {
            // JSPフォワード
            String jspFowardPath = result.getJspForwardPath();
            RequestDispatcher dispathcer = req.getRequestDispatcher(jspFowardPath);
            dispathcer.forward(req, res);
        }
        
    }

    @Override
    public void destroy() {
        // TODO 自動生成されたメソッド・スタブ
        super.destroy();
    }

}
