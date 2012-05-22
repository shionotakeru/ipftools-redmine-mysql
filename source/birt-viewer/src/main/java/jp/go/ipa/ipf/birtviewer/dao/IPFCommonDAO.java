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

import org.apache.commons.dbutils.BasicRowProcessor;
import org.apache.commons.dbutils.RowProcessor;

/**
 * IPF用共通DAOクラス
 *
 */
public abstract class IPFCommonDAO {
    
    /** コネクション */
    protected Connection conn;
    
    /** Commons DBUtils 用 Row Processor */
    protected RowProcessor rp;
    
    /** スキーマ名（定量データ） */
    protected String schema;
    
    /** スキーマ名（グラフ表示データ） */
    protected String graphSchema;
    
    /***
     * コンストラクタ
     * 
     * @param conn DBコネクション
     */
    public IPFCommonDAO(Connection conn) {
        super();
        this.conn = conn;
        this.rp = new BasicRowProcessor(new CustomBeanProcessor());
    }

    /**
     * コネクションを取得します。
     * @return コネクション
     */
    public Connection getConn() {
        return conn;
    }

    /**
     * コネクションを設定します。
     * @param conn コネクション
     */
    public void setConn(Connection conn) {
        this.conn = conn;
    }

    /**
     * Commons DBUtils 用 Row Processorを取得します。
     * @return Commons DBUtils 用 Row Processor
     */
    public RowProcessor getRp() {
        return rp;
    }

    /**
     * Commons DBUtils 用 Row Processorを設定します。
     * @param rp Commons DBUtils 用 Row Processor
     */
    public void setRp(RowProcessor rp) {
        this.rp = rp;
    }

    /**
     * スキーマ名を取得します。
     * @return スキーマ名
     */
    public String getSchema() {
        return schema;
    }

    /**
     * スキーマ名を設定します。
     * @param schema スキーマ名
     */
    public void setSchema(String schema) {
        this.schema = schema;
    }

    /**
     * スキーマ名（グラフ表示データ）を取得します。
     * @return スキーマ名（グラフ表示データ）
     */
    public String getGraphSchema() {
        return graphSchema;
    }

    /**
     * スキーマ名（グラフ表示データ）を設定します。
     * @param graphSchema スキーマ名（グラフ表示データ）
     */
    public void setGraphSchema(String graphSchema) {
        this.graphSchema = graphSchema;
    }


}
