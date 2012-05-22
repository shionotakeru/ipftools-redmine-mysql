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

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import jp.go.ipa.ipf.sourcescale.SourceScaleCount;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.lib.AnyObjectId;
import org.eclipse.jgit.lib.ObjectId;
import org.eclipse.jgit.lib.ObjectLoader;
import org.eclipse.jgit.lib.Ref;
import org.eclipse.jgit.lib.Repository;
import org.eclipse.jgit.revwalk.RevCommit;
import org.eclipse.jgit.revwalk.RevObject;
import org.eclipse.jgit.revwalk.RevSort;
import org.eclipse.jgit.revwalk.RevWalk;
import org.eclipse.jgit.storage.file.FileRepository;
import org.eclipse.jgit.treewalk.EmptyTreeIterator;
import org.eclipse.jgit.treewalk.TreeWalk;
import org.eclipse.jgit.treewalk.filter.TreeFilter;
import org.mozilla.universalchardet.UniversalDetector;

/**
 *  Git アクセス用ユーティリティクラス。
 */
public class IpfJGitUtils {

    /** ロガー */
    protected static Logger log = Logger.getLogger(SourceScaleCount.LOGGER_NAME);

    /** 文字コード判定用クラス */
    protected static UniversalDetector detector = new UniversalDetector(null);

    /**
     * Git のリポジトリオブジェクトを返す。
     * 
     * @param repoUrl リポジトリURL
     * @return Git のリポジトリオブジェクト
     * @throws Exception 
     */
    public static Repository getGitRepository(String repoUrl) throws Exception {
        Repository repository = new FileRepository(repoUrl);
        if (repository == null || repository.getAllRefs().isEmpty()) {
            String msg = String.format(SourceScaleCount.resource
                    .getString("git.error.parameter.unknown.repository"), repoUrl);
            throw new Exception(msg);
        }
        return repository;
    }
    
    /**
     * Git からパラメータで指定した条件に該当するファイルを取得してファイルを作成する。
     * 
     * @param repository Gitリポジトリ
     * @param filePath ファイルパス
     * @param objectId オブジェクトID
     * @param file 出力先ファイル
     */
    public static void createFile(
            Repository repository, 
            String filePath, 
            AnyObjectId objectId, 
            File file) {
        
        FileOutputStream fos = null;
        try {
            fos = FileUtils.openOutputStream(file);
            ObjectLoader loader = repository.open(objectId);
            loader.copyTo(fos);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            IOUtils.closeQuietly(fos);
        }
    }
    
    /**
     * コミット日時を返す
     * 
     * @param commit コミットログ
     * @return コミット日時
     */
    public static Date getCommitDate(RevCommit commit) {
        return new Date(commit.getCommitTime() * 1000L);
    }
    
    /**
     * 変更種別、変更前・変更後のオブジェクトIDを返す。
     * 
     * @param tWalk TreeWalk
     * @param objectIds 変更前、変更後のオブジェクトIDをセットして返す。
     *                  インデックス 0 : 変更前オブジェクトID
     *                  インデックス 1 : 変更後オブジェクトID
     * @return 変更種別(A:新規追加, M:変更, D:削除)
     */
    public static char getChangeType(TreeWalk tWalk, AnyObjectId[] objectIds) {
        
        char chg = 'M';
        int nTree = tWalk.getTreeCount();
        if (nTree == 1) {
            int m0 = tWalk.getRawMode(0); // new
            if (m0 != 0) {
                chg = 'A';
                objectIds[0] = tWalk.getObjectId(0); // new
            }
        } else if (nTree == 2) {
            int m0 = tWalk.getRawMode(0); // old
            int m1 = tWalk.getRawMode(1); // new
            if (m0 == 0 && m1 != 0) {
                chg = 'A';
            } else if (m0 != 0 && m1 == 0) {
                chg = 'D';
            } else if (m0 != m1 && tWalk.idEqual(0, 1)) {
                chg = 'T';
            }
            if (m0 != 0) {
                objectIds[0] = tWalk.getObjectId(0); // old
            }
            if (m1 != 0) {
                objectIds[1] = tWalk.getObjectId(1); // new
            }
        }
        
        return chg;
    }

    /**
     * 変更前、変更後ファイル比較用の TreeWalk を返す。
     * 
     * @param repository リポジトリ
     * @param commit 指定リビジョンの RevCommit
     * @param rwalk RevWalk
     * @return 変更前、変更後ファイル比較用の TreeWalk
     * @throws Exception 
     */
    public static TreeWalk getTreeWalk(
            Repository repository, 
            RevCommit commit, 
            RevWalk rwalk) throws Exception {
        
        TreeWalk twalk = new TreeWalk(repository);
        
        if (commit.getParentCount() > 0) {
            RevCommit parent = commit.getParent(0);
            if (parent.getTree() == null) {
                // リビジョン指定で実行した場合、親リビジョンの RevTree が取得できないので、
                // RevWalk から親リビジョンを取得してから RevTree を取得する。
                parent = rwalk.parseCommit(parent.getId());
            }
            twalk.addTree(parent.getTree());
            twalk.addTree(commit.getTree());
        } else {
            twalk.addTree(new EmptyTreeIterator());
            twalk.addTree(commit.getTree());
        }
        twalk.setRecursive(true);
        twalk.setFilter(TreeFilter.ANY_DIFF);
        return twalk;
    }

    /**
     * 全リビジョンの RevCommit のリストを返す。
     * 
     * @param repository リポジトリ
     * @return RevCommit のリスト
     * @throws Exception 
     */
    public static Iterator<RevCommit> getRevList(Repository repository) throws Exception {
        
        Git git = new Git(repository);
        Iterable<RevCommit> irc = git.log().call();
        
        return irc.iterator();
    }
    
    /**
     * 指定したリビジョンの RevCommit のリストを返す。
     * 
     * @param repository リポジトリ
     * @param oldRev 旧リビジョン
     * @return RevCommit のリスト
     * @throws Exception 
     */
    public static Iterator<RevCommit> getRevList(Repository repository,
            String oldRev) throws Exception {
        
        // 旧リビジョン
        ObjectId oldObjId = repository.resolve(oldRev);
        if (oldObjId == null) {
            String msg = String.format(SourceScaleCount.resource
                    .getString("git.error.parameter.unknown.oldrev"),
                    oldRev);
            throw new Exception(msg);
        }
        
        Git git = new Git(repository);
        Iterable<RevCommit> irc = null;
        if (oldObjId.equals(RevObject.zeroId())) {
            // リビジョンが ALL 0 の場合
            irc = git.log().call();
        } else {
            irc = git.log().not(oldObjId).call();
        }
        
        return irc.iterator();
    }
    
    /**
     * 指定したリビジョンの RevCommit のリストを返す。
     * 
     * @param repository リポジトリ
     * @param oldRev 旧リビジョン
     * @param newRev 新リビジョン
     * @return RevCommit のリスト
     * @throws Exception 
     */
    public static Iterator<RevCommit> getRevList(Repository repository,
            String oldRev, String newRev) throws Exception {
        
        // 旧リビジョン
        ObjectId oldObjId = repository.resolve(oldRev);
        if (oldObjId == null) {
            String msg = String.format(SourceScaleCount.resource
                    .getString("git.error.parameter.unknown.oldrev"),
                    oldRev);
            throw new Exception(msg);
        }
        // 新リビジョン
        ObjectId newObjId = repository.resolve(newRev);
        if (newObjId == null) {
            String msg = String.format(SourceScaleCount.resource
                    .getString("git.error.parameter.unknown.newrev"),
                    newRev);
            throw new Exception(msg);
        }
        
        Git git = new Git(repository);
        Iterable<RevCommit> irc = null;
        if (oldObjId.equals(RevObject.zeroId())) {
            // リビジョンが ALL 0 の場合
            irc = git.log().add(newObjId).call();
        } else {
            irc = git.log().addRange(oldObjId, newObjId).call();
        }
        return irc.iterator();
    }
    
    /**
     * 全てのブランチを含むの RevWalk を返す。
     * 
     * @param repository リポジトリ
     * @param oldRev 旧リビジョン
     * @param newRev 新リビション
     * @return 全てのブランチを含むの RevWalk
     * @throws Exception 
     */
    public static RevWalk getAllRevWalk(Repository repository) 
            throws Exception {
        
        RevWalk rwalk = new RevWalk(repository);
        
        Map<String, Ref> map = repository.getAllRefs();
        Collection<RevCommit> list = new ArrayList<RevCommit>();
        for (Entry<String, Ref> entry : map.entrySet()) {
            String  name = entry.getKey();
            Ref     ref  = entry.getValue();
            RevCommit revCommit = rwalk.parseCommit(ref.getObjectId());
            list.add(revCommit);
        }
        rwalk.markStart(list);
        rwalk.sort(RevSort.REVERSE);
        return rwalk;
    }
    
    /**
     * バイト配列を文字列に変換して返す。
     * 
     * @param バイト配列
     * @return 文字列
     */
    public static String getDecodeStr(byte[] bytes) {
        
        String encoding = getEncoding(bytes);
        log.debug("Encoding:" + encoding);
        
        String decodeStr = null;
        try {
            if (StringUtils.equalsIgnoreCase(encoding, "UTF-8") ||
                StringUtils.equalsIgnoreCase(encoding, "EUC-JP")) {
                // encoding
                decodeStr = new String(bytes, encoding);
            } else if (StringUtils.equalsIgnoreCase(encoding, "SHIFT_JIS")) {
                // MS932
                decodeStr = new String(bytes, "MS932");
            } else {
                // JISAutoDetect
                decodeStr = new String(bytes, "JISAutoDetect");
            }
        } catch (UnsupportedEncodingException e) {
            //
        }
        
        return decodeStr;
    }
    

    /**
     * バイト配列の文字コードを判別して返す。
     * 
     * @param バイト配列
     * @return 文字コード
     */
    public static String getEncoding (byte[] bytes) {
        
        String encoding = null;
        
        /** 文字コード判定用クラス */
        UniversalDetector detector = new UniversalDetector(null);
        
        ByteArrayInputStream bis = null;
        try {
            bis = new ByteArrayInputStream(bytes);
            byte[] buf = new byte[4096];
            int nread;
            while ((nread = bis.read(buf)) > 0 && !detector.isDone()) {
                detector.handleData(buf, 0, nread);
            }
            detector.dataEnd();
            
            if (detector.getDetectedCharset() != null) {
                encoding = detector.getDetectedCharset();
            }
            
        } catch (Exception e) {
            //
        } finally {
            IOUtils.closeQuietly(bis);
            detector.reset();
        }
        return encoding;
    }
    
}
