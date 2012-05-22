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

import java.sql.Connection;

import jp.go.ipa.ipf.birtviewer.dao.ConnectionFactory;

import org.apache.commons.dbutils.DbUtils;

public abstract class IPFCommonLogic {

    /**
     * DBコネクションを取得する。
     * 
     * @return DBコネクション
     */
    public Connection getDBConnection() {
        ConnectionFactory factory = ConnectionFactory.getInstance();
        Connection conn = factory.getConnection();
        return conn;
    }
    
    /**
     * コミットを行う。
     * 
     * @param conn DBコネクション
     */
    public void commit(Connection conn) {
        if (conn != null) {
            try {
                conn.commit();
            } catch (Exception se) {
                se.printStackTrace();
            }
        }
    }
    
    /**
     * ロールバックを行う。
     * 
     * @param conn DBコネクション
     */
    public void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception se) {
                se.printStackTrace();
            }
        }
    }
    
    /**
     * DBコネクションをクローズする。
     * 
     * @param conn DBコネクション
     */
    public void closeDBConnection(Connection conn) {
        DbUtils.closeQuietly(conn);
    }

}
