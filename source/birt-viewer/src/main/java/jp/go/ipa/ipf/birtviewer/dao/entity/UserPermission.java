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
package jp.go.ipa.ipf.birtviewer.dao.entity;

import java.io.Serializable;

/**
 * 権限情報テーブルのエンティティクラス。
 */
public class UserPermission implements Serializable {

    private static final long serialVersionUID = 4473225367770693116L;

    /** ユーザID */
    private Integer uesrId;
    
    /** アクション */
    private String action;
    
    /** プロジェクトID */
    private Integer projectId;

    /**
     * ユーザIDを取得します。
     * @return ユーザID
     */
    public Integer getUesrId() {
        return uesrId;
    }

    /**
     * ユーザIDを設定します。
     * @param uesrId ユーザID
     */
    public void setUesrId(Integer uesrId) {
        this.uesrId = uesrId;
    }

    /**
     * アクションを取得します。
     * @return アクション
     */
    public String getAction() {
        return action;
    }

    /**
     * アクションを設定します。
     * @param action アクション
     */
    public void setAction(String action) {
        this.action = action;
    }

    /**
     * プロジェクトIDを取得します。
     * @return プロジェクトID
     */
    public Integer getProjectId() {
        return projectId;
    }

    /**
     * プロジェクトIDを設定します。
     * @param projectId プロジェクトID
     */
    public void setProjectId(Integer projectId) {
        this.projectId = projectId;
    }
    
}
