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

package jp.go.ipa.ipf.sourcescale.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Collection;

import jp.go.ipa.ipf.sourcescale.SourceScaleCount;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNNodeKind;
import org.tmatesoft.svn.core.SVNProperties;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;

/**
 *  Subversion アクセス用ユーティリティクラス。
 */
public class IpfSVNKitUtils {

    /** ロガー */
    protected static Logger log = Logger.getLogger(SourceScaleCount.LOGGER_NAME);

    /**
     * Subversion のリポジトリオブジェクトを返す。
     * 
     * @param repoUrl リポジトリURL
     * @return Subversion のリポジトリオブジェクト
     * @throws SVNException 
     */
    public static SVNRepository getSVNRepository(String repoUrl) throws SVNException {
        
        SVNURL url = null ;
        try {
            // url の プロトコルが http, https, svn, svn+ssh, file の場合
            url = SVNURL.parseURIDecoded(repoUrl);
        } catch (SVNException svne) {
            try {
                // ファイルパスを直接指定した場合(例 C://svn/repos/)
                url = SVNURL.fromFile(new File(repoUrl));
            } catch (SVNException e) {
                throw svne;
            }
        }
        log.debug("url:" + url.toDecodedString());
        
        // プロトコルに応じたライブラリの初期化処理を行う
        String protocol = url.getProtocol();
        log.debug("protocol:" + protocol);
        
        if (protocol.startsWith("http")) {
            // for DAV (over http and https)
            log.debug(String.format("DAVRepositoryFactory.setup()"));
            DAVRepositoryFactory.setup();
            
        } else if (protocol.startsWith("svn")) {
            // for svn (over svn and svn+ssh)
            log.debug(String.format("SVNRepositoryFactoryImpl.setup()"));
            SVNRepositoryFactoryImpl.setup();
            
        } else if (protocol.startsWith("file")) {
            // For using over file:///
            log.debug(String.format("FSRepositoryFactory.setup()"));
            FSRepositoryFactory.setup();
            
        }
        
        SVNRepository repository = SVNRepositoryFactory.create(url);
        
        return repository;
    }
    
    /**
     * Subversion のコミットログを返す。
     * 
     * @param repository リポジトリ
     * @param startRevision 収集開始リビジョン
     * @return Subversion のコミットログ
     * @throws SVNException 
     */
    public static Collection getSVNCommitLog(SVNRepository repository, long startRevision) throws SVNException {
        
        long endRevision   = -1; //HEAD (the latest) revision
        Collection logEntries = repository.log(new String[] {""}, null, startRevision, endRevision, true, true);
        return logEntries;
        
    }
    
    /**
     * SVNリポジトリ からパラメータで指定した条件に該当するファイルを取得してファイルを作成する。
     * 
     * @param repository SVNリポジトリ
     * @param filePath ファイルパス
     * @param revision リビジョン
     * @param file 出力先ファイル
     */
    public static void createFile(SVNRepository repository, String filePath, long revision, File file) {
        try {
            SVNNodeKind nodeKind = repository.checkPath(filePath, revision);
            if (nodeKind == SVNNodeKind.FILE) {
                SVNProperties fileProperties = new SVNProperties();
                FileOutputStream fos = null;
                try {
                    fos = new FileOutputStream(file);
                    repository.getFile(filePath , revision , fileProperties , fos);
                } finally {
                    IOUtils.closeQuietly(fos);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
