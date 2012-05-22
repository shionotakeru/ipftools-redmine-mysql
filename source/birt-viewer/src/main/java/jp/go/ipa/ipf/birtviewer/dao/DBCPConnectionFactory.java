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

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import javax.sql.DataSource;

import jp.go.ipa.ipf.birtviewer.util.IPFConfig;
import jp.go.ipa.ipf.birtviewer.util.IPFKettleProperties;

import org.apache.commons.dbcp.BasicDataSourceFactory;
import org.apache.log4j.Logger;

/**
 * コネクションプーリングに対応した
 * DBコネクションを作成するクラス。
 */
public abstract class DBCPConnectionFactory extends ConnectionFactory {

    protected static Logger log = Logger.getLogger(DBCPConnectionFactory.class);
    
    /** 定量データ用スキーマ */
    public static final String SCHEMA_PM_DB = "pmSchema";
    
    /** グラフデータ用スキーマ */
    public static final String SCHEMA_GRAPH_DB = "graphSchema";

    /** データソース */
    private DataSource ds;
    
    /**
     * コンストラクタ
     */
    protected DBCPConnectionFactory() {
        
        dbcpProp = new Properties();
        try {
            
            Properties kettleProp = IPFKettleProperties.getInstance();
            Properties ipfProp = IPFConfig.getInstance();
            
            String host         = kettleProp.getProperty("IPF_DB_HOST", "localhost");
            String port         = kettleProp.getProperty("IPF_DB_PORT", "5432");
            String dbname       = kettleProp.getProperty("IPF_DB_NAME", "");
            String pmSchema     = kettleProp.getProperty("IPF_DB_SCHEMA", "");
            String graphSchema  = kettleProp.getProperty("GRAPH_DB_SCHEMA", "");
            log.info("host          =" + host);
            log.info("port          =" + port);
            log.info("dbname        =" + dbname);
            log.info("pmSchema      =" + pmSchema);
            log.info("graphSchema   =" + graphSchema);
            dbcpProp.setProperty("host", host);
            dbcpProp.setProperty("port", port);
            dbcpProp.setProperty("dbname", dbname);
            dbcpProp.setProperty("pmSchema", pmSchema);
            dbcpProp.setProperty("graphSchema", graphSchema);

            String url = createUrl(dbcpProp);
            log.info("url      =" + url);
            dbcpProp.setProperty("url", url);
            
            String user     = kettleProp.getProperty("IPF_DB_USER");
            String pass     = kettleProp.getProperty("IPF_DB_PASS");
            log.info("username =" + user);
            log.info("password =" + pass);
            dbcpProp.setProperty("username", user);
            dbcpProp.setProperty("password", pass);
            
            dbcpProp.setProperty("driverClassName", ipfProp.getProperty("driverClassName"));
            dbcpProp.setProperty("initialSize",     ipfProp.getProperty("initialSize"));
            dbcpProp.setProperty("maxActive",       ipfProp.getProperty("maxActive"));
            dbcpProp.setProperty("maxIdle",         ipfProp.getProperty("maxIdle"));
            dbcpProp.setProperty("maxWait",         ipfProp.getProperty("maxWait"));
            dbcpProp.setProperty("validationQuery", ipfProp.getProperty("validationQuery"));
            
            this.ds = BasicDataSourceFactory.createDataSource(dbcpProp);
            
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * JDBC接続用URLを作成する。
     * 
     * @param properties プロパティ
     * @return JDBC接続用URL
     */
    protected abstract String createUrl(Properties properties);
    
    /**
     * コネクションを取得する。
     */
    public Connection getConnection() {
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            return conn;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
