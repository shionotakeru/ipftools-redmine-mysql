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
package jp.go.ipa.ipf.birtviewer.logic;

import java.io.File;
import java.sql.Connection;
import java.util.Date;
import java.util.Locale;

import jp.go.ipa.ipf.birtviewer.dao.UserInfoDAO;
import jp.go.ipa.ipf.birtviewer.dao.WbsTicketDAO;
import jp.go.ipa.ipf.birtviewer.dao.entity.UserInfo;
import jp.go.ipa.ipf.birtviewer.dao.entity.WbsTicket;
import jp.go.ipa.ipf.birtviewer.exception.IPFException;
import jp.go.ipa.ipf.birtviewer.logic.param.IPFAnalyzeLogicParam;
import jp.go.ipa.ipf.birtviewer.logic.result.IPFAnalyzeLogicResult;
import jp.go.ipa.ipf.birtviewer.util.IPFAnalyzeUtils;
import jp.go.ipa.ipf.birtviewer.util.IPFMessage;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang.time.DateUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * 定量的分析・診断機能のロジック処理を行うクラス。
 */
public class IPFAnalyzeLogic extends IPFCommonLogic {
    
    protected static Logger log = Logger.getLogger(IPFAnalyzeLogic.class);

    public IPFAnalyzeLogicResult doLogic(IPFAnalyzeLogicParam prm) {
        
        IPFAnalyzeLogicResult result = new IPFAnalyzeLogicResult();
        
        // ロケール
        Locale locale = prm.getLocale();
        
        // ログレベル
        Level logLevel = log.getEffectiveLevel();
        int level = Level.INFO_INT;
        if (logLevel != null) {
            level = logLevel.toInt();
        }
        result.setLogLevel(level);
        
        Connection conn = null;
        try {
            // DB接続
            conn = getDBConnection();
            
            // DAO準備
            UserInfoDAO userDao = new UserInfoDAO(conn);
            WbsTicketDAO wbsTicketDao = new WbsTicketDAO(conn);
            
            // CSS用ロケールセット
            String cssLocale = IPFMessage.getInstance(locale).getString("css.locale");
            result.setCssLocale(cssLocale);
            
            // プロジェクトID、プロジェクト名
            Integer projectId = prm.getProjectId();
            String projectName = prm.getProjectName();
            String projectPath = prm.getProjectPath();
            result.setPROJECT_ID(projectId);
            result.setProjectName(projectName);
            
            // ユーザ名取得
            result.setUserName(prm.getUserName());
            
            // プロジェクト一覧情報を取得
            result.setProjectList(prm.getProjectList());
            
            // JSP情報を設定
            String graphId = prm.getGraphId();
            String reportFilePath = prm.getReportFilePath();
            String includeFilePath = null;
            String title = null;
            
            if (StringUtils.equals(graphId, "R_M01")) {
                // ダッシュボード
                title = IPFMessage.getInstance(locale).getString(graphId);
                
                String dashboardKey = "dashboard." + projectPath;
                
                // JSPファイルパス
                String patternJspFile = null;
                
                // JSPファイルパス（パラメータ）
                String reqJspPath = prm.getJspPaht();
                
                // JSPファイルパス（user_info テーブル）
                String dbJspPath = null;
                UserInfo userDashboardInfo = userDao.getUserInfo(prm.getUserId(), dashboardKey);
                if (userDashboardInfo != null) {
                    dbJspPath = StringUtils.defaultString(userDashboardInfo.getValue());
                }
                
                if (reqJspPath != null) {
                    // パラメータに指定されている場合
                    
                    if (dbJspPath == null) {
                        // user_info テーブルにJSPファイルパスが設定されていない場合 → INSERT
                        userDao.insertUserInfo(prm.getUserId(), prm.getUserName(), dashboardKey, reqJspPath);
                    } else {
                        // user_info テーブルにJSPファイルパスが設定されている場合 → UPDATE
                        userDao.updateUserInfo(prm.getUserId(), dashboardKey, reqJspPath);
                    }
                    
                    // パラメータのJSPファイルパス
                    patternJspFile = reqJspPath;
                } else {
                    // パラメータに指定されていない場合
                    
                    if (dbJspPath != null) {
                        // user_info テーブルのJSPファイルパス
                        patternJspFile = userDashboardInfo.getValue();
                    }
                }
                
                log.info("reqJspPath=" + reqJspPath);
                log.info("dbJspPath=" + dbJspPath);
                log.info("patternJspFile=" + patternJspFile);
                
                if (StringUtils.isBlank(patternJspFile)) {
                    // ダッシュボード表示パターンを取得できない場合（デフォルト表示）。
                    patternJspFile = "defaultPattern.jsp";
//                    throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0310",
//                            dashboardKey));
                }
                includeFilePath = "/dashboard/" + patternJspFile;
                
                // ダッシュボードパターンファイル存在チェック
                String jspRealPath = prm.getContextRealPath();
                File includeFile = new File(jspRealPath + includeFilePath);
                if (!(includeFile.isFile() && includeFile.canRead())) {
                    // ダッシュボードパターンファイルが存在しない場合
                    throw new IPFException(IPFMessage.getInstance(locale).getFormatString("0309", 
                            includeFilePath));
                }

            } else {
                // 個別グラフ
                title = IPFMessage.getInstance(locale).getString(graphId, "－");
                includeFilePath = "/WEB-INF/jsp/graph.jsp";
            }
            result.setGraphId(graphId);
            result.setReportFilePath(reportFilePath);
            result.setTitle(title);
            result.setIncludeFilePath(includeFilePath);
            
            // ヘルプファイルリンク設定
            String helpFilePath = "report/help/IPF_TOP/IPF_HELP.html";
            if (StringUtils.isNotBlank(graphId)) {
                helpFilePath = "report/help/" + graphId + "/IPF_" + graphId + "_HELP.html";
            }
            result.setHelpFilePath(helpFilePath);
            
            // フォワード先JSP設定
            String jspForwardPath = null;
            if (StringUtils.startsWith(graphId, "R_M")) {
                // メインウィンドウに表示
                jspForwardPath = "/WEB-INF/jsp/mainWindow.jsp";
            } else {
                // サブウィンドウに表示
                jspForwardPath = "/WEB-INF/jsp/subWindow.jsp";
            }
            result.setJspForwardPath(jspForwardPath);
            
            // グラフパラメータ生成
            
            // 現在日付
            Date today = new Date();
            result.setToday(DateFormatUtils.format(today, "yyyy/MM/dd"));
            
            // １か月前日付
            Date oneMonthAgo = DateUtils.addMonths(today, -1);
            result.setOneMonthAgo(DateFormatUtils.format(oneMonthAgo, "yyyy/MM/dd"));
            
            // １か月後日付
            Date oneMonthAfter = DateUtils.addMonths(today, +1);
            result.setOneMonthAfter(DateFormatUtils.format(oneMonthAfter, "yyyy/MM/dd"));
            
            // 最上位のWBSチケット情報
            Integer topTicketId = wbsTicketDao.getTopWbsTicketId(projectId);
            WbsTicket topWbsTicket = wbsTicketDao.getWbsTicket(projectId, topTicketId);
            if (topWbsTicket == null) {
                // WBSチケットがない場合
                topWbsTicket = new WbsTicket();
                topWbsTicket.setTicketId(0);
                topWbsTicket.setPlannedStartDate(oneMonthAgo);
                topWbsTicket.setPlannedEndDate(oneMonthAfter);
            }
            result.setTopWbsTicket(topWbsTicket);
            
            // 最上位のWBSチケット情報(R_S02,R_S03用)
            Integer topTicketIdRs02 = wbsTicketDao.getTopWbsTicketIdRs02(projectId);
            WbsTicket topWbsTicketRs02 = null;
            if (topTicketIdRs02 == null) {
                // r_s02_w_mart にWBSチケットがない場合
                topWbsTicketRs02 = new WbsTicket();
                topWbsTicketRs02.setTicketId(0);
                topWbsTicketRs02.setPlannedStartDate(oneMonthAgo);
                topWbsTicketRs02.setPlannedEndDate(oneMonthAfter);
            } else {
                topWbsTicketRs02 = wbsTicketDao.getWbsTicket(projectId, topTicketIdRs02);
                if (topWbsTicketRs02 == null) {
                    // wbs_ticket に WBSチケットがない場合
                    topWbsTicketRs02 = new WbsTicket();
                    topWbsTicketRs02.setTicketId(topTicketIdRs02);
                    topWbsTicketRs02.setPlannedStartDate(oneMonthAgo);
                    topWbsTicketRs02.setPlannedEndDate(oneMonthAfter);
                }
            }
            result.setTopWbsTicketRs02(topWbsTicketRs02);
            
            commit(conn);
        } catch (IPFException e) {
            rollback(conn);
            result.setJspForwardPath("/WEB-INF/jsp/errorWindow.jsp");
            result.setErrMsg(e.getMessage());
            
        } catch (Exception e) {
            e.printStackTrace();
            rollback(conn);
            result.setJspForwardPath("/WEB-INF/jsp/errorWindow.jsp");
            result.setErrMsg(e.getMessage());
            result.setStackTrace(IPFAnalyzeUtils.getStackTrace(e));
        } finally {
            closeDBConnection(conn);
        }
        return result;
    }
    
}



