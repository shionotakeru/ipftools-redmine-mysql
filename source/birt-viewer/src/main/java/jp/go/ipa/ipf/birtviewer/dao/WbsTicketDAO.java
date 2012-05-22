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
package jp.go.ipa.ipf.birtviewer.dao;

import java.sql.Connection;
import java.sql.SQLException;

import jp.go.ipa.ipf.birtviewer.dao.entity.WbsTicket;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;

/**
 * WBSチケットテーブルのDAOクラス
 */
public class WbsTicketDAO extends IPFCommonDAO {
    
    protected static Logger log = Logger.getLogger(WbsTicketDAO.class);
    
    /**
     * コンストラクタ
     * 
     * @param conn DBコネクション
     */
    public WbsTicketDAO(Connection conn) {
        super(conn);
        this.schema = ConnectionFactory.getInstance()
                .getProperty(DBCPConnectionFactory.SCHEMA_PM_DB, "");
        this.graphSchema = ConnectionFactory.getInstance()
                .getProperty(DBCPConnectionFactory.SCHEMA_GRAPH_DB, "");
    }
    
    /**
     * WBSチケット情報を返す。
     * 
     * @param projectId プロジェクトID
     * @param wbsTicketId WBSチケットID
     * @return WBSチケット情報
     * @throws SQLException 
     */
    public WbsTicket getWbsTicket(Integer projectId, Integer wbsTicketId) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler<WbsTicket> rsh = new BeanHandler<WbsTicket>(WbsTicket.class, rp);
        String sql = String.format(
                " SELECT                "+ 
                "   TICKET_ID           "+
                "  ,PROJECT_ID          "+
                "  ,PARENT_ID           "+
                "  ,PLANNED_START_DATE  "+
                "  ,PLANNED_END_DATE    "+
                " FROM %s.WBS_TICKET    "+
                "WHERE PROJECT_ID = ?   "+
                "  AND TICKET_ID  = ?   ",
                schema);
        return run.query(conn, sql, rsh, projectId, wbsTicketId);
    }
    
    /**
     * 最上位のWBSチケットIDを返す
     * 
     * @param ProjectId プロジェクトID
     * @return 最上位のWBSチケットID
     * @throws SQLException 
     */
    public Integer getTopWbsTicketId(Integer projectId) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("TICKET_ID");
        String sql = String.format(
                "  SELECT                "+ 
                "    TICKET_ID           "+
                "  FROM %s.WBS_TICKET    "+
                " WHERE PROJECT_ID = ?   "+
                "   AND (PARENT_ID = 0 OR PARENT_ID IS NULL) "+
                " ORDER BY TICKET_ID ASC ",
                schema);
        Integer ticketId =  run.query(conn, sql, rsh, projectId);
        
        return ticketId;
    }
    
    /**
     * 最上位のWBSチケットID(R_S02,R_S03用)を返す
     * 
     * @param ProjectId プロジェクトID
     * @return 最上位のWBSチケットID
     * @throws SQLException 
     */
    public Integer getTopWbsTicketIdRs02(Integer projectId) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("TICKET_ID");
        String sql = String.format(
                " SELECT                  " +
                "    TICKET_ID            " +
                "  FROM %s.R_S02_W_MART   " +
                " WHERE PROJECT_ID = ?    " +
                "   AND PARENT_ID = 0     " +
                " GROUP BY TICKET_ID      " +
                " ORDER BY TICKET_ID ASC  ",
                graphSchema);
        Integer ticketId =  run.query(conn, sql, rsh, projectId);
        
        return ticketId;
    }

}
