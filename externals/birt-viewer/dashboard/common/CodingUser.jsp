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

<div id="dashboard_title">製造工程（一般向け）(common/CodingUser.jsp)</div>

<!-- R_S02 -->
<ipf:authDisp permissions="IPF_GRAPH_S02">
<ipf:graph id="graph2" reportDesign="report/R_S02.rptdesign">
<ipf:graphTitle>WBS進捗推移(R_S02)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
過去の進捗率から、今後の開発の進み具合を予測し、タスク完了予定日を把握します。<br/>
【概要】<br/>
・パラメータで指定したWBSタスクの進捗推移を表示します。<br/>
・グラフ表示期間（開始日、終了日）と、スケール（週単位／月単位）、及び予測線を表示する為の進捗率変化分をグラフパラメータで指定します。<br/>
・グラフ表示期間の終了日に、未来の日付を指定した場合、進捗率の予測線を表示します。<br/>
・表示対象のWBSタスクの計画値（開始日、終了予定日）と予測日（終了予定日）を一覧で表示します。<br/>
・子グラフとして、「R_S03：WBS進捗変化」グラフを表示します。 <br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET_RS02.TICKET_ID}"></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"                ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${ONE_MONTH_AFTER}"              ></birt:param>
<birt:param name="SCALE"            value="0"                               ></birt:param>
<birt:param name="PRODUCTIVITY"     value=""                                ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S05 -->
<ipf:authDisp permissions="IPF_GRAPH_S05">
<ipf:graph id="graph5" reportDesign="report/R_S05.rptdesign">
<ipf:graphTitle>ソフトウェア規模推移(R_S05)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
ソース規模実績値の推移、及び計画値との対比を行い、製造工程での進捗確認、及び試験工程での品質低下の予兆がないか確認します。<br/>
【概要】<br/>
・パラメータ指定の期間内で、現在までのソース規模の実績推移、実績変化分、予実割合を週ごとに表示します。<br/>
・表示対象のWBSタスクと、グラフ表示期間（開始日、終了日）をグラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S15 -->
<ipf:authDisp permissions="IPF_GRAPH_S15">
<ipf:graph id="graph15" reportDesign="report/R_S15.rptdesign">
<ipf:graphTitle>遅延重要タスク抽出(R_S15)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
・予測遅延日数の大きなWBSタスクを抽出することにより、対策が必要なWBSタスクの確認を行います。<br/>
【概要】<br/>
・WBSタスクの進捗率を基に遅延予測を行い、その予測遅延日数を表示します。<br/>
・表示対象とするWBSタスクの重要度をパラメータで選択します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="SEVERITY"         value="1"                       ></birt:param>
</ipf:graph>
</ipf:authDisp>

