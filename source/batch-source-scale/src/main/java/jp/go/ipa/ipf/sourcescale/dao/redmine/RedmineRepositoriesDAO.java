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

package jp.go.ipa.ipf.sourcescale.dao.redmine;

import java.sql.Connection;
import java.sql.SQLException;

import jp.go.ipa.ipf.sourcescale.dao.IPFSourceSclaeDAO;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;

/**
 * Redmine
 * リポジトリ情報テーブル用DAOクラス
 */
public class RedmineRepositoriesDAO extends IPFSourceSclaeDAO {

    /**
     * コンストラクタ
     * 
     * @param conn コネクション
     * @param schema スキーマ
     */
    public RedmineRepositoriesDAO(Connection conn, String schema) {
        super(conn);
        this.schema = schema;
    }

    /**
     * リポジトリパスを取得する。
     * 
     * @param projectId プロジェクト識別子
     * @return リポジトリパス
     * @throws SQLException
     */
    public String getRepoPath(String projectId) throws SQLException {
        QueryRunner run = new QueryRunner();
        ResultSetHandler<Object> rsh = new ScalarHandler("url");
        String sql = String.format(
                "SELECT r.url AS url "+
                "  FROM %s.repositories r INNER JOIN %s.projects p ON (r.project_id = p.id) "+
                " WHERE p.identifier = ? ",
                schema, schema);
        return (String) run.query(conn, sql, rsh, projectId);
    }

}
