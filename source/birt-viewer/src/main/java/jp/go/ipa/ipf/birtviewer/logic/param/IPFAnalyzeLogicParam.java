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
package jp.go.ipa.ipf.birtviewer.logic.param;

import java.io.Serializable;
import java.util.List;
import java.util.Locale;

import jp.go.ipa.ipf.birtviewer.dao.entity.ProjectInfo;

/**
 * 定量的分析・診断機能のロジック処理のパラメータクラス。
 */
public class IPFAnalyzeLogicParam implements Serializable {

    private static final long serialVersionUID = 9109064019712131680L;

    /** ユーザID */
    private Integer userId;
    
    /** ユーザ名 */
    private String userName;
    
    /** プロジェクトID */
    private Integer projectId;
    
    /** プロジェクト名 */
    private String projectName;
    
    /** プロジェクトパス */
    private String projectPath;
    
    /** プロジェクト一覧 */
    private List<ProjectInfo> projectList;
    
    /** グラフID */
    private String graphId;
    
    /** レポートファイルパス */
    private String reportFilePath;
    
    /** JSPファイルパス */
    private String jspPaht;
    
    /** ロケール */
    private Locale locale;
    
    /** コンテキストパスの絶対パス */
    private String contextRealPath;
    
    /**
     * グラフIDを取得します。
     * @return グラフID
     */
    public String getGraphId() {
        return graphId;
    }
    /**
     * グラフIDを設定します。
     * @param graphId グラフID
     */
    public void setGraphId(String graphId) {
        this.graphId = graphId;
    }
    /**
     * レポートファイルパスを取得します。
     * @return レポートファイルパス
     */
    public String getReportFilePath() {
        return reportFilePath;
    }
    /**
     * レポートファイルパスを設定します。
     * @param reportFilePath レポートファイルパス
     */
    public void setReportFilePath(String reportFilePath) {
        this.reportFilePath = reportFilePath;
    }
    /**
     * JSPファイルパスを取得します。
     * @return JSPファイルパス
     */
    public String getJspPaht() {
        return jspPaht;
    }
    /**
     * JSPファイルパスを設定します。
     * @param jspPaht JSPファイルパス
     */
    public void setJspPaht(String jspPaht) {
        this.jspPaht = jspPaht;
    }
    /**
     * ロケールを取得します。
     * @return ロケール
     */
    public Locale getLocale() {
        return locale;
    }
    /**
     * ロケールを設定します。
     * @param locale ロケール
     */
    public void setLocale(Locale locale) {
        this.locale = locale;
    }



    /**
     * プロジェクトIDを取得します。
     * @return プロジェクトID
     */
    public Integer getProjectId() {
        return projectId;
    }
    /**
     * プロジェクトIDを設定します。
     * @param projectId プロジェクトID
     */
    public void setProjectId(Integer projectId) {
        this.projectId = projectId;
    }
    /**
     * プロジェクト名を取得します。
     * @return プロジェクト名
     */
    public String getProjectName() {
        return projectName;
    }
    /**
     * プロジェクト名を設定します。
     * @param projectName プロジェクト名
     */
    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    /**
     * プロジェクトパスを取得します。
     * @return プロジェクトパス
     */
    public String getProjectPath() {
        return projectPath;
    }
    /**
     * プロジェクトパスを設定します。
     * @param projectPath プロジェクトパス
     */
    public void setProjectPath(String projectPath) {
        this.projectPath = projectPath;
    }
    /**
     * プロジェクト一覧を取得します。
     * @return プロジェクト一覧
     */
    public List<ProjectInfo> getProjectList() {
        return projectList;
    }
    /**
     * プロジェクト一覧を設定します。
     * @param projectList プロジェクト一覧
     */
    public void setProjectList(List<ProjectInfo> projectList) {
        this.projectList = projectList;
    }
    /**
     * ユーザIDを取得します。
     * @return ユーザID
     */
    public Integer getUserId() {
        return userId;
    }
    /**
     * ユーザIDを設定します。
     * @param userId ユーザID
     */
    public void setUserId(Integer userId) {
        this.userId = userId;
    }
    /**
     * ユーザ名を取得します。
     * @return ユーザ名
     */
    public String getUserName() {
        return userName;
    }
    /**
     * ユーザ名を設定します。
     * @param userName ユーザ名
     */
    public void setUserName(String userName) {
        this.userName = userName;
    }
    /**
     * コンテキストパスの絶対パスを取得します。
     * @return コンテキストパスの絶対パス
     */
    public String getContextRealPath() {
        return contextRealPath;
    }
    /**
     * コンテキストパスの絶対パスを設定します。
     * @param contextRealPath コンテキストパスの絶対パス
     */
    public void setContextRealPath(String contextRealPath) {
        this.contextRealPath = contextRealPath;
    }
    
}
