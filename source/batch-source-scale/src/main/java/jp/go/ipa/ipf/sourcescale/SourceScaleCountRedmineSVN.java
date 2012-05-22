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

package jp.go.ipa.ipf.sourcescale;

import java.io.File;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;

/**
 * Redmine 用
 * 版管理ツール(Subversoin)からソースファイルを取得して、
 * ソース規模情報を収集する処理を行う。
 */
public class SourceScaleCountRedmineSVN extends SourceScaleCountSVN {
    
    /**
     * ソース規模データ収集(Redmine - Subversion用) 
     * 
     * @param args コマンドライン引数
     *  引数1 : プロジェクト識別子（必須）
     *  引数2 : 収集開始リビジョン番号（任意、デフォルト1）
     */
    public static void main(String[] args) {
        
        Integer rtnCd = null;
        String msg = null;
        try {
            // コマンド引数取得
            String projectId        = null;
            String startRevStr      = null;
            if (args != null) {
                if (args.length > 0) projectId   = args[0];
                if (args.length > 1) startRevStr = args[1];
            }
            
            log.debug("args[1] projectId   :" + projectId);
            log.debug("args[2] startRevStr :" + startRevStr);
            
            // コマンド引数チェック
            if (projectId == null) {
                throw new Exception(
                        resource.getString("redmine.svn.error.parameter.length.check"));
            }
            long startRev = 0;
            if (startRevStr != null) {
                if(! StringUtils.isNumeric(startRevStr)) {
                    throw new Exception(
                            resource.getString("svn.error.parameter.startrev.numeric.check"));
                }
                startRev = NumberUtils.toLong(startRevStr);
            }
            
            // Pentaho 設定ファイル情報取得
            Map<String, String> configInfo = getPentahoConfigInfo();
            
            // リポジトリパス取得
            String repoPath = null;
            String url = getRedmineRepoPath(projectId);
            if(StringUtils.startsWith(url, "file:///")) {
                repoPath = StringUtils.removeStart(url, "file:///");
            } else {
                throw new Exception(String.format(
                        resource.getString("redmine.error.repopath.invalid"),
                        url));
            }
            
            if (StringUtils.isBlank(repoPath)) {
                // リポジトリパスが設定されていない
                throw new Exception(
                        resource.getString("redmine.error.repopath.no.setting"));
            }
            File repoPathFile = new File(repoPath);
            if (! (repoPathFile.isDirectory() && repoPathFile.canRead())) {
                // リポジトリパスが存在しない
                throw new Exception(String.format(
                        resource.getString("redmine.error.repopath.cannot.read"),
                        repoPath));
            }
            
            // ソース規模収集
            sourceScaleCollect(projectId, repoPath, startRev, configInfo);
            
            // 正常終了
            rtnCd = 0;
            msg = resource.getString("normal.end");
            log.info(msg);
        } catch (Exception e) {
            // 異常終了
            rtnCd = (rtnCd == null ? 1 : rtnCd);
            msg = resource.getString("abort.end");
            log.error(msg, e);
        } finally {
            System.err.println(msg);
            System.exit(rtnCd);
        }
    }
}
