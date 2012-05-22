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
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

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
import jp.go.ipa.ipf.birtviewer.dao.entity.ProjectInfo;
import jp.go.ipa.ipf.birtviewer.exception.IPFException;
import jp.go.ipa.ipf.birtviewer.logic.result.IPFCommonResult;
import jp.go.ipa.ipf.birtviewer.taglib.IPFAuthDispTag;
import jp.go.ipa.ipf.birtviewer.util.IPFAnalyzeUtils;
import jp.go.ipa.ipf.birtviewer.util.IPFConfig;
import jp.go.ipa.ipf.birtviewer.util.IPFMessage;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * 認証・権限チェックを無効にするフィルタクラス
 */
public class IPFNoAuthFilter implements Filter {

    protected static Logger log = Logger.getLogger(IPFNoAuthFilter.class);
    
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
        log.debug("IPFNoAuthFilter#doFilter[START]");
        
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
            
            HttpSession session = request.getSession();
            if (session == null) {
                session = request.getSession(true);
            }
            
            // 認証情報取得
            String strUserId = IPFConfig.getInstance().getProperty("userId"); // ユーザID
            Integer userId = NumberUtils.toInt(strUserId, 1);
            String userName = IPFConfig.getInstance().getProperty("userName"); // ユーザ名
            
            // ユーザが閲覧できるプロジェクト一覧
            List<ProjectInfo> permProjectList = getPermProjectList();

            // セッションにセット
            session.setAttribute("USER_ID", userId);
            session.setAttribute("USER_NAME", userName);
            session.setAttribute("PROJECT_LIST", permProjectList);
            
            // プロジェクトID
            String reqProjectId = StringUtils.defaultString(request.getParameter("PROJECT_ID"));
            // プロジェクトパス
            String reqProjectPath = StringUtils.defaultString(request.getParameter("PROJECT_PATH"));
            if (StringUtils.isBlank(reqProjectId) && StringUtils.isBlank(reqProjectPath)) {
                // プロジェクトID、またはプロジェクトパスが指定されていない場合(0304)
                throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0304"));
            }
            
            ProjectInfo projectInfo = null;
            if (StringUtils.isNotBlank(reqProjectId) && StringUtils.isNumeric(reqProjectId)) {
                // プロジェクトIDで検索
                Integer id = NumberUtils.toInt(reqProjectId);
                projectInfo = getProjectInfoById(id, permProjectList);
            } else {
                // プロジェクトパスで検索
                projectInfo = getProjectInfoByPath(reqProjectPath, permProjectList);
            }
            if (projectInfo == null) {
                // プロジェクト情報を取得できない場合(0306)
                throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0306"));
            }
            Integer projectId = projectInfo.getProjectId();
            String projectName = projectInfo.getProjectName();
            // PROJECT_PATH が空の場合、PROJECT_ID を設定
            String projectPath = StringUtils.defaultIfBlank(
                                    projectInfo.getProjectPath(),
                                    projectId.toString());
            
            // JSPで使用する情報をリクエストにセット
            req.setAttribute("PROJECT_ID", projectId); // プロジェクトID
            req.setAttribute("PROJECT_NAME", projectName); // プロジェクト名
            req.setAttribute("PROJECT_NAME", projectPath); // プロジェクトパス
            req.setAttribute("PROJECT_OUTLINE", projectInfo.getOutline()); // プロジェクト概要
            
            // グラフID取得
            String graphId = getGraphId(request);
            req.setAttribute("GRAPH_ID", graphId);
            
            // レポートファイルパス取得
            String reportFilePath = getReportFilePath(request);
            req.setAttribute("REPORT_FILE_PATH", reportFilePath);

            // 権限情報
            UserPermissionBean userPermBean = new UserPermissionBean();
            userPermBean.add("TRAC_ADMIN");
            req.setAttribute(IPFAuthDispTag.BEAN_USER_PROJECT_PERMISSION, userPermBean);
            
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
            log.debug("IPFNoAuthFilter#doFilter[END] " + 
                    String.format("Start=%s, End=%s, elapsed=%s", startDate, endDate, strElapsed));
        }
    }

    @Override
    public void destroy() {
        // TODO 自動生成されたメソッド・スタブ
        
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
    
    /**
     * ユーザが閲覧権限を持っているプロジェクト情報一覧を取得する。
     * 
     * @return ユーザが閲覧権限を持っているプロジェクト情報一覧
     * @throws IOException 
     * @throws Exception 
     */
    private List<ProjectInfo> getPermProjectList() throws IOException {
        
        Map<Integer, ProjectInfo> projectMap = new TreeMap<Integer, ProjectInfo>();
        
        for (Map.Entry<Object, Object> entry : IPFConfig.getInstance().entrySet()) {
            String key = (String) entry.getKey();
            String value = (String) entry.getValue();
            if (StringUtils.startsWith(key, "projectList.")) {
                String strProjectId = StringUtils.replace(key, "projectList.", "");
                if (StringUtils.isNumeric(strProjectId)) {
                    // プロジェクトID
                    Integer projectId = NumberUtils.toInt(strProjectId);
                    
                    ProjectInfo projectInfo = new ProjectInfo();
                    projectInfo.setProjectId(projectId);
                    
                    String[] projectInfos = StringUtils.splitByWholeSeparatorPreserveAllTokens(value, ",");
                    if (projectInfos.length > 0) {
                        // プロジェクト名
                        projectInfo.setProjectName(StringUtils.trim(projectInfos[0]));
                    }
                    if (projectInfos.length > 1) {
                        // プロジェクト概要
                        projectInfo.setOutline(StringUtils.trim(projectInfos[1]));
                    }
                    if (projectInfos.length > 2) {
                        // プロジェクトパス
                        projectInfo.setProjectPath(StringUtils.trim(projectInfos[2]));
                    }
                    projectMap.put(projectId, projectInfo);
                }
            }
        }
        
        List<ProjectInfo> projectList = new ArrayList<ProjectInfo>();
        projectList.addAll(projectMap.values());
        return projectList;
    }
    
    /**
     * プロジェクトIDに該当するプロジェクト情報を取得する。
     * 
     * @param projectId プロジェクトID
     * @param projectList プロジェクト情報一覧
     * @return プロジェクト情報
     */
    private ProjectInfo getProjectInfoById(Integer projectId, List<ProjectInfo> projectList) {
        ProjectInfo projectInfo = null;
        for (ProjectInfo info : projectList) {
            if (info.getProjectId().equals(projectId)) {
                projectInfo = info;
                break;
            }
        }
        return projectInfo;
    }

    /**
     * プロジェクト名に該当するプロジェクト情報を取得する。
     * 
     * @param projectName プロジェクト名
     * @param projectList プロジェクト情報一覧
     * @return プロジェクト情報
     */
    private ProjectInfo getProjectInfoByName(String projectName, List<ProjectInfo> projectList) {
        ProjectInfo projectInfo = null;
        for (ProjectInfo info : projectList) {
            if (info.getProjectName().equals(projectName)) {
                projectInfo = info;
                break;
            }
        }
        return projectInfo;
    }

    /**
     * プロジェクトパスに該当するプロジェクト情報を取得する。
     * 
     * @param projectPath プロジェクトパス
     * @param projectList プロジェクト情報一覧
     * @return プロジェクト情報
     */
    private ProjectInfo getProjectInfoByPath(String projectPath, List<ProjectInfo> projectList) {
        ProjectInfo projectInfo = null;
        for (ProjectInfo info : projectList) {
            if (info.getProjectPath().equals(projectPath)) {
                projectInfo = info;
                break;
            }
        }
        return projectInfo;
    }
    
}
