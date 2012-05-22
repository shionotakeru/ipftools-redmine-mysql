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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.go.ipa.ipf.birtviewer.bean.UserPermissionBean;
import jp.go.ipa.ipf.birtviewer.dao.entity.UserPermission;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

/**
 * 権限情報テーブルのDAOクラス。
 */
public class UserPermissionDAO extends IPFCommonDAO {
    
    /**
     * コンストラクタ
     * 
     * @param conn DBコネクション
     */
    public UserPermissionDAO(Connection conn) {
        super(conn);
        this.schema = ConnectionFactory.getInstance()
                .getProperty(DBCPConnectionFactory.SCHEMA_PM_DB, "");
    }

    /**
     * 指定したユーザの権限情報(全プロジェクト分)を取得する。
     * 
     * @param userId ユーザID
     * @return 権限情報
     * @throws SQLException 
     */
    public Map<Integer, UserPermissionBean> getUserProjectPermission(Integer userId) throws SQLException {
        
        QueryRunner run = new QueryRunner();
        ResultSetHandler<List<UserPermission>> rsh = new BeanListHandler<UserPermission>(UserPermission.class, rp);
        String sql = String.format(
            " SELECT USER_ID             " +
            "       ,ACTION              " +
            "       ,PROJECT_ID          " +
            "   FROM %s.USER_PERMISSION  " +
            "  WHERE USER_ID = ?         " +
            "  ORDER BY PROJECT_ID ASC   ",
            schema);
        List<UserPermission> list = run.query(conn, sql, rsh, userId);
        
        Map<Integer, UserPermissionBean> upm = new HashMap<Integer, UserPermissionBean>();
        for (UserPermission up : list) {
            Integer projectId = up.getProjectId();
            String action = up.getAction();
            if (! upm.containsKey(projectId)) {
                upm.put(projectId, new UserPermissionBean());
            }
            UserPermissionBean upb = upm.get(projectId);
            upb.add(action);
        }
        return upm;
    }
    
    /**
     * 指定したユーザの該当プロジェクトの権限情報を取得する。
     * 
     * @param userId ユーザID
     * @return 権限情報
     * @throws SQLException 
     */
    public UserPermissionBean getUserPermission(Integer userId, Integer projectId) throws SQLException {
        
        QueryRunner run = new QueryRunner();
        ResultSetHandler<List<UserPermission>> rsh = new BeanListHandler<UserPermission>(UserPermission.class, rp);
        String sql = String.format(
            " SELECT USER_ID             " +
            "       ,ACTION              " +
            "       ,PROJECT_ID          " +
            "   FROM %s.USER_PERMISSION  " +
            "  WHERE USER_ID = ?         " +
            "    AND PROJECT_ID = ?      " +
            "  ORDER BY PROJECT_ID ASC   ",
            schema);
        List<UserPermission> list = run.query(conn, sql, rsh, userId, projectId);
        
        UserPermissionBean upb = new UserPermissionBean();
        for (UserPermission up : list) {
            String action = up.getAction();
            upb.add(action);
        }
        return upb;
    }
    
    /**
     * 指定したユーザの名のIDを取得する。
     * 
     * @param userName ユーザ名
     * @return 権限情報
     * @throws SQLException 
     */
    public Integer getUserId(String userName) throws SQLException {
        
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("USER_ID");
        String sql = String.format(
            "SELECT USER_ID         "+
            "  FROM %s.USER_INFO    "+
            " WHERE USER_NAME = ?   "+
            " GROUP BY USER_ID      ",
            schema);
        return run.query(conn, sql, rsh, userName);
    }

}
