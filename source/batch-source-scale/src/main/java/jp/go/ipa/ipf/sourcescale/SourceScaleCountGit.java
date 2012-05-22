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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import jp.go.ipa.ipf.sourcescale.exception.IpfSQLNormalException;
import jp.go.ipa.ipf.sourcescale.utils.IpfJGitUtils;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.eclipse.jgit.lib.AnyObjectId;
import org.eclipse.jgit.lib.Repository;
import org.eclipse.jgit.revwalk.RevCommit;
import org.eclipse.jgit.revwalk.RevWalk;
import org.eclipse.jgit.treewalk.TreeWalk;

/**
 * 版管理ツール(Git)からソースファイルを取得して、
 * ソース規模情報を収集する処理を行う。
 */
public class SourceScaleCountGit extends SourceScaleCount {

    /** 一時ディレクトリ（変更前） */
    private static final String OLD_TMP_DIR = "ipf_git_old_";
    /** 一時ディレクトリ（変更後） */
    private static final String NEW_TMP_DIR = "ipf_git_new_";
    
    /**
     * ソース規模データ収集(Subversion用) 
     * 
     * @param args コマンドライン引数
     *  引数1 : プロジェクトID（必須）
     *  引数2 : リポジトリパス（必須）
     *  引数3 : 旧リビジョン（任意）
     *  引数4 : 新リビジョン（任意）
     */
    public static void main(String[] args) {
        
        Integer rtnCd = null;
        String msg = null;
        try {
            // コマンド引数取得
            String projectId   = null;
            String repoPath    = null;
            String oldRev      = null;
            String newRev      = null;
            if (args != null) {
                if (args.length > 0) projectId  = args[0];
                if (args.length > 1) repoPath   = args[1];
                if (args.length > 2) oldRev     = args[2];
                if (args.length > 3) newRev     = args[3];
            }
            
            log.debug("args[1] projectId  :" + projectId);
            log.debug("args[2] repoPath   :" + repoPath);
            log.debug("args[3] oldRev     :" + oldRev);
            log.debug("args[4] newRev     :" + newRev);
            
            // コマンド引数チェック
            if (projectId == null || repoPath == null) {
                throw new Exception(
                        resource.getString("git.error.parameter.length.check"));
            }
            
            // Pentaho 設定ファイル情報取得
            Map<String, String> configInfo = getPentahoConfigInfo();
            
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
    
    /**
     * ソース規模データを集計してIPF・DBに登録する。
     * 
     * @param projectId プロジェクトID
     * @param repoPath リポジトリパス
     * @param oldRev 旧リビジョン（収集開始リビジョンの１つ前のリビジョン。旧リビション自身は収集されないので注意。）
     * @param newRev 新リビジョン
     * @param configInfo Pentaho 設定ファイル情報
     * @throws Exception 
     */
    public static void sourceScaleCollect(
            String projectId, 
            String repoPath,
            String oldRev,
            String newRev,
            Map<String, String> configInfo
        ) throws Exception {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        File oldTmpDir = null;
        File newTmpDir = null;
        
        RevWalk rwalk = null;
        try {
            // DB接続
            conn = getDBConnection(configInfo);
            log.debug("DB Connect.");
            // プリペアド・ステートメント作成
            pstmt = createPstmsInsertSourceScale(conn);
            
            // 一時ディレクトリ作成
            oldTmpDir = createTempDirectory(OLD_TMP_DIR, ".tmp");
            newTmpDir = createTempDirectory(NEW_TMP_DIR, ".tmp");
            log.debug("Temp Dir Create.");
            
            // Git コミットログ取得
            Repository repository = IpfJGitUtils.getGitRepository(repoPath);
            // リビジョンリストを取得
            rwalk = IpfJGitUtils.getAllRevWalk(repository);
            
            Iterator<RevCommit> revIter = null;
            if (StringUtils.isNotBlank(oldRev)) {
                if (StringUtils.isNotBlank(newRev)) {
                    // 指定リビジョン(oldRev ... newRev)
                    revIter = IpfJGitUtils.getRevList(repository, oldRev, newRev);
                } else {
                    // 指定リビジョン(oldRev ... )
                    revIter = IpfJGitUtils.getRevList(repository, oldRev);
                }
            } else {
                // 全リビジョン
                revIter = IpfJGitUtils.getRevList(repository);
            }
            
            // リビジョンで繰り返し
            while (revIter.hasNext()) {
                RevCommit commit = revIter.next();
                
                // ログ出力（リビジョン毎）（処理開始）
                String msg = String.format(resource.getString("log.revision.collect.start"),
                        commit.getName());
                log.info(msg);
                
                TreeWalk twalk = null;
                try {
                    
                    // ソース規模DB削除
                    String revision = commit.getName(); // リビジョン
                    deleteSourceScale(conn, projectId, revision);
                    
                    twalk = IpfJGitUtils.getTreeWalk(repository, commit, rwalk);
                    // ソースファイル数分繰り返し
                    while (twalk.next()) {
                        // ソースファイル取得、ソース規模情報取得、DB登録
                        sourceScaleCollectAndDbInsert(conn, pstmt, projectId, repository, commit, twalk, oldTmpDir, newTmpDir);
                    }
                    
                    // コミット（リビジョン毎）
                    log.debug("Transaction Commit.");
                    conn.commit();
                    
                    // ログ出力（リビジョン毎）（処理成功）
                    String msgok = String.format(resource.getString("log.revision.collect.end.success"),
                            commit.getName());
                    log.info(msgok);
                    
                } catch (IpfSQLNormalException isne) {
                    try {
                        // ロールバック（リビジョン毎）
                        log.debug("Transaction Rollback.");
                        if (conn != null) conn.rollback();
                    } catch (Exception e2) { }
                    
                    // ログ出力（リビジョン毎）（処理成功）
                    String msgok = String.format(resource.getString("log.revision.collect.end.success"),
                            commit.getName());
                    log.info(msgok);
                    
                } catch (Exception e) {
                    try {
                        // ロールバック（リビジョン毎）
                        log.debug("Transaction Rollback.");
                        if (conn != null) conn.rollback();
                    } catch (Exception e2) { }
                    
                    // ログ出力（リビジョン毎）（処理失敗）
                    String msgerr = String.format(resource.getString("log.revision.collect.end.error"),
                            commit.getName());
                    log.error(msgerr, e);
                    throw new Exception(resource.getString("aboart.end") + "\n" + e.getLocalizedMessage(), e);
                    
                } finally {
                    if (twalk != null) {
                      twalk.release();
                    }
                }
            }
            // リビジョンで繰り返し
            
        } finally {
            // DB切断
            try {
                if (conn != null) conn.close();
                log.debug("DB Close.");
            } catch (Exception e) { }
            // 一時ディレクトリ削除
            if (oldTmpDir != null) FileUtils.deleteDirectory(oldTmpDir);
            if (newTmpDir != null) FileUtils.deleteDirectory(newTmpDir);
            log.debug("Temp Dir Remove.");
            // リビジョンリスト破棄
            if (rwalk != null) {
                rwalk.dispose();
            }
        }
        
    }
    
    /**
     * ソースファイルを取得して、ソース規模データを集計しDBに登録する。
     * 
     * @param conn DBコネクション
     * @param pstmt プレペアド・ステートメント
     * @param projectId プロジェクトID
     * @param repository リポジトリ
     * @param revCommit 
     * @param treeWalk 
     * @param oldTmpDir 一時ディレクトリ（変更前）
     * @param newTmpDir 一時ディレクトリ（変更後）
     * @throws Exception 
     */
    protected static void sourceScaleCollectAndDbInsert (
            Connection conn,
            PreparedStatement pstmt,
            String projectId,
            Repository repository,
            RevCommit commit,
            TreeWalk twalk,
            File oldTmpDir,
            File newTmpDir) throws Exception {
        
        String revision     = commit.getName();                     // リビジョン
        String message      = commit.getFullMessage();              // コミットメッセージ
        String author       = commit.getCommitterIdent().getName(); // 更新者
        Date updDate        = IpfJGitUtils.getCommitDate(commit);   // 更新日時
        
        byte[] filePathBytes = twalk.getRawPath();                          // ファイルフルパス（ファイル名含む） バイト配列
        String filePath      = IpfJGitUtils.getDecodeStr(filePathBytes);    // ファイルフルパス（ファイル名含む）

        String filePathOnly = FilenameUtils.getPathNoEndSeparator(filePath);  // ファイルパスのみ（ファイル名除く）
        String fileName     = FilenameUtils.getName(filePath);                // ファイル名（拡張子含む）
        String fileExt      = FilenameUtils.getExtension(filePath);           // 拡張子
        
        AnyObjectId[] objectIds = new AnyObjectId[2];
        char chg            = IpfJGitUtils.getChangeType(twalk, objectIds);   // 変更種別
        AnyObjectId  oldObjectId = objectIds[0];   // 旧ファイルオブジェクト
        AnyObjectId  newObjectId = objectIds[1];   // 新ファイルオブジェクト
        
        // ソース規模収集可否チェック
        if (! isCountable(filePath)) {
            // ログ出力（ファイル毎）（スキップ）
            String msgskip = String.format(resource.getString("log.file.collect.skip"), filePath);
            log.info(msgskip);
            return;
        }
        
        File oldTmpFile = null;
        File newTmpFile = null;
        try {
            // ソースファイル取得
            oldTmpFile = new File(oldTmpDir, fileName);
            newTmpFile = new File(newTmpDir, fileName);
            
            // 一時ファイル作成
            log.debug("Temp File Create.");
            switch (chg) {
            case 'A':
                IpfJGitUtils.createFile(repository, filePath, newObjectId, newTmpFile);
                break;
            case 'D':
                IpfJGitUtils.createFile(repository, filePath, oldObjectId, oldTmpFile);
                break;
            case 'M':
                IpfJGitUtils.createFile(repository, filePath, oldObjectId, oldTmpFile);
                IpfJGitUtils.createFile(repository, filePath, newObjectId, newTmpFile);
                break;
            }
            
            // ソース規模取得
            SourceScaleResult result = count(oldTmpFile, newTmpFile);
            result.setRevision(revision);
            result.setAuthor(author);
            result.setUpdDate(updDate);
            result.setMessage(message);
            result.setFilePath(filePathOnly);
            result.setFileName(fileName);
            result.setFileExt(fileExt);
            
            // ソース規模DB登録
            insertSourceScale(conn, pstmt, projectId, result);
            
            // ログ出力（ファイル毎）（処理成功）
            String msgok = String.format(resource.getString("log.file.collect.end"), filePath);
            log.info(msgok);
            
        } finally {
            // 一時ファイル削除
            if(oldTmpFile != null) FileUtils.deleteQuietly(oldTmpFile);
            if(newTmpFile != null) FileUtils.deleteQuietly(newTmpFile);
            log.debug("Temp File Remove.");
        }
    }

    /**
     * ソース規模データの最新リビジョンを取得する
     * 
     * @param configInfo Pentaho 設定ファイル情報
     * @param projectId プロジェクトID
     * @return 最新リビジョン
     * @throws Exception 
     */
    protected static String getLatestRevision (
            Map<String, String> configInfo,
            String projectId) throws Exception {
        
        String rev = null;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // DB接続
            conn = getDBConnection(configInfo);
            // SQL
            String sql = 
                " SELECT revision             " +
                "   FROM source_scale         " +
                "  WHERE project_id = ?       " +
                "    AND change_date IN (     " +
                "    SELECT MAX(change_date)  " +
                "      FROM source_scale      " +
                "     WHERE project_id = ?    " +
                " ) ";
            pstmt = conn.prepareStatement(sql);
            int i = 1;
            pstmt.setString(i++, projectId);
            pstmt.setString(i++, projectId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                rev = rs.getString("revision");
            }
        } finally {
            // DB切断
            DbUtils.closeQuietly(conn);
        }
        return rev;
    }

}
