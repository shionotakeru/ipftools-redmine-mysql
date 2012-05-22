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
 * 担当情報テーブルのエンティティクラス。
 *
 */
public class UserInfo implements Serializable {
    
    private static final long serialVersionUID = -5795009859607076742L;

    /** ユーザID */
    private int userId;
    
    /** ユーザ名 */
    private String userName;
    
    /** 属性名 */
    private String name;
    
    /** 属性値 */
    private String value;

    /**
     * ユーザIDを取得します。
     * @return ユーザID
     */
    public int getUserId() {
        return userId;
    }

    /**
     * ユーザIDを設定します。
     * @param userId ユーザID
     */
    public void setUserId(int userId) {
        this.userId = userId;
    }

    /**
     * ユーザ名を取得します。
     * @return ユーザ名
     */
    public String getUserName() {
        return userName;
    }

    /**
     * ユーザ名を設定します。
     * @param userName ユーザ名
     */
    public void setUserName(String userName) {
        this.userName = userName;
    }

    /**
     * 属性名を取得します。
     * @return 属性名
     */
    public String getName() {
        return name;
    }

    /**
     * 属性名を設定します。
     * @param name 属性名
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * 属性値を取得します。
     * @return 属性値
     */
    public String getValue() {
        return value;
    }

    /**
     * 属性値を設定します。
     * @param value 属性値
     */
    public void setValue(String value) {
        this.value = value;
    }
    
}
