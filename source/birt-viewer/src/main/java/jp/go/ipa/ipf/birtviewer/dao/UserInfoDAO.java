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

import jp.go.ipa.ipf.birtviewer.dao.entity.UserInfo;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

/**
 * 担当情報テーブルのDAOクラス
 */
public class UserInfoDAO extends IPFCommonDAO {
    
    /**
     * コンストラクタ
     * 
     * @param conn DBコネクション
     */
    public UserInfoDAO(Connection conn) {
        super(conn);
        this.schema = ConnectionFactory.getInstance()
                .getProperty(DBCPConnectionFactory.SCHEMA_PM_DB, "");
    }
    
    /**
     * 担当情報を取得する。
     * 
     * @param userId ユーザID 
     * @param attr ユーザ属性名
     * @return 担当情報
     * @throws SQLException 
     */
    public UserInfo getUserInfo (Integer userId, String attr) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler<UserInfo> rsh = new BeanHandler<UserInfo>(UserInfo.class, rp);
        String sql = String.format(
                " SELECT            "+ 
                "   USER_ID         "+
                " , USER_NAME       "+
                " , NAME            "+
                " , VALUE           "+
                " FROM %s.USER_INFO "+
                "WHERE USER_ID = ?  "+
                "  AND NAME = ?     ",
                schema);
        return run.query(conn, sql, rsh, userId, attr);
    }
    
    /**
     * ユーザ名に該当するユーザIDを返す。
     * 
     * @param userName ユーザ名
     * @return ユーザID
     * @throws SQLException 
     */
    public Integer getUserId (String userName) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("USER_ID");
        String sql = String.format(
                " SELECT             "+ 
                "   USER_ID          "+
                " FROM %s.USER_INFO  "+
                "WHERE USER_NAME = ? ",
                schema);
        return run.query(conn, sql, rsh, userName);
    }

    /**
     * ユーザIDに該当するユーザ名を返す。
     * 
     * @param userId ユーザID
     * @return ユーザID
     * @throws SQLException 
     */
    public String getUserName (Integer userId) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler rsh = new ScalarHandler("USER_NAME");
        String sql = String.format(
                " SELECT            "+ 
                "   USER_NAME       "+
                " FROM %s.USER_INFO "+
                "WHERE USER_ID = ?  ",
                schema);
        return run.query(conn, sql, rsh, userId);
    }

    /**
     * 担当情報を登録(INSERT)する。
     * 
     * @param userId ユーザID
     * @param userName ユーザ名
     * @param name 属性名
     * @param value 属性値
     * @return 登録件数
     * @throws SQLException
     */
    public int insertUserInfo (Integer userId, String userName, String name, String value) throws SQLException {
        QueryRunner run = new QueryRunner();
        String sql = String.format(
                "INSERT INTO %s.USER_INFO ("+
                "   USER_ID   "+
                " , USER_NAME "+
                " , NAME      "+
                " , VALUE     "+
                " ) VALUES (  "+
                "   ?         "+
                " , ?         "+
                " , ?         "+
                " , ?         "+
                " )           ",
                schema);
        return run.update(conn, sql, userId, userName, name, value);
    }


    /**
     * 担当情報を更新(UPDATE)する。
     * 
     * @param userId ユーザID
     * @param name 属性名
     * @param value 属性値
     * @return 更新件数
     * @throws SQLException
     */
    public int updateUserInfo (Integer userId, String name, String value) throws SQLException {
        QueryRunner run = new QueryRunner();
        String sql = String.format(
                "UPDATE %s.USER_INFO SET VALUE = ? "+
                " WHERE USER_ID = ? "+
                 "  AND NAME = ?    ",
                 schema);
        return run.update(conn, sql, value, userId, name);
    }

}
