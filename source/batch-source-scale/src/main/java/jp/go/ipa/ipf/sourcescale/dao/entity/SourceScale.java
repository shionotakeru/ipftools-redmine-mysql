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

package jp.go.ipa.ipf.sourcescale.dao.entity;

import java.io.Serializable;
import java.util.Date;

/**
 * ソース規模情報テーブルのエンティティクラス。
 */
public class SourceScale implements Serializable {

    private static final long serialVersionUID = 5943936300513251386L;

    /** プロジェクトID */
    String projectId;
    
    /** リビジョン */
    String revision;

    /** チケットID */
    Integer ticketId;

    /** ファイル名 */
    String fileName;
    
    /** ファイルタイプ */
    String fileType;
    
    /** パス名 */
    String filePath;
    
    /** 変更者 */
    String changeUserId;
    
    /** 更新日時 */
    Date changeDate;
    
    /** サイズ */
    long fileSize;
    
    /** 行数 */
    long sourceLines;
    
    /** 行数２ */
    long sourceLines2;
    
    /** 増加行数 */
    long increaseSourceLines;
    
    /** 増加行数２ */
    long increaseSourceLines2;

    /** 変更行数 */
    long changeSourceLines;

    /** 変更行数２ */
    long changeSourceLines2;

    /**
     * プロジェクトIDを取得します。
     * @return プロジェクトID
     */
    public String getProjectId() {
        return projectId;
    }

    /**
     * プロジェクトIDを設定します。
     * @param projectId プロジェクトID
     */
    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }

    /**
     * リビジョンを取得します。
     * @return リビジョン
     */
    public String getRevision() {
        return revision;
    }

    /**
     * リビジョンを設定します。
     * @param revision リビジョン
     */
    public void setRevision(String revision) {
        this.revision = revision;
    }

    /**
     * チケットIDを取得します。
     * @return チケットID
     */
    public Integer getTicketId() {
        return ticketId;
    }

    /**
     * チケットIDを設定します。
     * @param ticketId チケットID
     */
    public void setTicketId(Integer ticketId) {
        this.ticketId = ticketId;
    }

    /**
     * ファイル名を取得します。
     * @return ファイル名
     */
    public String getFileName() {
        return fileName;
    }

    /**
     * ファイル名を設定します。
     * @param fileName ファイル名
     */
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    /**
     * ファイルタイプを取得します。
     * @return ファイルタイプ
     */
    public String getFileType() {
        return fileType;
    }

    /**
     * ファイルタイプを設定します。
     * @param fileType ファイルタイプ
     */
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    /**
     * パス名を取得します。
     * @return パス名
     */
    public String getFilePath() {
        return filePath;
    }

    /**
     * パス名を設定します。
     * @param filePath パス名
     */
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    /**
     * 変更者を取得します。
     * @return 変更者
     */
    public String getChangeUserId() {
        return changeUserId;
    }

    /**
     * 変更者を設定します。
     * @param changeUserId 変更者
     */
    public void setChangeUserId(String changeUserId) {
        this.changeUserId = changeUserId;
    }

    /**
     * 更新日時を取得します。
     * @return 更新日時
     */
    public Date getChangeDate() {
        return changeDate;
    }

    /**
     * 更新日時を設定します。
     * @param changeDate 更新日時
     */
    public void setChangeDate(Date changeDate) {
        this.changeDate = changeDate;
    }

    /**
     * サイズを取得します。
     * @return サイズ
     */
    public long getFileSize() {
        return fileSize;
    }

    /**
     * サイズを設定します。
     * @param fileSize サイズ
     */
    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    /**
     * 行数を取得します。
     * @return 行数
     */
    public long getSourceLines() {
        return sourceLines;
    }

    /**
     * 行数を設定します。
     * @param sourceLines 行数
     */
    public void setSourceLines(long sourceLines) {
        this.sourceLines = sourceLines;
    }

    /**
     * 行数２を取得します。
     * @return 行数２
     */
    public long getSourceLines2() {
        return sourceLines2;
    }

    /**
     * 行数２を設定します。
     * @param sourceLines2 行数２
     */
    public void setSourceLines2(long sourceLines2) {
        this.sourceLines2 = sourceLines2;
    }

    /**
     * 増加行数を取得します。
     * @return 増加行数
     */
    public long getIncreaseSourceLines() {
        return increaseSourceLines;
    }

    /**
     * 増加行数を設定します。
     * @param increaseSourceLines 増加行数
     */
    public void setIncreaseSourceLines(long increaseSourceLines) {
        this.increaseSourceLines = increaseSourceLines;
    }

    /**
     * 増加行数２を取得します。
     * @return 増加行数２
     */
    public long getIncreaseSourceLines2() {
        return increaseSourceLines2;
    }

    /**
     * 増加行数２を設定します。
     * @param increaseSourceLines2 増加行数２
     */
    public void setIncreaseSourceLines2(long increaseSourceLines2) {
        this.increaseSourceLines2 = increaseSourceLines2;
    }

    /**
     * 変更行数を取得します。
     * @return 変更行数
     */
    public long getChangeSourceLines() {
        return changeSourceLines;
    }

    /**
     * 変更行数を設定します。
     * @param changeSourceLines 変更行数
     */
    public void setChangeSourceLines(long changeSourceLines) {
        this.changeSourceLines = changeSourceLines;
    }

    /**
     * 変更行数２を取得します。
     * @return 変更行数２
     */
    public long getChangeSourceLines2() {
        return changeSourceLines2;
    }

    /**
     * 変更行数２を設定します。
     * @param changeSourceLines2 変更行数２
     */
    public void setChangeSourceLines2(long changeSourceLines2) {
        this.changeSourceLines2 = changeSourceLines2;
    }

}
