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

import java.util.Properties;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

/**
 * コネクションプーリングに対応した
 * PostgreSQL 用のDBコネクションを作成するクラス。
 */
public class DBCPPostgreSQLConnectionFactory extends DBCPConnectionFactory {

    protected static Logger log = Logger.getLogger(DBCPPostgreSQLConnectionFactory.class);
    
    @Override
    protected String createUrl(Properties properties) {
        
        String host     = properties.getProperty("host");
        String port     = properties.getProperty("port");
        String dbname   = properties.getProperty("dbname");
        
        StringBuilder sb = new StringBuilder();
        sb.append("jdbc:postgresql://");
        sb.append(host);
        if (StringUtils.isNotBlank(port)) {
            sb.append(":");
            sb.append(port);
        }
        sb.append("/");
        sb.append(dbname);
        
        return sb.toString();
    }

}
