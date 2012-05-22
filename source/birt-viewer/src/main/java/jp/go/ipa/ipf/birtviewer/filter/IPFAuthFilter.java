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
package jp.go.ipa.ipf.birtviewer.filter;

import java.io.IOException;
import java.sql.Connection;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jp.go.ipa.ipf.birtviewer.bean.UserPermissionBean;
import jp.go.ipa.ipf.birtviewer.dao.ConnectionFactory;
import jp.go.ipa.ipf.birtviewer.dao.ProjectInfoDAO;
import jp.go.ipa.ipf.birtviewer.dao.UserInfoDAO;
import jp.go.ipa.ipf.birtviewer.dao.UserPermissionDAO;
import jp.go.ipa.ipf.birtviewer.dao.entity.ProjectInfo;
import jp.go.ipa.ipf.birtviewer.exception.IPFException;
import jp.go.ipa.ipf.birtviewer.logic.result.IPFCommonResult;
import jp.go.ipa.ipf.birtviewer.taglib.IPFAuthDispTag;
import jp.go.ipa.ipf.birtviewer.util.IPFAnalyzeUtils;
import jp.go.ipa.ipf.birtviewer.util.IPFConfig;
import jp.go.ipa.ipf.birtviewer.util.IPFMessage;

import org.apache.commons.codec.net.URLCodec;
import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * 認証・権限チェック用フィルタクラス
 */
public class IPFAuthFilter implements Filter {

    protected static Logger log = Logger.getLogger(IPFAuthFilter.class);
    
    /** DBコネクション生成クラス */
    private ConnectionFactory factory;
    
    @Override
    public void init(FilterConfig config) throws ServletException {
//        factory = ConnectionFactory.getInstance();
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res,
            FilterChain chain) throws IOException, ServletException {
        
        factory = ConnectionFactory.getInstance();
        
        Date start = new Date();
        log.debug("IPFAuthFilter#doFilter[START]");
        
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        Locale locale = req.getLocale();
        
        // レスポンスヘッダに IE8 ドキュメントモードを指定
        response.setHeader("X-UA-Compatible", "IE=EmulateIE8");
        
        IPFCommonResult result = new IPFCommonResult();
        
        // ログレベル
        Level logLevel = log.getEffectiveLevel();
        int level = Level.INFO_INT;
        if (logLevel != null) {
            level = logLevel.toInt();
        }
        result.setLogLevel(level);
        
        try {
            // CSS用ロケールセット
            String cssLocale = IPFMessage.getInstance(locale).getString("css.locale");
            result.setCssLocale(cssLocale);
            
            // 認証情報取得
            Integer userId = getUserId(request);
            if (userId == null) {
                // 認証エラー
                throw new IPFException(
                        IPFMessage.getInstance(locale).getFormatString("0301"));
            }
            
            // セッションから権限情報を取得
            HttpSession session = request.getSession(false);
            
            String userName = null; // ユーザ名
            Map<Integer, UserPermissionBean> userProjectPermMap = null; // ユーザの権限情報（全プロジェクト）
            List<ProjectInfo> permProjectList = null; // ユーザが閲覧できるプロジェクト一覧
            
            if (session.isNew()) {
                // 新規セッション（新規ログイン）の場合
                
                // ユーザ名を取得、セッションにセット
                userName = getUserName(userId);
                if (userName == null) {
                    throw new IPFException(IPFMessage.getInstance(
                            request.getLocale()).getFormatString("0314"));
                }
                session.setAttribute("USER_NAME", userName);
                
                // ユーザの権限情報を取得、セッションにセット
                userProjectPermMap = getUserPeojectPermission(userId);
                session.setAttribute("USER_PERM_MAP", userProjectPermMap);
                
                // ユーザが閲覧権限を持っているプロジェクト情報一覧を取得、セッションにセット
                permProjectList = getPermProjectList(userProjectPermMap);
                session.setAttribute("PROJECT_LIST", permProjectList);
            } else {
                // ログイン済みの場合
                
                // ユーザ名をセッションから取得
                userName = (String) session.getAttribute("USER_NAME");
                // ユーザの権限情報をセッションから取得
                userProjectPermMap = (Map<Integer, UserPermissionBean>) session.getAttribute("USER_PERM_MAP");
                // ユーザが閲覧権限を持っているプロジェクト情報一覧をセッションから取得
                permProjectList = (List<ProjectInfo>) session.getAttribute("PROJECT_LIST");
            }
            
            // プロジェクトID、プロジェクトパスを取得、リクエストにセット
            ProjectInfo projectInfo = getProjectInfo(request);
            if (projectInfo == null) {
                // プロジェクト情報を取得できない場合(0305)
                throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0305"));
            }
            Integer projectId = projectInfo.getProjectId();
            String projectName = projectInfo.getProjectName();
            // ダッシュボードパターンのキーとして使用するプロジェクトパス
            // PROJECT_PATH が空の場合、PROJECT_ID を設定
            String projectPath = StringUtils.defaultIfBlank(
                                    projectInfo.getProjectPath(),
                                    projectId.toString());
            
            // JSPで使用する情報をリクエストにセット
            req.setAttribute("PROJECT_ID", projectId); // プロジェクトID
            req.setAttribute("PROJECT_NAME", projectName); // プロジェクト名
            req.setAttribute("PROJECT_PATH", projectPath); // プロジェクトパス
            req.setAttribute("PROJECT_OUTLINE", projectInfo.getOutline()); // プロジェクト概要
            
            // グラフID取得
            String graphId = getGraphId(request);
            req.setAttribute("GRAPH_ID", graphId);
            
            // レポートファイルパス取得
            String reportFilePath = getReportFilePath(request);
            req.setAttribute("REPORT_FILE_PATH", reportFilePath);

            // 権限チェック
            UserPermissionBean userPermBean = userProjectPermMap.get(projectId);
            if (userPermBean == null) {
                // 権限情報を取得できない場合(0302)
                throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0302", projectName));
            }
            
            String graphPermission = IPFConfig.getInstance().getProperty("permission." + graphId);
            if (! userPermBean.hasPermission(graphPermission)) {
                // 権限がない場合(0302)
                throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0303", projectName, graphPermission));
            }
            req.setAttribute(IPFAuthDispTag.BEAN_USER_PROJECT_PERMISSION, userPermBean);
            
        } catch (IPFException e) {
            result.setErrMsg(e.getMessage());
            
        } catch (Exception e) {
            e.printStackTrace();
            result.setErrMsg(e.getMessage());
            result.setStackTrace(IPFAnalyzeUtils.getStackTrace(e));
        } finally {
            if (result.getErrMsg() != null) {
                // 認証エラー
                req.setAttribute("result", result);
                RequestDispatcher dispathcer = 
                        req.getRequestDispatcher("/WEB-INF/jsp/authError.jsp");
                dispathcer.forward(req, res);
            } else {
                // 認証成功
                chain.doFilter(req, res);
            }
        }
        
        if (log.isDebugEnabled()) {
            Date end = new Date();
            String startDate = DateFormatUtils.format(start, "yyyy/MM/dd HH:mm:ss.SSS");
            String endDate = DateFormatUtils.format(end, "yyyy/MM/dd HH:mm:ss.SSS");
            float elapsed = (end.getTime() - start.getTime());
            NumberFormat nf = new DecimalFormat("0.000");
            String strElapsed = nf.format(elapsed / 1000);
            log.debug("IPFAuthFilter#doFilter[END] " + 
                    String.format("Start=%s, End=%s, elapsed=%s", startDate, endDate, strElapsed));
        }
    }

    @Override
    public void destroy() {
        // TODO 自動生成されたメソッド・スタブ
        
    }
    
    /**
     * リクエスト情報からユーザIDを取得する。
     * 
     * @param request リクエスト情報
     * @return ユーザID
     * @throws IPFException 
     */
    private Integer getUserId(HttpServletRequest request) throws Exception {
        
        Integer authUserId = null;
        
        String reqUserId = request.getParameter("USER_ID");
        String reqUserName = request.getParameter("USER_NAME");
        
        if (StringUtils.isNotBlank(reqUserId) || StringUtils.isNotBlank(reqUserName)) {
            // ユーザID(UESR_ID) または ユーザ名(UESR_NAME) が指定されている場合
            // リクエストパラメータからユーザIDを取得
            
            // リクエストパラメータ改ざんチェック
            if (isInvalidQuery(request)) {
                // パラメータが改ざんされている
                throw new IPFException(IPFMessage.getInstance(
                        request.getLocale()).getFormatString("0313"));
            }
            
            // タイムアウトチェック
            if (isTimeoutQuery(request)) {
                // タイムアウト
                throw new IPFException(IPFMessage.getInstance(
                        request.getLocale()).getFormatString("0313"));
            }
            
            if (StringUtils.isNotBlank(reqUserId)) {
                // ユーザIDが指定されている場合
                String decUserId = IPFAnalyzeUtils.decodeBase64(reqUserId);
                if (StringUtils.isNumeric(decUserId)) {
                    authUserId = NumberUtils.toInt(decUserId);
                }
            } else {
                // ユーザ名が指定されている場合 → uesr_info テーブルからユーザIDを取得
                String decUserName = IPFAnalyzeUtils.decodeBase64(reqUserName);
                Connection conn = null;
                try {
                    conn = factory.getConnection();
                    UserInfoDAO userInfoDao = new UserInfoDAO(conn);
                    authUserId = userInfoDao.getUserId(decUserName);
                    if (authUserId == null) {
                        throw new IPFException(IPFMessage.getInstance(
                                request.getLocale()).getFormatString("0314"));
                    }
                } finally {
                    DbUtils.closeQuietly(conn);
                }
            }
            // セッション破棄
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            
            // ユーザIDをセッションに格納
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("USER_ID", authUserId);
            
        } else {
            // セッションからユーザIDを取得
            HttpSession session = request.getSession(false);
            Integer sesUserId = null;
            if (session != null) {
                sesUserId = (Integer) session.getAttribute("USER_ID");
            }
            authUserId = sesUserId;
        }
        
        return authUserId;
    }

    /**
     * ユーザIDからユーザ名を取得する。
     * 
     * @param userId ユーザID
     * @return ユーザ名
     */
    private String getUserName(Integer userId) throws Exception {
        
        String userName = null;
        Connection conn = null;
        try {
            conn = factory.getConnection();
            UserInfoDAO userDdo = new UserInfoDAO(conn);
            userName = userDdo.getUserName(userId);
        } finally {
            DbUtils.closeQuietly(conn);
        }
        
        return userName;
    }
    
    /**
     * ユーザが閲覧権限を持っているプロジェクト情報一覧を取得する。
     * 
     * @param userId ユーザID
     * @return ユーザが閲覧権限を持っているプロジェクト情報一覧
     * @throws Exception 
     */
    private List<ProjectInfo> getPermProjectList(Map<Integer, UserPermissionBean> uesrProjectPermMap) throws Exception {
        List<ProjectInfo> permProjectList = new ArrayList<ProjectInfo>();
        Connection conn = null;
        try {
            conn = factory.getConnection();
            ProjectInfoDAO projectDao = new ProjectInfoDAO(conn);
            List<ProjectInfo> projectList = projectDao.getProjectList();
             for (ProjectInfo project : projectList) {
                 UserPermissionBean upb = uesrProjectPermMap.get(project.getProjectId());
                 if (upb != null && upb.hasPermission(UserPermissionBean.IPF_ANALYZE)) {
                     // 権限がある場合
                     permProjectList.add(project);
                 }
             }
        } finally {
            DbUtils.closeQuietly(conn);
        }
        return permProjectList;
    }

    /**
     * ユーザIDからユーザの権限情報(全プロジェクト)を取得する。
     * 
     * @param userId ユーザID
     * @return ユーザの権限情報（全プロジェクト）
     */
    private Map<Integer, UserPermissionBean> getUserPeojectPermission(Integer userId) throws Exception {
        
        Map<Integer, UserPermissionBean> userProjectPermMap = null;
        Connection conn = null;
        try {
            conn = factory.getConnection();
            UserPermissionDAO userPermDdo = new UserPermissionDAO(conn);
            userProjectPermMap = userPermDdo.getUserProjectPermission(userId);
        } finally {
            DbUtils.closeQuietly(conn);
        }
        
        return userProjectPermMap;
    }

    /**
     * クエリストリングが改ざんされていないかチェックする。
     * 
     * @param req リクエスト
     * @return true : 改ざんされている。 false : 改ざんされていない。
     * @throws Exception 
     */
    private boolean isInvalidQuery(HttpServletRequest request) throws Exception {
        
        String queryStr = StringUtils.defaultString(request.getQueryString());
        URLCodec codec = new URLCodec();
        queryStr = codec.decode(queryStr);
        String digestStr = request.getParameter("digest");
        String validQueryStr = queryStr.replaceAll("&+digest=" + digestStr, "");
        log.debug("validQueryStr=" + validQueryStr);
        String chkDigestStr = IPFAnalyzeUtils.getHmacSha1(validQueryStr);
        log.debug("reqDigest=" + digestStr);
        log.debug("chkDigest=" + chkDigestStr);
        
        if (StringUtils.isBlank(digestStr) || 
            ! StringUtils.equals(digestStr, chkDigestStr)) {
            // 改ざんされている
            return true;
        }
        return false;
    }

    /**
     * タイムアウトしているかチェックする。
     * 
     * @param req リクエスト
     * @return true : タイムアウトしている。 false : タイムアウトしていない。
     */
    private boolean isTimeoutQuery(HttpServletRequest request) {
        
        // タイムアウト時間取得
        Long timeout = null;
        try {
            String strTimeout = IPFConfig.getInstance().getProperty("queryTimeout");
            timeout = NumberUtils.toLong(strTimeout, 1800);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        if (timeout == 0) {
            // タイムアウトチェックしない
            return false;
        }
        
        String t = request.getParameter("t");
        if (NumberUtils.isNumber(t)) {
            long quetyTime = NumberUtils.toLong(t);
            long nowTime = (new Date().getTime()) / 1000;
            log.debug("quetyTime=" + quetyTime);
            log.debug("nowTime=" + nowTime);
            log.debug("timeout=" + timeout);
            if ((nowTime - quetyTime) > timeout) {
                // タイムアウトしている場合
                return true;
            }
        }
        return false;
    }
    
    /**
     * リクエスト情報からプロジェクト情報を取得する。
     * 
     * @param req リクエスト
     * @return プロジェクト情報
     * @throws Exception 
     */
    private ProjectInfo getProjectInfo(HttpServletRequest request) throws Exception {
        
        Locale locale = request.getLocale();
        
        String reqProjectId = request.getParameter("PROJECT_ID");
        String reqProjectPath = request.getParameter("PROJECT_PATH");
        
        // プロジェクト情報取得
        if (StringUtils.isBlank(reqProjectId) && StringUtils.isBlank(reqProjectPath)) {
            // パラメータにプロジェクトID、またはプロジェクトパスのいずれも指定されていない場合
            throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0304"));
        }
        
        ProjectInfo projectInfo = null;
        Connection conn = null;
        try {
            conn = factory.getConnection();
            ProjectInfoDAO projectDao = new ProjectInfoDAO(conn);
            
            // プロジェクト情報取得
            Integer projectId = null;
            String projectName = null;
            if (StringUtils.isNotBlank(reqProjectId)) {
                // プロジェクトIDが指定されている場合
                if (StringUtils.isNumeric(reqProjectId)) {
                    projectId = Integer.parseInt(reqProjectId);
                    projectName = projectDao.getProjectName(projectId);
                }
                if (projectName == null) {
                    // プロジェクト情報が取得できない場合(0307)
                    throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0307", 
                            reqProjectId));
                }
                
            } else {
                // プロジェクト名が指定されている場合
                projectId = projectDao.getProjectIdFromPath(reqProjectPath);
                projectName = projectDao.getProjectName(projectId);
                if (projectId == null) {
                    // プロジェクト情報が取得できない場合(0308)
                    throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0308", 
                            reqProjectPath));
                }
            }
            
            // プロジェクト概要取得
            projectInfo = projectDao.getProjectInfo(projectId);
        } finally {
            DbUtils.closeQuietly(conn);
        }
        
        return projectInfo;
    }
    
    /**
     * リクエストからグラフIDを取得する。
     * 
     * @param request リクエスト
     * @return グラフID
     */
    private String getGraphId(HttpServletRequest request) {
        String graphId = null;
        
        // サーブレットパス・拡張パス取得
        String servletPath = StringUtils.defaultString(request.getServletPath()) + 
                            StringUtils.defaultString(request.getPathInfo());
        
        if (StringUtils.endsWith(servletPath, "/dashboard")) {
            // 定量管理ダッシュボード
            graphId = "R_M01";
        } else {
            // それ以外
            String reportFilePath = StringUtils.removeStart(servletPath, "/");
            graphId = FilenameUtils.getBaseName(reportFilePath);
        }
        return graphId;
    }
    
    /**
     * レポートファイルパスを取得する。
     * 
     * @param request リクエスト
     * @return レポートファイルパス
     */
    private String getReportFilePath(HttpServletRequest request) {
        String reportFilePath = null;
        
        // サーブレットパス・拡張パス取得
        String servletPath = StringUtils.defaultString(request.getServletPath()) + 
                            StringUtils.defaultString(request.getPathInfo());
        
        if (StringUtils.endsWith(servletPath, "/dashboard")) {
            // 定量管理ダッシュボード
            reportFilePath = null;
        } else {
            // それ以外
            reportFilePath = StringUtils.removeStart(servletPath, "/");
        }
        
        return reportFilePath;
    }

}
