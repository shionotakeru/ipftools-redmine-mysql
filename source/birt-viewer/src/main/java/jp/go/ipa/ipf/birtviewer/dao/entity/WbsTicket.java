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
import java.util.Calendar;
import java.util.Date;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.commons.lang.builder.ToStringStyle;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang.time.DateUtils;

/**
 * WBSチケットテーブルのエンティティクラス。
 */
public class WbsTicket implements Serializable {
    
    private static final long serialVersionUID = -6693567758693860230L;
    
    /** チケットID */
    private Integer ticketId;
    /** プロジェクトID */
    private Integer projectId;
    /** 親チケットID */
    private Integer parentId;
    /** WBS開始予定日 */
    private Date plannedStartDate;
    /** WBS終了予定日 */
    private Date plannedEndDate;
    
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
	 * 親チケットIDを取得します。
	 * @return 親チケットID
	 */
	public Integer getParentId() {
	    return parentId;
	}
	/**
	 * 親チケットIDを設定します。
	 * @param parentId 親チケットID
	 */
	public void setParentId(Integer parentId) {
	    this.parentId = parentId;
	}
	/**
	 * WBS開始予定日を取得します。
	 * @return WBS開始予定日
	 */
	public Date getPlannedStartDate() {
	    return plannedStartDate;
	}
	/**
	 * WBS開始予定日を設定します。
	 * @param plannedStartDate WBS開始予定日
	 */
	public void setPlannedStartDate(Date plannedStartDate) {
	    this.plannedStartDate = plannedStartDate;
	}
	/**
	 * WBS終了予定日を取得します。
	 * @return WBS終了予定日
	 */
	public Date getPlannedEndDate() {
	    return plannedEndDate;
	}
	/**
	 * WBS終了予定日を設定します。
	 * @param plannedEndDate WBS終了予定日
	 */
	public void setPlannedEndDate(Date plannedEndDate) {
	    this.plannedEndDate = plannedEndDate;
	}
    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this,
                ToStringStyle.MULTI_LINE_STYLE);
    }
    
    /**
     * チケットIDを取得します。
     * @return TICKET_ID
     */
    public String getTICKET_ID() {
        return (ticketId != null ? ticketId.toString() : "");
    }
    /**
     * WBS開始予定日を取得します。
     * @return WBS開始予定日
     */
    public String getPLANNED_START_DATE() {
        return (plannedStartDate != null ?
            DateFormatUtils.format(plannedStartDate, "yyyy/MM/dd") : "");
    }
    
    /**
     * WBS開始予定日を取得します。
     * @return WBS開始予定日
     */
    public String getPLANNED_START_DATE_OR_TODAY() {
        String startDate = "";
        if (plannedStartDate != null) {
            Date today = DateUtils.truncate(new Date(), Calendar.DAY_OF_MONTH);
            if (plannedStartDate.after(today)) {
                // システム日付より後の場合
                startDate = DateFormatUtils.format(today, "yyyy/MM/dd");
            } else {
                // システム日付以前の場合
                startDate = DateFormatUtils.format(plannedStartDate, "yyyy/MM/dd");
            }
        }
        return startDate;
    }
    
    /**
     * WBS終了予定日を取得します。
     * @return WBS終了予定日
     */
    public String getPLANNED_END_DATE() {
        return (plannedEndDate != null ?
                DateFormatUtils.format(plannedEndDate, "yyyy/MM/dd") : "");
    }

}
