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
import java.util.Date;

/**
 * プロジェクト情報テーブルのエンティティクラス。
 */
public class ProjectInfo implements Serializable {
    
    private static final long serialVersionUID = 5246728591297488732L;
    
    /** プロジェクトID */
    private Integer projectId;
    /** プロジェクト名 */
    private String projectName;
    /** 概要 */
    private String outline;
    /** 親プロジェクトID */
    private String parentId;
    /** 開始日 */
    private Date startDate;
    /** 終了日 */
    private Date endDate;
    /** 開発開始日 */
    private Date pgStartDate;
    /** 開発終了日 */
    private Date pgEndDate;
    /** 障害起算日 */
    private Integer troubleInitialDate;
    /** 課題起算日 */
    private Integer problemInitialDate;
    /** プロジェクトパス */
    private String projectPath;
    
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
    /**
     * プロジェクト名を取得します。
     * @return プロジェクト名
     */
    public String getProjectName() {
        return projectName;
    }
    /**
     * プロジェクト名を設定します。
     * @param projectName プロジェクト名
     */
    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }
    /**
     * 概要を取得します。
     * @return 概要
     */
    public String getOutline() {
        return outline;
    }
    /**
     * 概要を設定します。
     * @param outline 概要
     */
    public void setOutline(String outline) {
        this.outline = outline;
    }
    /**
     * 親プロジェクトIDを取得します。
     * @return 親プロジェクトID
     */
    public String getParentId() {
        return parentId;
    }
    /**
     * 親プロジェクトIDを設定します。
     * @param parentId 親プロジェクトID
     */
    public void setParentId(String parentId) {
        this.parentId = parentId;
    }
    /**
     * 開始日を取得します。
     * @return 開始日
     */
    public Date getStartDate() {
        return startDate;
    }
    /**
     * 開始日を設定します。
     * @param startDate 開始日
     */
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }
    /**
     * 終了日を取得します。
     * @return 終了日
     */
    public Date getEndDate() {
        return endDate;
    }
    /**
     * 終了日を設定します。
     * @param endDate 終了日
     */
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
    /**
     * 開発開始日を取得します。
     * @return 開発開始日
     */
    public Date getPgStartDate() {
        return pgStartDate;
    }
    /**
     * 開発開始日を設定します。
     * @param pgStartDate 開発開始日
     */
    public void setPgStartDate(Date pgStartDate) {
        this.pgStartDate = pgStartDate;
    }
    /**
     * 開発終了日を取得します。
     * @return 開発終了日
     */
    public Date getPgEndDate() {
        return pgEndDate;
    }
    /**
     * 開発終了日を設定します。
     * @param pgEndDate 開発終了日
     */
    public void setPgEndDate(Date pgEndDate) {
        this.pgEndDate = pgEndDate;
    }
    /**
     * 障害起算日を取得します。
     * @return 障害起算日
     */
    public Integer getTroubleInitialDate() {
        return troubleInitialDate;
    }
    /**
     * 障害起算日を設定します。
     * @param troubleInitialDate 障害起算日
     */
    public void setTroubleInitialDate(Integer troubleInitialDate) {
        this.troubleInitialDate = troubleInitialDate;
    }
    /**
     * 課題起算日を取得します。
     * @return 課題起算日
     */
    public Integer getProblemInitialDate() {
        return problemInitialDate;
    }
    /**
     * 課題起算日を設定します。
     * @param problemInitialDate 課題起算日
     */
    public void setProblemInitialDate(Integer problemInitialDate) {
        this.problemInitialDate = problemInitialDate;
    }
    /**
     * プロジェクトパスを取得します。
     * @return プロジェクトパス
     */
    public String getProjectPath() {
        return projectPath;
    }
    /**
     * プロジェクトパスを設定します。
     * @param projectPath プロジェクトパス
     */
    public void setProjectPath(String projectPath) {
        this.projectPath = projectPath;
    }

}
