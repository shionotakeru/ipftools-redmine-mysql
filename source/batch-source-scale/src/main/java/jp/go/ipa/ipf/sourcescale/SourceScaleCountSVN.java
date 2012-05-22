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
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import jp.go.ipa.ipf.sourcescale.exception.IpfSQLNormalException;
import jp.go.ipa.ipf.sourcescale.utils.IpfSVNKitUtils;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.tmatesoft.svn.core.SVNLogEntry;
import org.tmatesoft.svn.core.SVNLogEntryPath;
import org.tmatesoft.svn.core.io.SVNRepository;

/**
 * 版管理ツール(Subversoin)からソースファイルを取得して、
 * ソース規模情報を収集する処理を行う。
 */
public class SourceScaleCountSVN extends SourceScaleCount {
    
    /** 一時ディレクトリ（変更前） */
    private static final String OLD_TMP_DIR = "ipf_svn_old_";
    /** 一時ディレクトリ（変更後） */
    private static final String NEW_TMP_DIR = "ipf_svn_new_";
    
    /**
     * ソース規模データ収集(Subversion用) 
     * 
     * @param args コマンドライン引数
     *  引数1 : プロジェクトID（必須）
     *  引数2 : リポジトリパス（必須）
     *  引数3 : 収集開始リビジョン番号（任意、デフォルト1）
     * 
     */
    public static void main(String[] args) {
        
        Integer rtnCd = null;
        String msg = null;
        try {
            // コマンド引数取得
            String projectId   = null;
            String repoPath    = null;
            String startRevStr = null;
            if (args != null) {
                if (args.length > 0) projectId   = args[0];
                if (args.length > 1) repoPath    = args[1];
                if (args.length > 2) startRevStr = args[2];
            }
            
            log.debug("args[1] projectId   :" + projectId);
            log.debug("args[2] repoPath    :" + repoPath);
            log.debug("args[3] startRevStr :" + startRevStr);
            
            // コマンド引数チェック
            if (projectId == null || repoPath == null) {
                throw new Exception(
                        resource.getString("svn.error.parameter.length.check"));
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
    
    /**
     * ソース規模データを集計してIPF・DBに登録する。
     * 
     * @param projectId プロジェクトID
     * @param repoPath リポジトリパス
     * @param startRev 開始リビジョン
     * @param configInfo Pentaho 設定ファイル情報
     * @throws Exception 
     */
    public static void sourceScaleCollect(
            String projectId, 
            String repoPath, 
            long startRev, 
            Map<String, String> configInfo
        ) throws Exception {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        File oldTmpDir = null;
        File newTmpDir = null;
        
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
            
            // Subversion コミットログ取得
            SVNRepository repository = IpfSVNKitUtils.getSVNRepository(repoPath);
            Collection logEntries = IpfSVNKitUtils.getSVNCommitLog(repository, startRev);
            
            // リビジョンで繰り返し
            for (Iterator entries = logEntries.iterator(); entries.hasNext();) {
                SVNLogEntry logEntry = (SVNLogEntry) entries.next();
                
                // ログ出力（リビジョン毎）（処理開始）
                String msg = String.format(resource.getString("log.revision.collect.start"),
                        logEntry.getRevision());
                log.info(msg);
                
                try {
                    
                    // ソース規模DB削除
                    long longRevision = logEntry.getRevision(); // リビジョン番号
                    String revision = Long.toString(longRevision);
                    deleteSourceScale(conn, projectId, revision);
                    
                    if (logEntry.getChangedPaths().size() > 0) {
                        Set changedPathsSet = logEntry.getChangedPaths().keySet();
                        // ソースファイル数分繰り返し
                        for (Iterator changedPaths = changedPathsSet.iterator(); changedPaths.hasNext();) {
                            SVNLogEntryPath entryPath = (SVNLogEntryPath) logEntry.getChangedPaths().get(changedPaths.next());
                            
                            // ソースファイル取得、ソース規模情報取得、DB登録
                            sourceScaleCollectAndDbInsert(conn, pstmt, projectId, repository, logEntry, entryPath, oldTmpDir, newTmpDir);
                        }
                    }
                    
                    // コミット（リビジョン毎）
                    log.debug("Transaction Commit.");
                    conn.commit();
                    
                    // ログ出力（リビジョン毎）（処理成功）
                    String msgok = String.format(resource.getString("log.revision.collect.end.success"),
                            logEntry.getRevision());
                    log.info(msgok);
                    
                } catch (IpfSQLNormalException isne) {
                    try {
                        // ロールバック（リビジョン毎）
                        log.debug("Transaction Rollback.");
                        if (conn != null) conn.rollback();
                    } catch (Exception e2) { }
                    
                    // ログ出力（リビジョン毎）（処理成功）
                    String msgok = String.format(resource.getString("log.revision.collect.end.success"),
                            logEntry.getRevision());
                    log.info(msgok);
                    
                } catch (Exception e) {
                    try {
                        // ロールバック（リビジョン毎）
                        log.debug("Transaction Rollback.");
                        if (conn != null) conn.rollback();
                    } catch (Exception e2) { }
                    
                    // ログ出力（リビジョン毎）（処理失敗）
                    String msgerr = String.format(resource.getString("log.revision.collect.end.error"),
                            logEntry.getRevision());
                    log.error(msgerr, e);
                    throw new Exception(resource.getString("aboart.end") + "\n" + e.getLocalizedMessage(), e);
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
        }
        
    }
    
    /**
     * ソースファイルを取得して、ソース規模データを集計しDBに登録する。
     * 
     * @param conn DBコネクション
     * @param pstmt プレペアド・ステートメント
     * @param projectId プロジェクトID
     * @param repository リポジトリ
     * @param logEntry コミットログ
     * @param entryPath コミットファイル
     * @param oldTmpDir 一時ディレクトリ（変更前）
     * @param newTmpDir 一時ディレクトリ（変更後）
     * @throws Exception 
     */
    protected static void sourceScaleCollectAndDbInsert (
            Connection conn,
            PreparedStatement pstmt,
            String projectId,
            SVNRepository repository,
            SVNLogEntry logEntry,
            SVNLogEntryPath entryPath,
            File oldTmpDir,
            File newTmpDir) throws Exception {
        
        long revision       = logEntry.getRevision();  // リビジョン番号
        String message      = logEntry.getMessage();   // コミットメッセージ
        String author       = logEntry.getAuthor();    // 更新者
        Date updDate        = logEntry.getDate();      // 更新日時
        
        String filePath     = entryPath.getPath();                            // ファイルフルパス（ファイル名含む）
        String filePathOnly = FilenameUtils.getPathNoEndSeparator(filePath);  // ファイルパスのみ（ファイル名除く）
        String fileName     = FilenameUtils.getName(filePath);                // ファイル名（拡張子含む）
        String fileExt      = FilenameUtils.getExtension(filePath);           // 拡張子
        char   chg          = entryPath.getType();                            // 変更種別
        
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
                IpfSVNKitUtils.createFile(repository, filePath, revision, newTmpFile);
                break;
            case 'D':
                IpfSVNKitUtils.createFile(repository, filePath, (revision - 1), oldTmpFile);
                break;
            case 'M':
                IpfSVNKitUtils.createFile(repository, filePath, (revision - 1), oldTmpFile);
                IpfSVNKitUtils.createFile(repository, filePath, revision, newTmpFile);
                break;
            }
            
            // ソース規模取得
            SourceScaleResult result = count(oldTmpFile, newTmpFile);
            result.setRevision(Long.toString(revision));
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
            if (oldTmpFile != null) FileUtils.deleteQuietly(oldTmpFile);
            if (newTmpFile != null) FileUtils.deleteQuietly(newTmpFile);
            log.debug("Temp File Remove.");
        }
    }

}
