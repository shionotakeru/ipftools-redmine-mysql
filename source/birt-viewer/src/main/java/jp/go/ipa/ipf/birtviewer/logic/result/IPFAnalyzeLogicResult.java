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
package jp.go.ipa.ipf.birtviewer.logic.result;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import jp.go.ipa.ipf.birtviewer.dao.entity.ProjectInfo;
import jp.go.ipa.ipf.birtviewer.dao.entity.WbsTicket;

/**
 * 定量的分析・診断機能のロジック処理の結果クラス。
 */
public class IPFAnalyzeLogicResult extends IPFCommonResult {
    
    private static final long serialVersionUID = 8683501304355655544L;

    /** タイトル */
    private String title;
    
    /** ユーザID */
    private Integer userId;
    
    /** ユーザ名 */
    private String userName;
    
    /** プロジェクトID */
    private Integer PROJECT_ID;
    
    /** プロジェクト名 */
    private String projectName;
    
    /** プロジェクト一覧情報 */
    private List<ProjectInfo> projectList;
    
    /** フォワード先JSPファイルパス */
    private String jspForwardPath;
    
    /** インクルードファイルパス */
    private String includeFilePath;
    
    /** レポートファイルパス */
    private String reportFilePath;
    
    /** グラフID */
    private String graphId;
    
    /** ヘルプファイルパス */
    private String helpFilePath;
    
    
    /** 現在日付 */
    private String today;
    
    /** １か月前日付 */
    private String oneMonthAgo;
    
    /** １か月後日付 */
    private String oneMonthAfter;
    
    /** 最上位のWBSチケット */
    private WbsTicket topWbsTicket;
    
    /** 最上位のWBSチケット(R_S02, R_S03用) */
    private WbsTicket topWbsTicketRs02;
    
    /**
     * コンストラクタ
     */
    public IPFAnalyzeLogicResult() {
        t = new Date().getTime();
        projectList = new ArrayList<ProjectInfo>();
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
     * プロジェクトIDを取得します。
     * @return プロジェクトID
     */
    public Integer getPROJECT_ID() {
        return PROJECT_ID;
    }

    /**
     * プロジェクトIDを設定します。
     * @param PROJECT_ID プロジェクトID
     */
    public void setPROJECT_ID(Integer PROJECT_ID) {
        this.PROJECT_ID = PROJECT_ID;
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
     * プロジェクト一覧情報を取得します。
     * @return プロジェクト一覧情報
     */
    public List<ProjectInfo> getProjectList() {
        return projectList;
    }

    /**
     * プロジェクト一覧情報を設定します。
     * @param projectList プロジェクト一覧情報
     */
    public void setProjectList(List<ProjectInfo> projectList) {
        this.projectList = projectList;
    }

    /**
     * フォワード先JSPファイルパスを取得します。
     * @return フォワード先JSPファイルパス
     */
    public String getJspForwardPath() {
        return jspForwardPath;
    }

    /**
     * フォワード先JSPファイルパスを設定します。
     * @param jspForwardPath フォワード先JSPファイルパス
     */
    public void setJspForwardPath(String jspForwardPath) {
        this.jspForwardPath = jspForwardPath;
    }

    /**
     * インクルードファイルパスを取得します。
     * @return インクルードファイルパス
     */
    public String getIncludeFilePath() {
        return includeFilePath;
    }

    /**
     * インクルードファイルパスを設定します。
     * @param includeFilePath インクルードファイルパス
     */
    public void setIncludeFilePath(String includeFilePath) {
        this.includeFilePath = includeFilePath;
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
     * ヘルプファイルパスを取得します。
     * @return ヘルプファイルパス
     */
    public String getHelpFilePath() {
        return helpFilePath;
    }

    /**
     * ヘルプファイルパスを設定します。
     * @param helpFilePath ヘルプファイルパス
     */
    public void setHelpFilePath(String helpFilePath) {
        this.helpFilePath = helpFilePath;
    }

	/**
	 * 現在日付を取得します。
	 * @return 現在日付
	 */
	public String getToday() {
	    return today;
	}

	/**
	 * 現在日付を設定します。
	 * @param today 現在日付
	 */
	public void setToday(String today) {
	    this.today = today;
	}

	/**
	 * １か月前日付を取得します。
	 * @return １か月前日付
	 */
	public String getOneMonthAgo() {
	    return oneMonthAgo;
	}

	/**
	 * １か月前日付を設定します。
	 * @param oneMonthAgo １か月前日付
	 */
	public void setOneMonthAgo(String oneMonthAgo) {
	    this.oneMonthAgo = oneMonthAgo;
	}

	/**
	 * １か月後日付を取得します。
	 * @return １か月後日付
	 */
	public String getOneMonthAfter() {
	    return oneMonthAfter;
	}

	/**
	 * １か月後日付を設定します。
	 * @param oneMonthAfter １か月後日付
	 */
	public void setOneMonthAfter(String oneMonthAfter) {
	    this.oneMonthAfter = oneMonthAfter;
	}
	
    /**
     * 最上位のWBSチケットを取得します。
     * @return 最上位のWBSチケット
     */
    public WbsTicket getTopWbsTicket() {
        return topWbsTicket;
    }

    /**
     * 最上位のWBSチケットを設定します。
     * @param topWbsTicket 最上位のWBSチケット
     */
    public void setTopWbsTicket(WbsTicket topWbsTicket) {
        this.topWbsTicket = topWbsTicket;
    }

    /**
     * 最上位のWBSチケット(R_S02, R_S03用)を取得します。
     * @return 最上位のWBSチケット(R_S02, R_S03用)
     */
    public WbsTicket getTopWbsTicketRs02() {
        return topWbsTicketRs02;
    }

    /**
     * 最上位のWBSチケット(R_S02, R_S03用)を設定します。
     * @param topWbsTicketRs02 最上位のWBSチケット(R_S02, R_S03用)
     */
    public void setTopWbsTicketRs02(WbsTicket topWbsTicketRs02) {
        this.topWbsTicketRs02 = topWbsTicketRs02;
    }

}