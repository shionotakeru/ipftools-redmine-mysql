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
import java.util.List;

import jp.go.ipa.ipf.birtviewer.dao.entity.ProjectInfo;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

/**
 * プロジェクト情報テーブルのDAOクラス
 */
public class ProjectInfoDAO extends IPFCommonDAO {

    /**
     * コンストラクタ
     * 
     * @param conn DBコネクション
     */
    public ProjectInfoDAO(Connection conn) {
        super(conn);
        this.schema = ConnectionFactory.getInstance()
                .getProperty(DBCPConnectionFactory.SCHEMA_PM_DB, "");
    }
    
    /**
     * プロジェクト名からプロジェクトIDを取得する。
     * 
     * @param projectName プロジェクト名
     * @return プロジェクトID
     * @throws SQLException 
     */
    public Integer getProjectId(String projectName) throws SQLException {
        
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("PROJECT_ID");
        String sql = String.format(
                "SELECT PROJECT_ID       "+
                "  FROM %s.PROJECT_INFO  "+
                " WHERE PROJECT_NAME = ? ",
                schema);
        Integer projectId = run.query(conn, sql, rsh, projectName);
        return projectId;
    }
    
    /**
     * プロジェクトパスからプロジェクトIDを取得する。
     * 
     * @param projectPath プロジェクトパス
     * @return プロジェクトID
     * @throws SQLException 
     */
    public Integer getProjectIdFromPath(String projectPath) throws SQLException {
        
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("PROJECT_ID");
        String sql = String.format(
                "SELECT PROJECT_ID       "+
                "  FROM %s.PROJECT_INFO  "+
                " WHERE PROJECT_PATH = ? ",
                schema);
        Integer projectId = run.query(conn, sql, rsh, projectPath);
        return projectId;
    }
    
    /**
     * プロジェクトIDからプロジェクト名を取得する。
     * 
     * @param projectName プロジェクト名
     * @return プロジェクトID
     * @throws SQLException 
     */
    public String getProjectName(Integer projectId) throws SQLException {
        
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("PROJECT_NAME");
        String sql = String.format(
                "SELECT PROJECT_NAME    "+
                "  FROM %s.PROJECT_INFO "+
                " WHERE PROJECT_ID = ?",
                schema);
        String outline = run.query(conn, sql, rsh, projectId);
        return outline;
    }
    
    /**
     * プロジェクト情報を取得する。
     * 
     * @param projectId プロジェクトID
     * @return プロジェクト情報
     * @throws SQLException
     */
    public ProjectInfo getProjectInfo(Integer projectId) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler<ProjectInfo> rsh = new BeanHandler<ProjectInfo>(ProjectInfo.class, rp);
        String sql = String.format(
                "SELECT PROJECT_ID           "+ 
                "      ,PROJECT_NAME         "+
                "      ,OUTLINE              "+
                "      ,PARENT_ID            "+
                "      ,START_DATE           "+
                "      ,END_DATE             "+
                "      ,PG_START_DATE        "+
                "      ,PG_END_DATE          "+
                "      ,TROUBLE_INITIAL_DATE "+
                "      ,PROBLEM_INITIAL_DATE "+
                "      ,PROJECT_PATH         "+
                "  FROM %s.PROJECT_INFO      "+
                " WHERE PROJECT_ID = ?",
                schema);
        return run.query(conn, sql, rsh, projectId);
    }
    
    /**
     * プロジェクト情報の一覧を取得する。
     * 
     * @return プロジェクト情報一覧
     * @throws SQLException
     */
    public List<ProjectInfo> getProjectList() throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler<List<ProjectInfo>> rsh = new BeanListHandler<ProjectInfo>(ProjectInfo.class, rp);
        String sql = String.format(
                "SELECT PROJECT_ID           "+ 
                "      ,PROJECT_NAME         "+
                "      ,OUTLINE              "+
                "      ,PARENT_ID            "+
                "      ,START_DATE           "+
                "      ,END_DATE             "+
                "      ,PG_START_DATE        "+
                "      ,PG_END_DATE          "+
                "      ,TROUBLE_INITIAL_DATE "+
                "      ,PROBLEM_INITIAL_DATE "+
                "      ,PROJECT_PATH         "+
                "  FROM %s.PROJECT_INFO      "+
                " ORDER BY PROJECT_ID        ",
                schema);
        return run.query(conn, sql, rsh);
    }
}
