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

package jp.go.ipa.ipf.sourcescale.dao;

import java.sql.Connection;

import org.apache.commons.dbutils.BasicRowProcessor;
import org.apache.commons.dbutils.RowProcessor;
import org.apache.log4j.Logger;

/**
 * ソース規模収集用共通DAOクラス
 * 
 */
public class IPFSourceSclaeDAO {

    protected static Logger log = Logger.getLogger(IPFSourceSclaeDAO.class);

    /** コネクション */
    protected Connection conn;
    
    /** Commons DBUtils 用 Row Processor */
    protected RowProcessor rp;
    
    /** スキーマ名 */
    protected String schema;
    
    /***
     * コンストラクタ
     * 
     * @param conn コネクション
     */
    public IPFSourceSclaeDAO(Connection conn) {
        super();
        this.conn = conn;
        this.rp = new BasicRowProcessor(new CustomBeanProcessor());
    }

}
