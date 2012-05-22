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
package jp.go.ipa.ipf.birtviewer.bean;

import java.util.HashSet;

/**
 * ユーザの権限情報を格納するクラス
 */
public class UserPermissionBean extends HashSet<String> {

    private static final long serialVersionUID = 6958745972194440152L;
    
    /** 管理者権限(Trac) */
    public static final String TRAC_ADMIN = "TRAC_ADMIN";
    
    /** 管理者権限(Redmine) */
    public static final String REDMINE_ADMIN = "";
    
    /** 定量的分析・診断機能実行権(R_M01:定量管理ダッシュボード) */
    public static final String IPF_ANALYZE = "IPF_ANALYZE";

    /**
     * 権限があるかどうか判定する。
     * 
     * @param permissions 権限名（カンマ区切りで複数指定可能）
     * @return 権限がある場合 true、ない場合 false を返す。
     */
    public boolean hasPermission(String permissions) {
        return hasPermission(permissions, true);
    }
    
    /**
     * 権限があるかどうか判定する。
     * 
     * @param permissions 権限名（カンマ区切りで複数指定可能）
     * @param allowAdmin 管理者権限を持っている場合、
     *                   全てのグラフを表示できるようにするかの設定。
     *                   true の場合表示できるようにする。
     * @return 権限がある場合 true、ない場合 false を返す。
     */
    public boolean hasPermission(String permissions, boolean allowAdmin) {
        
        if (allowAdmin) {
            // 管理者権限の確認
            if (this.contains(TRAC_ADMIN)) {
                // Trac の管理者権限を持っている場合
                return true;
            }
        }
        
        // グラフ個別権限の確認
        if (permissions != null) {
            String[] perms = permissions.split(",");
            for (int i = 0; i < perms.length; i++) {
                String perm = perms[i].trim();
                if (this.contains(perm)) {
                    // 権限がある場合
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * 定量的分析・診断機能実行権(R_M01:定量管理ダッシュボード)を取得します。
     * @return 定量的分析・診断機能実行権(R_M01:定量管理ダッシュボード)
     */
    public boolean isIpfAnalyze() {
        return this.hasPermission(IPF_ANALYZE);
    }

}
