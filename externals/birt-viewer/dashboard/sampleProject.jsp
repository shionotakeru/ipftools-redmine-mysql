<%-----------------------------------------------------------------------------
    <Quantitative project management tool.>
    Copyright (C) 2012 IPA, Japan.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------------%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/birt.tld" prefix="birt" %>
<%@ taglib uri="/ipf.tld" prefix="ipf" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<bean:define id="TODAY">2011/12/25</bean:define>
<bean:define id="ONE_MONTH_AGO">2011/11/25</bean:define>
<bean:define id="ONE_MONTH_AFTER">2012/01/25</bean:define>

<div id="dashboard_title">サンプルプロジェクト(sampleProject.jsp)</div>

<!-- R_S01 -->
<ipf:authDisp permissions="IPF_GRAPH_S01">
<ipf:graph id="graph1" reportDesign="report/R_S01.rptdesign">
<ipf:graphTitle>試験計画項目密度(R_S01)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"   value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"    value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
<birt:param name="TARGET_DATE"  value="${TODAY}"                        ></birt:param>
</ipf:graph>
</ipf:authDisp>

<!-- R_S02 -->
<ipf:authDisp permissions="IPF_GRAPH_S02">
<ipf:graph id="graph2" reportDesign="report/R_S02.rptdesign">
<ipf:graphTitle>WBS進捗推移(R_S02)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                    ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET_RS02.TICKET_ID}" ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"                 ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${ONE_MONTH_AFTER}"               ></birt:param>
<birt:param name="SCALE"            value="0"                                ></birt:param>
<birt:param name="PRODUCTIVITY"     value=""                                 ></birt:param>
</ipf:graph>
</ipf:authDisp>

<!-- R_S03 -->
<ipf:authDisp permissions="IPF_GRAPH_S03">
<ipf:graph id="graph3" reportDesign="report/R_S03.rptdesign">
<ipf:graphTitle>WBS進捗変化(R_S03)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                     ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET_RS02.TICKET_ID}"  ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"                  ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                          ></birt:param>
<birt:param name="SCALE"            value="0"                                 ></birt:param>
</ipf:graph>
</ipf:authDisp>

<!-- R_S04 -->
<ipf:authDisp permissions="IPF_GRAPH_S04">
<ipf:graph id="graph4" reportDesign="report/R_S04.rptdesign">
<ipf:graphTitle>EVM評価（進捗、工数）(R_S04)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                           ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"             ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE}"    ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TOP_WBS_TICKET.PLANNED_END_DATE}"      ></birt:param>
<birt:param name="SCALE"            value="0"                                       ></birt:param>
<birt:param name="PRODUCTIVITY"     value="1"                                       ></birt:param>
<birt:param name="COST"             value="0"                                       ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S05 -->
<ipf:authDisp permissions="IPF_GRAPH_S05">
<ipf:graph id="graph5" reportDesign="report/R_S05.rptdesign">
<ipf:graphTitle>ソフトウェア規模推移(R_S05)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S06 -->
<ipf:authDisp permissions="IPF_GRAPH_S06">
<ipf:graph id="graph6" reportDesign="report/R_S06.rptdesign">
<ipf:graphTitle>試験進捗率(R_S06)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
<birt:param name="SELECT_OUTPUT"    value="0"                                             ></birt:param>
<birt:param name="XAXIS_COUNT"      value=""                                              ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S07 -->
<ipf:authDisp permissions="IPF_GRAPH_S07">
<ipf:graph id="graph7" reportDesign="report/R_S07.rptdesign">
<ipf:graphTitle>工数の予実(R_S07)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                       ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"         ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE}"></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TOP_WBS_TICKET.PLANNED_END_DATE}"  ></birt:param>
<birt:param name="SCALE"            value="0"                                   ></birt:param>
<birt:param name="PRODUCTIVITY"     value="0"                                   ></birt:param>
</ipf:graph>
</ipf:authDisp>

<!-- R_S08 -->
<ipf:authDisp permissions="IPF_GRAPH_S08">
<ipf:graph id="graph8" reportDesign="report/R_S08.rptdesign">
<ipf:graphTitle>障害件数変化(R_S08)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S09 -->
<ipf:authDisp permissions="IPF_GRAPH_S09">
<ipf:graph id="graph9" reportDesign="report/R_S09.rptdesign">
<ipf:graphTitle>障害原因分析(R_S09)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S10 -->
<ipf:authDisp permissions="IPF_GRAPH_S10">
<ipf:graph id="graph10" reportDesign="report/R_S10.rptdesign">
<ipf:graphTitle>障害発生密度(R_S10)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S11 -->
<ipf:authDisp permissions="IPF_GRAPH_S11">
<ipf:graph id="graph11" reportDesign="report/R_S11.rptdesign">
<ipf:graphTitle>障害滞留状況(R_S11)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S12 -->
<ipf:authDisp permissions="IPF_GRAPH_S12">
<ipf:graph id="graph12" reportDesign="report/R_S12.rptdesign">
<ipf:graphTitle>負荷状況(R_S12)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"        ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                ></birt:param>
<birt:param name="SELECT_OUTPUT"    value="0"                       ></birt:param>
<birt:param name="BORDER_TIME"      value="160"                     ></birt:param>
<birt:param name="WORKER_ID"        value="0"                       ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S13 -->
<ipf:authDisp permissions="IPF_GRAPH_S13">
<ipf:graph id="graph13" reportDesign="report/R_S13.rptdesign">
<ipf:graphTitle>障害解決予測(R_S13)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S14 -->
<ipf:authDisp permissions="IPF_GRAPH_S14">
<ipf:graph id="graph14" reportDesign="report/R_S14.rptdesign">
<ipf:graphTitle>長期未解決課題抽出(R_S14)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="PERIOD"           value="1"                       ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S15 -->
<ipf:authDisp permissions="IPF_GRAPH_S15">
<ipf:graph id="graph15" reportDesign="report/R_S15.rptdesign">
<ipf:graphTitle>遅延重要タスク抽出(R_S15)</ipf:graphTitle>
<ipf:graphComment>
サンプルプロジェクトのデータです。
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="SEVERITY"         value="1"                       ></birt:param>
</ipf:graph>
</ipf:authDisp>


