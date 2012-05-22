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

/**
 * Redmine 用
 * 版管理ツール(Git)からソースファイルを取得して、
 * ソース規模情報を収集する処理を行う。
 */
public class SourceScaleCountRedmineGit extends SourceScaleCountGit {

    /**
     * ソース規模データ収集(Redmine - Git用) 
     * 
     * @param args コマンドライン引数
     *  引数1 : プロジェクト識別子（必須）
     *  引数2 : 旧リビジョン（任意）
     *  引数3 : 新リビジョン（任意）
     */
    public static void main(String[] args) {
        
        Integer rtnCd = null;
        String msg = null;
        try {
            // コマンド引数取得
            String projectId        = null;
            String oldRev           = null;
            String newRev           = null;
            if (args != null) {
                if (args.length > 0) projectId  = args[0];
                if (args.length > 1) oldRev     = args[1];
                if (args.length > 2) newRev     = args[2];
            }
            
            log.debug("args[1] projectId  :" + projectId);
            log.debug("args[2] oldRev     :" + oldRev);
            log.debug("args[3] newRev     :" + newRev);
            
            // コマンド引数チェック
            if (projectId == null) {
                throw new Exception(
                        resource.getString("redmine.git.error.parameter.length.check"));
            }
            if (oldRev != null && newRev == null) {
                // 旧リビジョンが指定されていて、新リビジョンが指定されていない場合エラー
                throw new Exception(
                        resource.getString("git.error.parameter.revision.check"));
            }
            
            // Pentaho 設定ファイル情報取得
            Map<String, String> configInfo = getPentahoConfigInfo();
            
            // リポジトリパス取得
            String repoPath = getRedmineRepoPath(projectId);
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
            sourceScaleCollect(projectId, repoPath, oldRev, newRev, configInfo);
            
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
