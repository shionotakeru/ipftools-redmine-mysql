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
import java.util.Properties;

/**
 * DBコネクションを作成するクラス。
 * 
 */
public abstract class ConnectionFactory {
    
    /** ロックオブジェクト */
    private static Object lock = new Object();
    
    /** DBコネクションを作成するクラス */
    private static ConnectionFactory factory;
    
    /** DB接続プロパティ */
    protected Properties dbcpProp;
    
    /** コンストラクタ */
    protected ConnectionFactory(){}
    
    /**
     * DBコネクション作成クラスのインスタンスを返す。
     * 
     * @return インスタンス
     */
    public static ConnectionFactory getInstance() {
        if (factory != null) {
            return factory;
        } else {
            synchronized (lock) {
                if (factory == null) {
                    factory = new DBCPPostgreSQLConnectionFactory();
                }
            }
            return factory;
        }
    }
    
    /**
     * DBコネクションを返す。
     * 
     * @return DBコネクション
     */
    public abstract Connection getConnection();
    
    public String getProperty(String key) {
        return dbcpProp.getProperty(key);
    }

    public String getProperty(String key, String defaultValue) {
        return dbcpProp.getProperty(key, defaultValue);
    }

}
